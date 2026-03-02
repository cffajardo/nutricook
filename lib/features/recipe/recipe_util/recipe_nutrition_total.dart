import 'dart:math';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe/recipe.dart';

NutritionInfo calculateRecipeNutritionTotals(Recipe recipe) {
  double totalCalories = 0;
  double totalCarbohydrates = 0;
  double totalProtein = 0;
  double totalFat = 0;
  double totalFiber = 0;
  double totalSugar = 0;
  double totalSodium = 0;

  for (final ingredient in recipe.ingredients) {
    final per100g = ingredient.nutritionPer100g;
    if (per100g == null) continue;

    final weightG = ingredient.calculatedWeightG ?? ingredient.quantity;
    if (weightG <= 0) continue;

    final factor = weightG / 100.0;

    totalCalories += per100g.calories * factor;
    totalCarbohydrates += per100g.carbohydrates * factor;
    totalProtein += per100g.protein * factor;
    totalFat += per100g.fat * factor;
    totalFiber += per100g.fiber * factor;
    totalSugar += per100g.sugar * factor;
    totalSodium += per100g.sodium * factor;
  }

  return NutritionInfo(
    calories: totalCalories.round(),
    carbohydrates: totalCarbohydrates,
    protein: totalProtein,
    fat: totalFat,
    fiber: totalFiber,
    sugar: totalSugar,
    sodium: totalSodium,
  );
}

/// Calculate nutrition per serving for a recipe.
NutritionInfo calculateRecipeNutritionPerServing(Recipe recipe) {
  final totals = calculateRecipeNutritionTotals(recipe);
  final servings = max(recipe.servings, 1); // Avoid division by zero

  return NutritionInfo(
    calories: (totals.calories / servings).round(),
    carbohydrates: totals.carbohydrates / servings,
    protein: totals.protein / servings,
    fat: totals.fat / servings,
    fiber: totals.fiber / servings,
    sugar: totals.sugar / servings,
    sodium: totals.sodium / servings,
  );
}