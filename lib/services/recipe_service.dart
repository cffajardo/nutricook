import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Recipe>> getPublicRecipes({int limit = 20}) {
    return _db
        .collection(FirestoreConstants.recipes)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList());
  }

  Stream<Recipe?> getRecipeById(String recipeId) {
    return _db
        .collection(FirestoreConstants.recipes)
        .doc(recipeId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Recipe.fromJson(doc.data()!);
    });
  }

  Stream<List<Recipe>> getUserRecipes(String userId) {
    return _db
        .collection(FirestoreConstants.recipes)
        .where('ownerID', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Recipe>> getTrendingRecipes({int limit = 10}) {
    return _db
        .collection(FirestoreConstants.recipes)
        .where('isPublic', isEqualTo: true)
        .orderBy('favoriteCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Recipe>> getFilteredRecipesWithUserAllergens(
    List<String> userAllergenIds,
  ) {
    return getPublicRecipes().map((recipes) {
      return recipes.where((recipe) {
        return !recipe.ingredients.any(
          (ingredient) => userAllergenIds.contains(ingredient.ingredientID),
        );
      }).toList();
    });
  }


  Future<String> createRecipe({
    required Recipe recipe,
    required Map<String, Ingredient> ingredientsMap,
    required Map<String, Unit> unitsMap,
  }) async {
    final recipeRef = recipe.id.isEmpty
        ? _db.collection(FirestoreConstants.recipes).doc()
        : _db.collection(FirestoreConstants.recipes).doc(recipe.id);

    final userId = _auth.currentUser?.uid ?? 'anonymous';

    final enrichedIngredients = recipe.ingredients.map((recipeIng) {
      final ingredient = ingredientsMap[recipeIng.ingredientID];
      final unit = unitsMap[recipeIng.unitID];

      if (ingredient == null || unit == null) {
        throw Exception(
          'Invalid ingredient or unit: ${recipeIng.ingredientID}, ${recipeIng.unitID}',
        );
      }

      final calculatedWeight = NutritionCalculator.convertToGrams(
        quantity: recipeIng.quantity,
        unit: unit,
        ingredient: ingredient,
      );

      return recipeIng.copyWith(
        name: ingredient.name,
        unitName: unit.name,
        nutritionPer100g: ingredient.nutritionPer100g,
        densityGPerMl: ingredient.densityGPerMl,
        avgWeightG: ingredient.avgWeightG,
        calculatedWeightG: calculatedWeight,
      );
    }).toList();

    final totalNutrition = NutritionCalculator.calculateRecipeNutrition(
      recipeIngredients: enrichedIngredients,
      ingredientsMap: ingredientsMap,
      unitsMap: unitsMap,
    );

    final recipeWithId = recipe.copyWith(
      id: recipeRef.id,
      ownerId: userId,
      ingredients: enrichedIngredients,
      nutritionTotal: totalNutrition,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await recipeRef.set(recipeWithId.toJson());
    return recipeRef.id;
  }

  Future<void> updateRecipe({
    required Recipe recipe,
    required Map<String, Ingredient> ingredientsMap,
    required Map<String, Unit> unitsMap,
  }) async {
    final enrichedIngredients = recipe.ingredients.map((recipeIng) {
      final ingredient = ingredientsMap[recipeIng.ingredientID];
      final unit = unitsMap[recipeIng.unitID];

      if (ingredient == null || unit == null) {
        return recipeIng;
      }

      final calculatedWeight = NutritionCalculator.convertToGrams(
        quantity: recipeIng.quantity,
        unit: unit,
        ingredient: ingredient,
      );

      return recipeIng.copyWith(
        name: ingredient.name,
        unitName: unit.name,
        nutritionPer100g: ingredient.nutritionPer100g,
        densityGPerMl: ingredient.densityGPerMl,
        avgWeightG: ingredient.avgWeightG,
        calculatedWeightG: calculatedWeight,
      );
    }).toList();

    // Recalculate nutrition
    final totalNutrition = NutritionCalculator.calculateRecipeNutrition(
      recipeIngredients: enrichedIngredients,
      ingredientsMap: ingredientsMap,
      unitsMap: unitsMap,
    );

    final updatedRecipe = recipe.copyWith(
      ingredients: enrichedIngredients,
      nutritionTotal: totalNutrition,
      updatedAt: DateTime.now(),
    );

    await _db
        .collection(FirestoreConstants.recipes)
        .doc(recipe.id)
        .update(updatedRecipe.toJson());
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _db
        .collection(FirestoreConstants.recipes)
        .doc(recipeId)
        .delete();
  }

  Future<void> addFavorite(String recipeId, String userId) async {
    final recipeRef = _db.collection(FirestoreConstants.recipes).doc(recipeId);
    await recipeRef.update({
      'favoriteCount': FieldValue.increment(1),
      'favoritedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeFavorite(String recipeId, String userId) async {
    final recipeRef = _db.collection(FirestoreConstants.recipes).doc(recipeId);
    await recipeRef.update({
      'favoriteCount': FieldValue.increment(-1),
      'favoritedBy': FieldValue.arrayRemove([userId]),
    });
  }

  bool doesRecipeContainAllergens(
    Recipe recipe,
    List<String> userAllergenIds,
  ) {
    return recipe.ingredients.any(
      (ingredient) => userAllergenIds.contains(ingredient.ingredientID),
    );
  }

  Stream<List<Recipe>> getRecipesSafeForUser(String userId) async* {
    final userDoc = await _db.collection('users').doc(userId).get();
    final userAllergens = List<String>.from(userDoc.data()?['allergens'] ?? []);

    yield* getFilteredRecipesWithUserAllergens(userAllergens);
  }
}