import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';
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

class RecipeStepDraft {
  final String instruction;
  final int timerSeconds;

  const RecipeStepDraft({required this.instruction, this.timerSeconds = 0});
}

class RecipeSeedSpec {
  final String id;
  final String name;
  final String description;
  final int servings;
  final int prepTime;
  final int cookTime;
  final List<RecipeStepDraft> steps;
  final List<String> tags;
  final List<String> techniqueIDs;
  final List<String> imageURL;
  final List<RecipeIngredientDraft> ingredients;
  final bool isPublic;

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
    final ingredientsSnapshot = await db
        .collection(FirestoreConstants.ingredients)
        .get();
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

      final calculatedWeight = _safeConvertToGrams(
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

    final nutritionTotal = _calculateRecipeNutritionFromEnrichedIngredients(
      enrichedIngredients,
    );

    final nutritionPerServing =
        NutritionCalculator.calculateNutritionPerServing(
          totalNutrition: nutritionTotal,
          servings: spec.servings,
        );

    return Recipe(
      id: spec.id,
      name: spec.name,
      ingredients: enrichedIngredients,
      steps: spec.steps
          .map(
            (step) => RecipeStep(
              instruction: step.instruction,
              timerSeconds: step.timerSeconds,
            ),
          )
          .toList(),
      description: spec.description,
      isPublic: spec.isPublic,
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

  static double _safeConvertToGrams({
    required double quantity,
    required Unit unit,
    required Ingredient ingredient,
  }) {
    try {
      return NutritionCalculator.convertToGrams(
        quantity: quantity,
        unit: unit,
        ingredient: ingredient,
      );
    } catch (_) {
      if (unit.type == 'weight') {
        return quantity * unit.multiplier;
      }
      if (unit.type == 'volume') {
        // Seeder fallback: when density is missing, treat 1ml ~= 1g.
        return quantity * unit.multiplier;
      }
      if (unit.type == 'count') {
        return ingredient.avgWeightG != null
            ? quantity * ingredient.avgWeightG!
            : quantity;
      }
      return 0;
    }
  }

  static NutritionInfo _calculateRecipeNutritionFromEnrichedIngredients(
    List<RecipeIngredient> ingredients,
  ) {
    var calories = 0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    var fiber = 0.0;
    var sugar = 0.0;
    var sodium = 0.0;

    for (final ingredient in ingredients) {
      final base = ingredient.nutritionPer100g;
      if (base == null) {
        continue;
      }
      final grams = ingredient.calculatedWeightG ?? 0;
      if (grams <= 0) {
        continue;
      }

      final factor = grams / 100;
      calories += (base.calories * factor).round();
      protein += base.protein * factor;
      carbs += base.carbohydrates * factor;
      fat += base.fat * factor;
      fiber += base.fiber * factor;
      sugar += base.sugar * factor;
      sodium += base.sodium * factor;
    }

    return NutritionInfo(
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
    );
  }
}
