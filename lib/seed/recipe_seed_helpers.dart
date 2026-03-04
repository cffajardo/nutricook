import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';

class RecipeIngredientDraft {
  final String ingredientID;
  final double quantity;
  final String unitID;
  final String? preparation;

  const RecipeIngredientDraft({
    required this.ingredientID,
    required this.quantity,
    required this.unitID,
    this.preparation,
  });
}

class RecipeSeedSpec {
  final String id;
  final String name;
  final String description;
  final int servings;
  final int prepTime;
  final int cookTime;
  final List<String> steps;
  final List<String> tags;
  final List<String> techniqueIDs;
  final List<String> imageURL;
  final List<RecipeIngredientDraft> ingredients;
  final bool isPublic;
  final bool isVerified;

  const RecipeSeedSpec({
    required this.id,
    required this.name,
    required this.description,
    required this.servings,
    required this.prepTime,
    required this.cookTime,
    required this.steps,
    required this.ingredients,
    this.tags = const <String>[],
    this.techniqueIDs = const <String>[],
    this.imageURL = const <String>[],
    this.isPublic = true,
    this.isVerified = true,
  });
}

class RecipeSeedReferenceData {
  final Map<String, Ingredient> ingredientsMap;
  final Map<String, Unit> unitsMap;

  const RecipeSeedReferenceData({
    required this.ingredientsMap,
    required this.unitsMap,
  });
}

class RecipeSeedHelpers {
  static Future<RecipeSeedReferenceData> loadReferenceData(
    FirebaseFirestore db,
  ) async {
    final ingredientsSnapshot =
        await db.collection(FirestoreConstants.ingredients).get();
    final unitsSnapshot = await db.collection(FirestoreConstants.units).get();

    final ingredientsMap = {
      for (final doc in ingredientsSnapshot.docs)
        doc.id: Ingredient.fromJson(doc.data()),
    };

    final unitsMap = {
      for (final doc in unitsSnapshot.docs) doc.id: Unit.fromJson(doc.data()),
    };

    return RecipeSeedReferenceData(
      ingredientsMap: ingredientsMap,
      unitsMap: unitsMap,
    );
  }

  static Recipe buildEnrichedRecipe({
    required RecipeSeedSpec spec,
    required Map<String, Ingredient> ingredientsMap,
    required Map<String, Unit> unitsMap,
    String? ownerId,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();

    final enrichedIngredients = spec.ingredients.map((draft) {
      final ingredient = ingredientsMap[draft.ingredientID];
      final unit = unitsMap[draft.unitID];

      if (ingredient == null || unit == null) {
        throw Exception(
          'Invalid ingredient or unit: ${draft.ingredientID}, ${draft.unitID}',
        );
      }

      final calculatedWeight = NutritionCalculator.convertToGrams(
        quantity: draft.quantity,
        unit: unit,
        ingredient: ingredient,
      );

      return RecipeIngredient(
        ingredientID: draft.ingredientID,
        name: ingredient.name,
        quantity: draft.quantity,
        unitID: draft.unitID,
        unitName: unit.name,
        nutritionPer100g: ingredient.nutritionPer100g,
        densityGPerMl: ingredient.densityGPerMl,
        avgWeightG: ingredient.avgWeightG,
        calculatedWeightG: calculatedWeight,
        preparation: draft.preparation,
      );
    }).toList();

    final nutritionTotal = NutritionCalculator.calculateRecipeNutrition(
      recipeIngredients: enrichedIngredients,
      ingredientsMap: ingredientsMap,
      unitsMap: unitsMap,
    );

    final nutritionPerServing = NutritionCalculator.calculateNutritionPerServing(
      totalNutrition: nutritionTotal,
      servings: spec.servings,
    );

    return Recipe(
      id: spec.id,
      name: spec.name,
      ingredients: enrichedIngredients,
      steps: spec.steps,
      description: spec.description,
      isPublic: spec.isPublic,
      isVerified: spec.isVerified,
      servings: spec.servings,
      cookTime: spec.cookTime,
      prepTime: spec.prepTime,
      createdAt: timestamp,
      updatedAt: timestamp,
      nutritionTotal: nutritionTotal,
      nutritionPerServing: nutritionPerServing,
      ownerId: ownerId,
      tags: spec.tags,
      techniqueIDs: spec.techniqueIDs,
      imageURL: spec.imageURL,
    );
  }
}
