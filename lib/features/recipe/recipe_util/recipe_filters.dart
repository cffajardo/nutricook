import 'package:nutricook/models/recipe/recipe.dart';

// Filter recipes based on user allergens
List<Recipe> filterRecipesByAllergens(
  List<Recipe> recipes,
  List<String> userAllergens,
) {
  if (userAllergens.isEmpty) {
    return recipes;
  }

  return recipes.where((recipe) {
    return recipe.ingredients.every((ingredient) {
      return !userAllergens.contains(ingredient.ingredientID.toLowerCase());
    });
  }).toList();
}

// Filter Recipes by query (Mostly names and ingredients for now)
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

// Filter recipes by tags (Declared in constants.dart)
List<Recipe> filterByTag(List<Recipe> recipes, List<String> tags) {
  if (tags.isEmpty) return recipes;
  final lowerTags = tags.map((tag) => tag.toLowerCase()).toList();
  return recipes.where((recipe) {
    return recipe.tags.any((t) => lowerTags.contains(t.toLowerCase()));
  }).toList();
}
