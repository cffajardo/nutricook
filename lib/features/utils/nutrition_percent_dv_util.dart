import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/nutrition/nutrition.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';

/// Helpers for calculating %DV (percent of Recommended Daily Value)
/// for recipes and daily planner totals using Nutrition metadata.

NutritionInfo calculateRecipePercentDV({
  required NutritionInfo nutritionPerServing,
  required Map<String, Nutrition> rdvMap,
}) {
  double percent(String key, double value) {
    final meta = rdvMap[key];
    if (meta == null || meta.recommendedDailyValue <= 0) return 0;
    return NutritionCalculator.calculatePercentDV(
      value: value,
      recommendedDailyValue: meta.recommendedDailyValue,
    );
  }

  return NutritionInfo(
    calories:
        percent('calories', nutritionPerServing.calories.toDouble()).round(),
    protein: percent('protein', nutritionPerServing.protein),
    carbohydrates: percent('carbohydrates', nutritionPerServing.carbohydrates),
    fat: percent('fat', nutritionPerServing.fat),
    fiber: percent('fiber', nutritionPerServing.fiber),
    sugar: percent('sugar', nutritionPerServing.sugar),
    sodium: percent('sodium', nutritionPerServing.sodium),
  );
}

NutritionInfo calculateDailyPlannerPercentDV({
  required NutritionInfo dailyTotal,
  required Map<String, Nutrition> rdvMap,
}) {
  return calculateRecipePercentDV(
    nutritionPerServing: dailyTotal,
    rdvMap: rdvMap,
  );
}

