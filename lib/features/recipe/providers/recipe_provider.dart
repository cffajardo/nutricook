import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';
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

final userRecipesByOwnerProvider = StreamProvider.family<List<Recipe>, String>((
  ref,
  ownerId,
) {
  return ref.watch(recipeServiceProvider).getUserRecipes(ownerId);
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
        final allergens = allergensAsync.asData?.value ?? [];
        var result = recipes;
        result = filterRecipesByAllergens(result, allergens);
        result = filterRecipesByQuery(result, query);
        result = filterByTag(result, tags);
        return result;
      });
    });

class RecipeCreationState {
  const RecipeCreationState({
    this.name = '',
    this.description = '',
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 1,
    this.isPublic = true,
    this.tags = const <String>[],
    this.ingredients = const <RecipeIngredient>[],
    this.steps = const <RecipeStep>[],
  });

  final String name;
  final String description;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final bool isPublic;
  final List<String> tags;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  RecipeCreationState copyWith({
    String? name,
    String? description,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    bool? isPublic,
    List<String>? tags,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
  }) {
    return RecipeCreationState(
      name: name ?? this.name,
      description: description ?? this.description,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }

  bool get canProceedFromAbout =>
      name.trim().isNotEmpty && description.trim().isNotEmpty;
}

class RecipeCreationNotifier extends Notifier<RecipeCreationState> {
  @override
  RecipeCreationState build() {
    return const RecipeCreationState();
  }

  void updateAbout({
    required String name,
    required String description,
    required int prepTimeMinutes,
    required int cookTimeMinutes,
    required int servings,
    required bool isPublic,
    required List<String> tags,
  }) {
    state = state.copyWith(
      name: name,
      description: description,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      isPublic: isPublic,
      tags: List<String>.unmodifiable(tags),
    );
  }

  void addIngredient(RecipeIngredient ingredient) {
    state = state.copyWith(
      ingredients: <RecipeIngredient>[...state.ingredients, ingredient],
    );
  }

  void updateIngredient(int index, RecipeIngredient ingredient) {
    if (index < 0 || index >= state.ingredients.length) return;
    final next = <RecipeIngredient>[...state.ingredients];
    next[index] = ingredient;
    state = state.copyWith(ingredients: next);
  }

  void removeIngredient(int index) {
    if (index < 0 || index >= state.ingredients.length) return;
    final next = <RecipeIngredient>[...state.ingredients]..removeAt(index);
    state = state.copyWith(ingredients: next);
  }

  void addStep(RecipeStep step) {
    state = state.copyWith(steps: <RecipeStep>[...state.steps, step]);
  }

  void updateStep(int index, RecipeStep step) {
    if (index < 0 || index >= state.steps.length) return;
    final next = <RecipeStep>[...state.steps];
    next[index] = step;
    state = state.copyWith(steps: next);
  }

  void removeStep(int index) {
    if (index < 0 || index >= state.steps.length) return;
    final next = <RecipeStep>[...state.steps]..removeAt(index);
    state = state.copyWith(steps: next);
  }

  void clear() {
    state = const RecipeCreationState();
  }
}

final recipeCreationProvider =
    NotifierProvider.autoDispose<RecipeCreationNotifier, RecipeCreationState>(
      RecipeCreationNotifier.new,
    );


//todo: add more specific providers for different recipe categories (e.g. breakfast, lunch, dinner)

//todo: add provider for user's favorite recipes



