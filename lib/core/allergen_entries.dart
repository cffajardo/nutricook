import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/recipe/recipe.dart';

const String allergenIngredientPrefix = 'ingredient:';
const String allergenCategoryPrefix = 'category:';

String normalizeAllergenEntry(String entry) => entry.trim().toLowerCase();

String allergenIngredientEntry(String ingredientId) =>
    '$allergenIngredientPrefix${normalizeAllergenEntry(ingredientId)}';

String allergenCategoryEntry(String category) =>
    '$allergenCategoryPrefix${normalizeAllergenEntry(category)}';

bool isCategoryAllergenEntry(String entry) =>
    normalizeAllergenEntry(entry).startsWith(allergenCategoryPrefix);

bool isIngredientAllergenEntry(String entry) =>
    normalizeAllergenEntry(entry).startsWith(allergenIngredientPrefix);

String? parseAllergenCategory(String entry) {
  final normalized = normalizeAllergenEntry(entry);
  if (!normalized.startsWith(allergenCategoryPrefix)) {
    return null;
  }
  return normalized.substring(allergenCategoryPrefix.length);
}

String? parseAllergenIngredientId(String entry) {
  final normalized = normalizeAllergenEntry(entry);
  if (normalized.startsWith(allergenCategoryPrefix)) {
    return null;
  }
  if (normalized.startsWith(allergenIngredientPrefix)) {
    return normalized.substring(allergenIngredientPrefix.length);
  }
  return normalized;
}

bool matchesRecipeIngredientAllergen({
  required RecipeIngredient ingredient,
  required Iterable<String> allergenEntries,
  String? ingredientCategory,
  Map<String, Ingredient>? ingredientsMap,
}) {
  final normalizedEntries = allergenEntries
      .map(normalizeAllergenEntry)
      .where((entry) => entry.isNotEmpty)
      .toSet()
    ..addAll(
      _expandAllergenEntriesWithIngredientNames(
        allergenEntries: allergenEntries,
        ingredientsMap: ingredientsMap,
      ),
    );

  if (normalizedEntries.isEmpty) {
    return false;
  }

  final normalizedIngredientId = normalizeAllergenEntry(ingredient.ingredientID);
  final normalizedIngredientName = normalizeAllergenEntry(ingredient.name);
  final normalizedCategory = ingredientCategory == null
      ? null
      : normalizeAllergenEntry(ingredientCategory);

  return normalizedEntries.contains(normalizedIngredientId) ||
      normalizedEntries.contains(normalizedIngredientName) ||
      normalizedEntries.contains(allergenIngredientEntry(normalizedIngredientId)) ||
      (normalizedCategory != null &&
          normalizedEntries.contains(allergenCategoryEntry(normalizedCategory)));
}

List<String> matchedRecipeAllergenLabels({
  required Recipe recipe,
  required Iterable<String> allergenEntries,
  Map<String, Ingredient>? ingredientsMap,
}) {
  final labelsByKey = <String, String>{};

  for (final ingredient in recipe.ingredients) {
    final matches = matchesRecipeIngredientAllergen(
      ingredient: ingredient,
      allergenEntries: allergenEntries,
      ingredientCategory: ingredientsMap?[ingredient.ingredientID]?.category,
      ingredientsMap: ingredientsMap,
    );

    if (!matches) {
      continue;
    }

    final label = ingredient.name.trim();
    if (label.isEmpty) {
      continue;
    }
    labelsByKey.putIfAbsent(normalizeAllergenEntry(label), () => label);
  }

  final labels = labelsByKey.values.toList()..sort();
  return labels;
}

Set<String> _expandAllergenEntriesWithIngredientNames({
  required Iterable<String> allergenEntries,
  Map<String, Ingredient>? ingredientsMap,
}) {
  if (ingredientsMap == null || ingredientsMap.isEmpty) {
    return const <String>{};
  }

  final ingredientLookup = <String, Ingredient>{
    for (final ingredient in ingredientsMap.values)
      normalizeAllergenEntry(ingredient.id): ingredient,
  };

  final expanded = <String>{};
  for (final entry in allergenEntries) {
    final ingredientId = parseAllergenIngredientId(entry);
    if (ingredientId == null) {
      continue;
    }

    final ingredient = ingredientLookup[normalizeAllergenEntry(ingredientId)];
    if (ingredient == null) {
      continue;
    }

    expanded.add(normalizeAllergenEntry(ingredient.name));
  }

  return expanded;
}