import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/nutrition/nutrition.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';

//Helper function to calculate %DV for a recipe based on nutrition per serving and RDV (Recommended Daily Value) 

NutritionInfo calculateRecipePercentDV({
  required NutritionInfo nutritionPerServing,
  required Map<String, Nutrition> rdvMap,
}) {
  
  double percent(String key, double value) {
    final data = rdvMap[key];
    if (data == null || data.recommendedDailyValue <= 0) return 0;
    return NutritionCalculator.calculatePercentDV(
      value: value,
      recommendedDailyValue: data.recommendedDailyValue,
    );
  }

  return NutritionInfo(
    calories:percent('calories', nutritionPerServing.calories.toDouble()).round(),
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

