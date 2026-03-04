import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/services/ingredient_service.dart';

// ---------------------------------------------------------------------------
// Example usage
// ---------------------------------------------------------------------------
//
// class IngredientListScreen extends ConsumerStatefulWidget {
//   const IngredientListScreen({super.key});
//
//   @override
//   ConsumerState<IngredientListScreen> createState() =>
//       _IngredientListScreenState();
// }
//
// class _IngredientListScreenState
//     extends ConsumerState<IngredientListScreen> {
//   String _query = '';
//   String? _category;
//
//   @override
//   Widget build(BuildContext context) {
//     // 1) Load all ingredients (cached FutureProvider)
//     final allAsync = ref.watch(ingredientsProvider);
//
//     // 2) Apply filters using a family Provider
//     final filteredAsync = ref.watch(
//       filteredIngredientsProvider(
//         IngredientFilterInput(query: _query, category: _category),
//       ),
//     );
//
//     return Column(
//       children: [
//         TextField(
//           onChanged: (value) => setState(() => _query = value),
//         ),
//         filteredAsync.when(
//           loading: () => const CircularProgressIndicator(),
//           error: (e, _) => Text('Error: $e'),
//           data: (items) => Expanded(
//             child: ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (_, index) => Text(items[index].name),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// Creating a custom ingredient:
//
// final service = ref.read(ingredientServiceProvider);
// final isTaken = await service.isIngredientNameTaken(draft.name);
// if (!isTaken) {
//   await service.createIngredient(draft);
// }
//
// Note: there is deliberately **no StateProvider** here for search/filter
// state. The widget holds its own local state and passes it into the
// family providers, in line with using StatefulWidget for forms.

// ---------------------------------------------------------------------------
// Service provider
// ---------------------------------------------------------------------------

final ingredientServiceProvider = Provider<IngredientService>((ref) {
  return IngredientService();
});

// ---------------------------------------------------------------------------
// Future / Stream providers
// ---------------------------------------------------------------------------

/// All ingredients (seeded + custom) as a cached FutureProvider.
final ingredientsProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(ingredientServiceProvider);
  return service.getAllIngredients();
});

/// Single ingredient by id.
final ingredientByIdProvider =
    FutureProvider.family<Ingredient?, String>((ref, id) async {
  final service = ref.watch(ingredientServiceProvider);
  return service.getIngredientById(id);
});

/// User's custom ingredients only (real‑time).
final userCustomIngredientsProvider =
    StreamProvider<List<Ingredient>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream<List<Ingredient>>.empty();
  }

  final service = ref.watch(ingredientServiceProvider);
  return service.getUserCustomIngredients(userId);
});

// ---------------------------------------------------------------------------
// Filter input and computed providers
// ---------------------------------------------------------------------------

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

/// Ingredients filtered by query + category, using client‑side filtering.
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

/// Ingredients grouped by category.
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

/// All available ingredient categories based on current ingredients.
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

/// Ingredients map for quick lookup: id -> Ingredient.
final ingredientsMapProvider =
    Provider<AsyncValue<Map<String, Ingredient>>>((ref) {
  final ingredientsAsync = ref.watch(ingredientsProvider);

  return ingredientsAsync.whenData((ingredients) {
    return {for (final ing in ingredients) ing.id: ing};
  });
});

