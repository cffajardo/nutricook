import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/services/ingredient_service.dart';


// Service Provider
final ingredientServiceProvider = Provider<IngredientService>((ref) {
  return IngredientService();
});


// All Ingredients Cached
final ingredientsProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(ingredientServiceProvider);
  return service.getAllIngredients();
});

// Single ingredient by id
final ingredientByIdProvider =
    FutureProvider.family<Ingredient?, String>((ref, id) async {
  final service = ref.watch(ingredientServiceProvider);
  return service.getIngredientById(id);
});

// Real Time Stream of User's Custom Ingredients 
// to-do: modify to account for custom densities and other user‑specific overrides in the future
final userCustomIngredientsProvider =
    StreamProvider<List<Ingredient>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream<List<Ingredient>>.empty();
  }

  final service = ref.watch(ingredientServiceProvider);
  return service.getUserCustomIngredients(userId);
});


class IngredientFilterInput {
  const IngredientFilterInput({
    this.query = '',
    this.category,
  });

  final String query;
  final String? category;

  @override
  bool operator ==(Object other) {
    return other is IngredientFilterInput &&
        other.query == query &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(query, category);
}

// Filtered Ingredients by Query or Category
final filteredIngredientsProvider = Provider.family<
    AsyncValue<List<Ingredient>>, IngredientFilterInput>((ref, input) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    Iterable<Ingredient> result = ingredients;

    if (input.category != null && input.category!.isNotEmpty) {
      result = result.where((ing) => ing.category == input.category);
    }

    final trimmed = input.query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where(
        (ing) => ing.name.toLowerCase().contains(trimmed),
      );
    }

    return result.toList();
  });
});

// Ingredients grouped by category
final ingredientsByCategoryProvider =
    Provider<AsyncValue<Map<String, List<Ingredient>>>>((ref) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    final map = <String, List<Ingredient>>{};
    for (final ingredient in ingredients) {
      map.putIfAbsent(ingredient.category, () => <Ingredient>[]);
      map[ingredient.category]!.add(ingredient);
    }
    return map;
  });
});

// All Ingredient Categories
// Custom for User owned
final ingredientCategoriesProvider =
    Provider<AsyncValue<List<String>>>((ref) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    final set = <String>{};
    for (final ing in ingredients) {
      set.add(ing.category);
    }

    if (ingredients.any((ing) => ing.ownerId != null)) {
      set.add(IngredientCategory.custom);
    }

    final list = set.toList()..sort();
    return list;
  });
});

// Map for faster lookup (id, ingredient)
// Performance issues still needs to be fixed for recipe editing 
final ingredientsMapProvider =
    Provider<AsyncValue<Map<String, Ingredient>>>((ref) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    return {for (final ing in ingredients) ing.id: ing};
  });
});

