import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/services/ingredient_service.dart';


final ingredientServiceProvider = Provider<IngredientService>((ref) {
  return IngredientService();
});


final ingredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  final service = ref.watch(ingredientServiceProvider);
  return service.getAllIngredientsStream();
});

final ingredientByIdProvider =
    FutureProvider.family<Ingredient?, String>((ref, id) async {
  final service = ref.watch(ingredientServiceProvider);
  return service.getIngredientById(id);
});

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

final filteredIngredientsProvider = Provider.family<
    AsyncValue<List<Ingredient>>, IngredientFilterInput>((ref, input) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    Iterable<Ingredient> result = ingredients;

    if (input.category != null && input.category!.isNotEmpty) {
      result = result.where((ing) => (ing.category ?? '') == input.category);
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

final ingredientsByCategoryProvider =
    Provider<AsyncValue<Map<String, List<Ingredient>>>>((ref) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    final map = <String, List<Ingredient>>{};
    for (final ingredient in ingredients) {
      final category = ingredient.category ?? 'Uncategorized';
      map.putIfAbsent(category, () => <Ingredient>[]);
      map[category]!.add(ingredient);
    }
    return map;
  });
});

final ingredientCategoriesProvider =
    Provider<AsyncValue<List<String>>>((ref) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    final set = <String>{};
    for (final ing in ingredients) {
      final category = ing.category;
      set.add(category);
    }

    if (ingredients.any((ing) => ing.ownerId != null)) {
      set.add(IngredientCategory.custom);
    }

    final list = set.toList()..sort();
    return list;
  });
});

// Map for faster lookup (id, ingredient)
final ingredientsMapProvider =
    Provider<AsyncValue<Map<String, Ingredient>>>((ref) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    return {for (final ing in ingredients) ing.id: ing};
  });
});

