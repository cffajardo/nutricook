import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
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
  return ref.watch(recipeServiceProvider).getTrendingRecipes(limit: 5);
});

final visiblePublicRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesAsync = ref.watch(publicRecipesProvider);
  final userData = ref.watch(userDataProvider).asData?.value;
  final preferences = ref.watch(userPreferencesProvider).asData?.value;
  final ingredientsMap = ref.watch(ingredientsMapProvider).asData?.value;
  final blocked = List<String>.from(
    userData?['blockedUsers'] ?? const <String>[],
  );
  final allergens = preferences?.allergens ?? const <String>[];
  final shouldShowAllergens = preferences?.showRecipesWithAllergens ?? true;

  return recipesAsync.whenData((recipes) {
    var result = recipes
        .where(
          (recipe) =>
              recipe.ownerId == null || !blocked.contains(recipe.ownerId),
        )
        .toList();

    if (!shouldShowAllergens) {
      result = filterRecipesByAllergens(
        result,
        allergens,
        ingredientsMap: ingredientsMap,
      );
    }

    return result;
  });
});

final visibleTrendingRecipesProvider = Provider<AsyncValue<List<Recipe>>>((
  ref,
) {
  final recipesAsync = ref.watch(trendingRecipesProvider);
  final userData = ref.watch(userDataProvider).asData?.value;
  final preferences = ref.watch(userPreferencesProvider).asData?.value;
  final ingredientsMap = ref.watch(ingredientsMapProvider).asData?.value;
  final blocked = List<String>.from(
    userData?['blockedUsers'] ?? const <String>[],
  );
  final allergens = preferences?.allergens ?? const <String>[];
  final shouldShowAllergens = preferences?.showRecipesWithAllergens ?? true;

  return recipesAsync.whenData((recipes) {
    var result = recipes
        .where(
          (recipe) =>
              recipe.ownerId == null || !blocked.contains(recipe.ownerId),
        )
        .toList();

    if (!shouldShowAllergens) {
      result = filterRecipesByAllergens(
        result,
        allergens,
        ingredientsMap: ingredientsMap,
      );
    }

    if (result.length > 5) result = result.sublist(0, 5);
    return result;
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

final recipeNutritionPerServingProvider =
    Provider<NutritionInfo Function(Recipe)>((ref) {
      return (recipe) => calculateRecipeNutritionPerServing(recipe);
    });

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

class RecipeAdvancedFilters {
  const RecipeAdvancedFilters({
    this.maxCalories = 500,
    this.maxCarbs = 50,
    this.maxFats = 30,
    this.maxProtein = 40,
    this.maxSugar = 20,
    this.maxFiber = 10,
    this.maxSodium = 500,
    this.useCaloriesFilter = false,
    this.useCarbsFilter = false,
    this.useFatsFilter = false,
    this.useProteinFilter = false,
    this.useSugarFilter = false,
    this.useFiberFilter = false,
    this.useSodiumFilter = false,
    this.maxCookTimeMinutes = 30,
    this.includeTags = const <String>[],
    this.excludeTags = const <String>[],
  });

  final double maxCalories;
  final double maxCarbs;
  final double maxFats;
  final double maxProtein;
  final double maxSugar;
  final double maxFiber;
  final double maxSodium;
  final bool useCaloriesFilter;
  final bool useCarbsFilter;
  final bool useFatsFilter;
  final bool useProteinFilter;
  final bool useSugarFilter;
  final bool useFiberFilter;
  final bool useSodiumFilter;
  final double maxCookTimeMinutes;
  final List<String> includeTags;
  final List<String> excludeTags;

  RecipeAdvancedFilters copyWith({
    double? maxCalories,
    double? maxCarbs,
    double? maxFats,
    double? maxProtein,
    double? maxSugar,
    double? maxFiber,
    double? maxSodium,
    bool? useCaloriesFilter,
    bool? useCarbsFilter,
    bool? useFatsFilter,
    bool? useProteinFilter,
    bool? useSugarFilter,
    bool? useFiberFilter,
    bool? useSodiumFilter,
    double? maxCookTimeMinutes,
    List<String>? includeTags,
    List<String>? excludeTags,
  }) {
    return RecipeAdvancedFilters(
      maxCalories: maxCalories ?? this.maxCalories,
      maxCarbs: maxCarbs ?? this.maxCarbs,
      maxFats: maxFats ?? this.maxFats,
      maxProtein: maxProtein ?? this.maxProtein,
      maxSugar: maxSugar ?? this.maxSugar,
      maxFiber: maxFiber ?? this.maxFiber,
      maxSodium: maxSodium ?? this.maxSodium,
      useCaloriesFilter: useCaloriesFilter ?? this.useCaloriesFilter,
      useCarbsFilter: useCarbsFilter ?? this.useCarbsFilter,
      useFatsFilter: useFatsFilter ?? this.useFatsFilter,
      useProteinFilter: useProteinFilter ?? this.useProteinFilter,
      useSugarFilter: useSugarFilter ?? this.useSugarFilter,
      useFiberFilter: useFiberFilter ?? this.useFiberFilter,
      useSodiumFilter: useSodiumFilter ?? this.useSodiumFilter,
      maxCookTimeMinutes: maxCookTimeMinutes ?? this.maxCookTimeMinutes,
      includeTags: includeTags ?? this.includeTags,
      excludeTags: excludeTags ?? this.excludeTags,
    );
  }

  bool get hasAnyTagFilters => includeTags.isNotEmpty || excludeTags.isNotEmpty;

  bool get hasAnyFilters {
    return useCaloriesFilter ||
        useCarbsFilter ||
        useFatsFilter ||
        useProteinFilter ||
        useSugarFilter ||
        useFiberFilter ||
        useSodiumFilter ||
        maxCookTimeMinutes < defaults.maxCookTimeMinutes ||
        hasAnyTagFilters;
  }

  static const RecipeAdvancedFilters defaults = RecipeAdvancedFilters(
    maxCalories: 2000,
    maxCarbs: 200,
    maxFats: 100,
    maxProtein: 150,
    maxSugar: 100,
    maxFiber: 50,
    maxSodium: 2500,
    maxCookTimeMinutes: 180,
  );
}

class RecipeAdvancedFiltersNotifier extends Notifier<RecipeAdvancedFilters> {
  @override
  RecipeAdvancedFilters build() => RecipeAdvancedFilters.defaults;

  void apply(RecipeAdvancedFilters next) {
    state = next;
  }

  void reset() {
    state = RecipeAdvancedFilters.defaults;
  }
}

final recipeAdvancedFiltersProvider =
    NotifierProvider<RecipeAdvancedFiltersNotifier, RecipeAdvancedFilters>(
      RecipeAdvancedFiltersNotifier.new,
    );

// Helper function for list equality (since List doesn't override == by default)
bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Provider that combines query and tag filtering for public recipe discovery.
final filteredRecipesProvider =
    Provider.family<AsyncValue<List<Recipe>>, RecipeFilterInput>((ref, input) {
      final recipesAsync = ref.watch(visiblePublicRecipesProvider);
      final query = input.query;
      final tags = input.tags;
      final filters = ref.watch(recipeAdvancedFiltersProvider);

      return recipesAsync.whenData((recipes) {
        var result = recipes;
        result = filterRecipesByQuery(result, query);
        result = applyAdvancedRecipeFilters(
          result,
          filters,
          forcedIncludeTags: tags,
        );

        return result;
      });
    });

List<Recipe> applyAdvancedRecipeFilters(
  List<Recipe> recipes,
  RecipeAdvancedFilters filters, {
  List<String> forcedIncludeTags = const <String>[],
}) {
  var result = recipes;

  result = filterByTag(
    result,
    <String>{...forcedIncludeTags, ...filters.includeTags}.toList(),
  );

  if (filters.excludeTags.isNotEmpty) {
    final excluded = filters.excludeTags
        .map((tag) => tag.toLowerCase())
        .toSet();
    result = result.where((recipe) {
      return !recipe.tags.any((tag) => excluded.contains(tag.toLowerCase()));
    }).toList();
  }

  return result.where((recipe) {
    final nutrition = _resolveNutritionPerServing(recipe);
    final totalTime = recipe.prepTime + recipe.cookTime;
    final hasNutritionFilters =
        filters.useCaloriesFilter ||
        filters.useCarbsFilter ||
        filters.useFatsFilter ||
        filters.useProteinFilter ||
        filters.useSugarFilter ||
        filters.useFiberFilter ||
        filters.useSodiumFilter;

    if (totalTime > filters.maxCookTimeMinutes) {
      return false;
    }

    if (nutrition == null) {
      return !hasNutritionFilters;
    }

    if (filters.useCaloriesFilter && nutrition.calories > filters.maxCalories) {
      return false;
    }
    if (filters.useCarbsFilter && nutrition.carbohydrates > filters.maxCarbs) {
      return false;
    }
    if (filters.useFatsFilter && nutrition.fat > filters.maxFats) {
      return false;
    }
    if (filters.useProteinFilter && nutrition.protein > filters.maxProtein) {
      return false;
    }
    if (filters.useSugarFilter && nutrition.sugar > filters.maxSugar) {
      return false;
    }
    if (filters.useFiberFilter && nutrition.fiber > filters.maxFiber) {
      return false;
    }
    if (filters.useSodiumFilter && nutrition.sodium > filters.maxSodium) {
      return false;
    }

    return true;
  }).toList();
}

NutritionInfo? _resolveNutritionPerServing(Recipe recipe) {
  final perServing = recipe.nutritionPerServing;
  if (perServing != null) {
    return perServing;
  }

  final total = recipe.nutritionTotal;
  if (total == null || recipe.servings <= 0) {
    return null;
  }

  return NutritionInfo(
    calories: (total.calories / recipe.servings).round(),
    carbohydrates: total.carbohydrates / recipe.servings,
    protein: total.protein / recipe.servings,
    fat: total.fat / recipe.servings,
    fiber: total.fiber / recipe.servings,
    sugar: total.sugar / recipe.servings,
    sodium: total.sodium / recipe.servings,
  );
}

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

// Provider: list of recipes the current user has favorited (derived from the
// already-streamed public + own recipes; no extra Firestore read needed).
final userFavoriteRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const AsyncValue.data(<Recipe>[]);

  final publicAsync = ref.watch(publicRecipesProvider);
  final ownAsync = ref.watch(userRecipesProvider);

  if (publicAsync is AsyncLoading || ownAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }
  if (publicAsync is AsyncError) return publicAsync;
  if (ownAsync is AsyncError) return ownAsync;

  final allRecipes = <Recipe>{
    ...publicAsync.asData?.value ?? <Recipe>[],
    ...ownAsync.asData?.value ?? <Recipe>[],
  };

  return AsyncValue.data(
    allRecipes.where((r) => r.favoritedBy.contains(userId)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );
});

// Provider: is a specific recipe favorited by the current user?
final isRecipeFavoritedProvider =
    Provider.family<bool, String>((ref, recipeId) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) return false;

      // Check from the already-streamed single recipe details.
      final recipeAsync = ref.watch(recipeDetailsProvider(recipeId));
      return recipeAsync.asData?.value?.favoritedBy.contains(userId) ?? false;
    });

// Notifier: toggle favorite (add or remove).
class ToggleFavoriteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle(String recipeId) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return;

    final isFavorited = ref.read(isRecipeFavoritedProvider(recipeId));
    final service = ref.read(recipeServiceProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (isFavorited) {
        await service.removeFavorite(recipeId, userId);
      } else {
        await service.addFavorite(recipeId, userId);
      }
    });
  }
}

final toggleFavoriteProvider =
    AsyncNotifierProvider<ToggleFavoriteNotifier, void>(
      ToggleFavoriteNotifier.new,
    );

