import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_filters.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_nutrition_total.dart';

// Recipe Service Provider
final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

// Stream Provider for Public Recipes (Streams updates in real-time)
final publicRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.watch(recipeServiceProvider).getPublicRecipes();
});

// Stream Provider for Trending Recipes (Based on favoriteCount)
final trendingRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.watch(recipeServiceProvider).getTrendingRecipes();
});

final visiblePublicRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesAsync = ref.watch(publicRecipesProvider);
  final userData = ref.watch(userDataProvider).asData?.value;
  final blocked = List<String>.from(
    userData?['blockedUsers'] ?? const <String>[],
  );

  return recipesAsync.whenData((recipes) {
    return recipes
        .where(
          (recipe) =>
              recipe.ownerId == null || !blocked.contains(recipe.ownerId),
        )
        .toList();
  });
});

final visibleTrendingRecipesProvider = Provider<AsyncValue<List<Recipe>>>((
  ref,
) {
  final recipesAsync = ref.watch(trendingRecipesProvider);
  final userData = ref.watch(userDataProvider).asData?.value;
  final blocked = List<String>.from(
    userData?['blockedUsers'] ?? const <String>[],
  );

  return recipesAsync.whenData((recipes) {
    return recipes
        .where(
          (recipe) =>
              recipe.ownerId == null || !blocked.contains(recipe.ownerId),
        )
        .toList();
  });
});

final followingRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesAsync = ref.watch(visiblePublicRecipesProvider);
  final followingIds =
      ref.watch(userFollowingIdsProvider).asData?.value ?? const <String>[];

  return recipesAsync.whenData((recipes) {
    if (followingIds.isEmpty) return <Recipe>[];
    return recipes
        .where(
          (recipe) =>
              recipe.ownerId != null && followingIds.contains(recipe.ownerId),
        )
        .toList();
  });
});

// Stream Provider for single recipe details by ID
final recipeDetailsProvider = StreamProvider.family<Recipe?, String>((
  ref,
  recipeId,
) {
  return ref.watch(recipeServiceProvider).getRecipeById(recipeId);
});

// Stream Provider for user's own recipes (Requires user ID from auth provider)
final userRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(recipeServiceProvider).getUserRecipes(userId);
});

// Provider for calculating total nutrition information for a recipe (used in recipe details)
final recipeNutritionTotalsProvider = Provider<NutritionInfo Function(Recipe)>((
  ref,
) {
  return (recipe) => calculateRecipeNutritionTotals(recipe);
});

// Provider for calculating nutrition information per serving for a recipe
// Serving Size Calculation: Total Nutrition / Servings
final recipeNutritionPerServingProvider =
    Provider<NutritionInfo Function(Recipe)>((ref) {
      return (recipe) => calculateRecipeNutritionPerServing(recipe);
    });

// For Recipe Filtering - Combines multiple filters (Query and Tags)
// Allergen Filtering is handled separately in the filteredRecipesProvider to ensure it applies to all recipe lists based on user preferences
class RecipeFilterInput {
  RecipeFilterInput({this.query = '', List<String> tags = const <String>[]})
    : tags = List.unmodifiable(tags);

  final String query;
  final List<String> tags;

  @override
  bool operator ==(Object other) {
    return other is RecipeFilterInput &&
        other.query == query &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode => Object.hash(query, Object.hashAll(tags));
}

// Helper function for list equality (since List doesn't override == by default)
bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Provider that combines multiple filters (query, tags) and applies allergen filtering based on user preferences
final filteredRecipesProvider =
    Provider.family<AsyncValue<List<Recipe>>, RecipeFilterInput>((ref, input) {
      final recipesAsync = ref.watch(visiblePublicRecipesProvider);
      final allergensAsync = ref.watch(userAllergenProvider);
      final query = input.query;
      final tags = input.tags;

      return recipesAsync.whenData((recipes) {
        final allergens = allergensAsync.value ?? [];
        var result = recipes;
        result = filterRecipesByAllergens(result, allergens);
        result = filterRecipesByQuery(result, query);
        result = filterByTag(result, tags);
        return result;
      });
    });


//todo: add more specific providers for different recipe categories (e.g. breakfast, lunch, dinner)

//todo: add provider for user's favorite recipes



