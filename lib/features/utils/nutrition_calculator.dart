import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';

/// Utility class for converting units and calculating nutrition
/// 
/// Handles three types of conversions:
/// 1. Weight units (g, kg, oz, lb) → grams (direct conversion)
/// 2. Volume units (ml, L, cup, tsp, tbsp) → grams (requires densityGPerMl)
/// 3. Count units (piece, clove, slice) → grams (requires avgWeightG)
class NutritionCalculator {
  /// Convert ingredient quantity + unit to grams
  /// 
  /// This is the core conversion function that uses:
  /// - unit.multiplier for weight/volume conversions
  /// - ingredient.densityGPerMl for volume→weight
  /// - ingredient.avgWeightG for count→weight
  /// 
  /// Examples:
  /// - 500g chicken → 500g (direct)
  /// - 2 cups milk → 2×240ml×1.03g/ml = 494.4g
  /// - 3 eggs → 3×50g = 150g
  static double convertToGrams({
    required double quantity,
    required Unit unit,
    required Ingredient ingredient,
  }) {
    switch (unit.type) {
      // ========================================
      // WEIGHT UNITS - Direct conversion
      // ========================================
      case 'weight':
        // Convert to grams using unit multiplier
        // Example: 2 kg × 1000 = 2000g
        return quantity * unit.multiplier;

      // ========================================
      // VOLUME UNITS - Need density
      // ========================================
      case 'volume':
        if (ingredient.densityGPerMl == null) {
          throw Exception(
            'Cannot convert volume to weight: ${ingredient.name} is missing densityGPerMl. '
            'Please add density data to this ingredient.',
          );
        }
        
        // Step 1: Convert to ml using unit multiplier
        // Example: 2 cups × 240 = 480ml
        final volumeInMl = quantity * unit.multiplier;
        
        // Step 2: Convert ml to grams using density
        // Example: 480ml × 0.92 g/ml = 441.6g
        return volumeInMl * ingredient.densityGPerMl!;

      // ========================================
      // COUNT UNITS - Need average weight
      // ========================================
      case 'count':
        if (ingredient.avgWeightG == null) {
          throw Exception(
            'Cannot convert count to weight: ${ingredient.name} is missing avgWeightG. '
            'Please add average weight data to this ingredient.',
          );
        }
        
        // Convert pieces to grams using average weight
        // Example: 3 eggs × 50g/egg = 150g
        return quantity * ingredient.avgWeightG!;

      // ========================================
      // ENERGY UNITS - Not supported for weight conversion
      // ========================================
      case 'energy':
        throw Exception(
          'Cannot convert energy units (kcal) to weight. '
          'Energy units are only for nutrition display.',
        );

      default:
        throw Exception('Unknown unit type: ${unit.type}');
    }
  }

  /// Calculate nutrition for a specific quantity + unit of an ingredient
  /// 
  /// Returns NutritionInfo scaled to the actual quantity.
  /// 
  /// Example:
  /// - Ingredient: Chicken breast (165 cal per 100g)
  /// - Quantity: 200g
  /// - Result: 330 calories (200/100 × 165)
  static NutritionInfo calculateNutrition({
    required double quantity,
    required Unit unit,
    required Ingredient ingredient,
  }) {
    if (ingredient.nutritionPer100g == null) {
      // Return zero nutrition if no data available
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

  /// Calculate total nutrition for a recipe
  /// 
  /// Sums up nutrition from all RecipeIngredients.
  /// 
  /// Example:
  /// Recipe: Scrambled Eggs
  /// - 3 eggs: 232.5 cal
  /// - 2 tbsp butter: 195.7 cal
  /// - 1/4 cup milk: 37.7 cal
  /// Total: 465.9 calories
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

  /// Scale recipe nutrition for different serving sizes
  static NutritionInfo scaleNutritionToServingSizes({
    required NutritionInfo nutrition,
    required double servingMultiplier,
  }) {
    return NutritionInfo(
      calories: (nutrition.calories * servingMultiplier).round(),
      protein: nutrition.protein * servingMultiplier,
      carbohydrates: nutrition.carbohydrates * servingMultiplier,
      fat: nutrition.fat * servingMultiplier,
      fiber: nutrition.fiber * servingMultiplier,
      sugar: nutrition.sugar * servingMultiplier,
      sodium: nutrition.sodium * servingMultiplier,
    );
  }

  /// Format nutrition value for display
  static String formatNutritionValue(double value, String nutrientType) {
    switch (nutrientType) {
      case 'calories':
      case 'sodium':
        return value.toStringAsFixed(0);
      default:
        return value.toStringAsFixed(1);
    }
  }

  /// Calculate percentage of daily recommended value
  static double calculatePercentDV({
    required double value,
    required double recommendedDailyValue,
  }) {
    if (recommendedDailyValue <= 0) return 0;
    return (value / recommendedDailyValue) * 100;
  }
}