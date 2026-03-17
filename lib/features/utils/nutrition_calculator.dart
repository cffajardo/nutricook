import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';


class NutritionCalculator {
  
  static double convertToGrams({
    required double quantity,
    required Unit unit,
    required Ingredient ingredient,
  }) {
    switch (unit.type) {
      case 'weight':
        // Convert to grams using unit multiplier
        return quantity * unit.multiplier;

      case 'volume':
        if (ingredient.densityGPerMl == null) {
          throw Exception(
            'Cannot convert volume to weight: ${ingredient.name} is missing Density Value. '
            'Please add density data to this ingredient.',
          );
        }
        // Convert to ml using unit multiplier
        final volumeInMl = quantity * unit.multiplier;
        // Convert ml to grams using density (g/ml)
        return volumeInMl * ingredient.densityGPerMl!;

      case 'count':
        if (ingredient.avgWeightG == null) {
          throw Exception(
            'Cannot convert count to weight: ${ingredient.name} is missing Average Weight Value. '
            'Please add average weight data to this ingredient.',
          );
        }
        
        // Convert pieces to grams using average weight
        return quantity * ingredient.avgWeightG!;

      default:
        throw Exception('Unknown unit type: ${unit.type}');
    }
  }

  static NutritionInfo calculateNutrition({
    required double quantity,
    required Unit unit,
    required Ingredient ingredient,
  }) {
    if (ingredient.nutritionPer100g == null) {
      return const NutritionInfo(
        calories: 0,
        protein: 0,
        carbohydrates: 0,
        fat: 0,
        fiber: 0,
        sugar: 0,
        sodium: 0,
      );
    }

    // Convert to grams first
    final grams = convertToGrams(
      quantity: quantity,
      unit: unit,
      ingredient: ingredient,
    );

    // Calculate nutrition based on per-100g values
    final factor = grams / 100;

    return NutritionInfo(
      calories: (ingredient.nutritionPer100g!.calories * factor).round(),
      protein: ingredient.nutritionPer100g!.protein * factor,
      carbohydrates: ingredient.nutritionPer100g!.carbohydrates * factor,
      fat: ingredient.nutritionPer100g!.fat * factor,
      fiber: ingredient.nutritionPer100g!.fiber * factor,
      sugar: ingredient.nutritionPer100g!.sugar * factor,
      sodium: ingredient.nutritionPer100g!.sodium * factor,
    );
  }

  static NutritionInfo calculateRecipeNutrition({
    required List<RecipeIngredient> recipeIngredients,
    required Map<String, Ingredient> ingredientsMap,
    required Map<String, Unit> unitsMap,
  }) {
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;

    for (final recipeIng in recipeIngredients) {
      final ingredient = ingredientsMap[recipeIng.ingredientID];
      final unit = unitsMap[recipeIng.unitID];

      if (ingredient == null || unit == null) {
        continue;
      }

      // Calculate nutrition for this ingredient
      final nutrition = calculateNutrition(
        quantity: recipeIng.quantity,
        unit: unit,
        ingredient: ingredient,
      );

      // Add to totals
      totalCalories += nutrition.calories;
      totalProtein += nutrition.protein;
      totalCarbs += nutrition.carbohydrates;
      totalFat += nutrition.fat;
      totalFiber += nutrition.fiber;
      totalSugar += nutrition.sugar;
      totalSodium += nutrition.sodium;
    }

    return NutritionInfo(
      calories: totalCalories,
      protein: totalProtein,
      carbohydrates: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
    );
  }

  static NutritionInfo calculateNutritionPerServing({
    required NutritionInfo totalNutrition,
    required int servings,
  }) {
    if (servings <= 0) {
      throw Exception('Servings must be greater than 0');
    }

    return NutritionInfo(
      calories: (totalNutrition.calories / servings).round(),
      protein: totalNutrition.protein / servings,
      carbohydrates: totalNutrition.carbohydrates / servings,
      fat: totalNutrition.fat / servings,
      fiber: totalNutrition.fiber / servings,
      sugar: totalNutrition.sugar / servings,
      sodium: totalNutrition.sodium / servings,
    );
  }


}
