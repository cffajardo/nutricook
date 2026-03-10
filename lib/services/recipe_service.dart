import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/unit/unit.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Recipe>> getPublicRecipes({int? limit}) {
    var query = _db
        .collection(FirestoreConstants.recipes)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList(),
    );
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
        .where('ownerId', isEqualTo: userId)
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

    final data = _sanitizeForFirestore(_recipeToFirestoreData(recipeWithId))
        as Map<String, dynamic>;
    await recipeRef.set(data);
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

    final data = _sanitizeForFirestore(_recipeToFirestoreData(updatedRecipe))
        as Map<String, dynamic>;
    await _db
        .collection(FirestoreConstants.recipes)
        .doc(recipe.id)
        .update(data);
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

  Map<String, dynamic> _recipeToFirestoreData(Recipe recipe) {
    return <String, dynamic>{
      'id': recipe.id,
      'name': recipe.name,
      'description': recipe.description,
      'isPublic': recipe.isPublic,
      'isVerified': recipe.isVerified,
      'servings': recipe.servings,
      'cookTime': recipe.cookTime,
      'prepTime': recipe.prepTime,
      'createdAt': Timestamp.fromDate(recipe.createdAt),
      'updatedAt': Timestamp.fromDate(recipe.updatedAt),
      'ownerId': recipe.ownerId,
      'favoriteCount': recipe.favoriteCount,
      'reportCount': recipe.reportCount,
      'tags': recipe.tags,
      'techniqueIDs': recipe.techniqueIDs,
      'imageURL': recipe.imageURL,
      'ingredients': recipe.ingredients
          .map(
            (item) => <String, dynamic>{
              'ingredientID': item.ingredientID,
              'name': item.name,
              'quantity': item.quantity,
              'unitID': item.unitID,
              'unitName': item.unitName,
              'nutritionPer100g': item.nutritionPer100g?.toJson(),
              'densityGPerMl': item.densityGPerMl,
              'avgWeightG': item.avgWeightG,
              'calculatedWeightG': item.calculatedWeightG,
              'preparation': item.preparation,
            },
          )
          .toList(),
      'steps': recipe.steps
          .map(
            (item) => <String, dynamic>{
              'instruction': item.instruction,
              'timerSeconds': item.timerSeconds,
            },
          )
          .toList(),
      'nutritionTotal': recipe.nutritionTotal?.toJson(),
      'nutritionPerServing': recipe.nutritionPerServing?.toJson(),
    };
  }

  dynamic _sanitizeForFirestore(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is Timestamp) {
      return value;
    }
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    if (value is NutritionInfo) {
      return value.toJson();
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(
          key.toString(),
          _sanitizeForFirestore(entryValue),
        ),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitizeForFirestore).toList();
    }
    return value;
  }
}