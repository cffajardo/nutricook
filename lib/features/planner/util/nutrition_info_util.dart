import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';


// Calculates the total nutrition information for a list of planner items
NutritionInfo calculatePlannerNutrition({
  required List<PlannerItem> plannerItems,
}) {
  return plannerItems.fold( // fold - used to accumulate values through a list with an initial value
    const NutritionInfo(
      calories: 0,
      carbohydrates: 0,
      protein: 0,
      fat: 0,
      fiber: 0,
      sugar: 0,
      sodium: 0,
    ),
    (total, item) {
      final n = item.nutritionPerServing;
      if (n == null) return total;
      final scale = item.servingMultiplier;
      return total.copyWith( //
        calories: total.calories + (n.calories * scale).round(),
        carbohydrates: total.carbohydrates + n.carbohydrates * scale,
        protein: total.protein + n.protein * scale,
        fat: total.fat + n.fat * scale,
        fiber: total.fiber + n.fiber * scale,
        sugar: total.sugar + n.sugar * scale,
        sodium: total.sodium + n.sodium * scale,
      );
    },
  );
}