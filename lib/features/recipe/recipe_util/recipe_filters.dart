import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/recipe/recipe.dart';

List<Recipe> filterRecipesByAllergens(
  List<Recipe> recipes,
  List<String> userAllergens, {
  Map<String, Ingredient>? ingredientsMap,
}) {
  if (userAllergens.isEmpty) {
    return recipes;
  }

  return recipes.where((recipe) {
    return recipe.ingredients.every((ingredient) {
      return !matchesRecipeIngredientAllergen(
        ingredient: ingredient,
        allergenEntries: userAllergens,
        ingredientCategory: ingredientsMap?[ingredient.ingredientID]?.category,
      );
    });
  }).toList();
}

List<Recipe> filterRecipesByQuery(List<Recipe> recipes, String query) {
  if (query.isEmpty) return recipes;
  final lowerQuery = query.toLowerCase();
  return recipes.where((recipe) {
    return recipe.name.toLowerCase().contains(lowerQuery) ||
        recipe.description.toLowerCase().contains(lowerQuery) ||
        recipe.ingredients.any(
          (ingredient) => ingredient.name.toLowerCase().contains(lowerQuery),
        ) ||
        recipe.steps.any(
          (step) => step.instruction.toLowerCase().contains(lowerQuery),
        );
  }).toList();
}

List<Recipe> filterByTag(List<Recipe> recipes, List<String> tags) {
  if (tags.isEmpty) return recipes;
  final lowerTags = tags.map((tag) => tag.toLowerCase()).toList();
  return recipes.where((recipe) {
    return recipe.tags.any((t) => lowerTags.contains(t.toLowerCase()));
  }).toList();
}
