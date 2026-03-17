import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/services/collection_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_filters.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_nutrition_total.dart';
import 'package:nutricook/core/constants.dart';

// Recipe Service Provider
final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

// Collection Service Provider
final collectionServiceProvider = Provider<CollectionService>((ref) {
  return CollectionService();
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

// Provider for the "Custom" category: includes the current user's own recipes
// (public and private) plus public recipes by other users, excluding any
// recipes authored by the current user's own public recipes (avoid duplication)
// and recipes from the system account "NutriCook".
final userCustomRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final publicAsync = ref.watch(visiblePublicRecipesProvider);
  final ownAsync = ref.watch(userRecipesProvider);
  final currentUserId = ref.watch(currentUserIdProvider);

  if (publicAsync is AsyncLoading || ownAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }
  if (publicAsync is AsyncError) return publicAsync;
  if (ownAsync is AsyncError) return ownAsync;

  final public = publicAsync.asData?.value ?? <Recipe>[];
  final own = ownAsync.asData?.value ?? <Recipe>[];

  // Filter public recipes: exclude any authored by the current user (to avoid
  // duplication). Full NutriCook filtering will be added once we confirm
  // recipes show up in the Custom category.
  final filteredPublic = public.where((r) {
    final ownerId = r.ownerId;
    if (ownerId == null || ownerId.isEmpty) return true;
    // Exclude current user's public recipes (already in own)
    if (ownerId == currentUserId) return false;
    return true;
  }).toList();

  final merged = <Recipe>[...own, ...filteredPublic];
  merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return AsyncValue.data(merged);
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
    required this.maxCalories,
    required this.maxCarbs,
    required this.maxFats,
    required this.maxProtein,
    required this.maxSugar,
    required this.maxFiber,
    required this.maxSodium,
    required this.useCaloriesFilter,
    required this.useCarbsFilter,
    required this.useFatsFilter,
    required this.useProteinFilter,
    required this.useSugarFilter,
    required this.useFiberFilter,
    required this.useSodiumFilter,
    required this.caloriesComparisonMode,
    required this.carbsComparisonMode,
    required this.fatsComparisonMode,
    required this.proteinComparisonMode,
    required this.sugarComparisonMode,
    required this.fiberComparisonMode,
    required this.sodiumComparisonMode,
    required this.maxCookTimeMinutes,
    required this.includeTags,
    required this.excludeTags,
    required this.userCreatedOnly,
    required this.createdByOthersOnly,
    required this.followingOnly,
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
  final bool caloriesComparisonMode;
  final bool carbsComparisonMode;
  final bool fatsComparisonMode;
  final bool proteinComparisonMode;
  final bool sugarComparisonMode;
  final bool fiberComparisonMode;
  final bool sodiumComparisonMode;
  final double maxCookTimeMinutes;
  final List<String> includeTags;
  final List<String> excludeTags;
  final bool userCreatedOnly;
  final bool createdByOthersOnly;
  final bool followingOnly;

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
    bool? caloriesComparisonMode,
    bool? carbsComparisonMode,
    bool? fatsComparisonMode,
    bool? proteinComparisonMode,
    bool? sugarComparisonMode,
    bool? fiberComparisonMode,
    bool? sodiumComparisonMode,
    double? maxCookTimeMinutes,
    List<String>? includeTags,
    List<String>? excludeTags,
    bool? userCreatedOnly,
    bool? createdByOthersOnly,
    bool? followingOnly,
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
      caloriesComparisonMode: caloriesComparisonMode ?? this.caloriesComparisonMode,
      carbsComparisonMode: carbsComparisonMode ?? this.carbsComparisonMode,
      fatsComparisonMode: fatsComparisonMode ?? this.fatsComparisonMode,
      proteinComparisonMode: proteinComparisonMode ?? this.proteinComparisonMode,
      sugarComparisonMode: sugarComparisonMode ?? this.sugarComparisonMode,
      fiberComparisonMode: fiberComparisonMode ?? this.fiberComparisonMode,
      sodiumComparisonMode: sodiumComparisonMode ?? this.sodiumComparisonMode,
      maxCookTimeMinutes: maxCookTimeMinutes ?? this.maxCookTimeMinutes,
      includeTags: includeTags ?? this.includeTags,
      excludeTags: excludeTags ?? this.excludeTags,
      userCreatedOnly: userCreatedOnly ?? this.userCreatedOnly,
      createdByOthersOnly: createdByOthersOnly ?? this.createdByOthersOnly,
      followingOnly: followingOnly ?? this.followingOnly,
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
        hasAnyTagFilters ||
        userCreatedOnly ||
        createdByOthersOnly ||
        followingOnly;
  }

  static const RecipeAdvancedFilters defaults = RecipeAdvancedFilters(
    maxCalories: 2000,
    maxCarbs: 200,
    maxFats: 100,
    maxProtein: 150,
    maxSugar: 100,
    maxFiber: 50,
    maxSodium: 2500,
    useCaloriesFilter: false,
    useCarbsFilter: false,
    useFatsFilter: false,
    useProteinFilter: false,
    useSugarFilter: false,
    useFiberFilter: false,
    useSodiumFilter: false,
    caloriesComparisonMode: false,
    carbsComparisonMode: false,
    fatsComparisonMode: false,
    proteinComparisonMode: false,
    sugarComparisonMode: false,
    fiberComparisonMode: false,
    sodiumComparisonMode: false,
    maxCookTimeMinutes: 180,
    includeTags: <String>[],
    excludeTags: <String>[],
    userCreatedOnly: false,
    createdByOthersOnly: false,
    followingOnly: false,
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
      final currentUserId = ref.watch(currentUserIdProvider);
      final followingIdsAsync = ref.watch(userFollowingIdsProvider);
      final followingIds = followingIdsAsync.asData?.value ?? const <String>[];

      return recipesAsync.whenData((recipes) {
        var result = recipes;
        result = filterRecipesByQuery(result, query);
        result = applyAdvancedRecipeFilters(
          result,
          filters,
          forcedIncludeTags: tags,
          currentUserId: currentUserId,
          followingIds: followingIds,
        );

        return result;
      });
    });

List<Recipe> applyAdvancedRecipeFilters(
  List<Recipe> recipes,
  RecipeAdvancedFilters filters, {
  List<String> forcedIncludeTags = const <String>[],
  String? currentUserId,
  List<String> followingIds = const <String>[],
}) {
  var result = recipes;

  // Apply source filters
  if (filters.userCreatedOnly && currentUserId != null) {
    result = result.where((recipe) => recipe.ownerId == currentUserId).toList();
  }
  
  if (filters.createdByOthersOnly && currentUserId != null) {
    result = result.where((recipe) => recipe.ownerId != null && recipe.ownerId != currentUserId).toList();
  }
  
  if (filters.followingOnly && followingIds.isNotEmpty) {
    result = result.where((recipe) => recipe.ownerId != null && followingIds.contains(recipe.ownerId)).toList();
  }

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

    if (filters.useCaloriesFilter) {
      final meetsFilter = filters.caloriesComparisonMode
          ? nutrition.calories < filters.maxCalories
          : nutrition.calories > filters.maxCalories;
      if (meetsFilter) return false;
    }
    if (filters.useCarbsFilter) {
      final meetsFilter = filters.carbsComparisonMode
          ? nutrition.carbohydrates < filters.maxCarbs
          : nutrition.carbohydrates > filters.maxCarbs;
      if (meetsFilter) return false;
    }
    if (filters.useFatsFilter) {
      final meetsFilter = filters.fatsComparisonMode
          ? nutrition.fat < filters.maxFats
          : nutrition.fat > filters.maxFats;
      if (meetsFilter) return false;
    }
    if (filters.useProteinFilter) {
      final meetsFilter = filters.proteinComparisonMode
          ? nutrition.protein < filters.maxProtein
          : nutrition.protein > filters.maxProtein;
      if (meetsFilter) return false;
    }
    if (filters.useSugarFilter) {
      final meetsFilter = filters.sugarComparisonMode
          ? nutrition.sugar < filters.maxSugar
          : nutrition.sugar > filters.maxSugar;
      if (meetsFilter) return false;
    }
    if (filters.useFiberFilter) {
      final meetsFilter = filters.fiberComparisonMode
          ? nutrition.fiber < filters.maxFiber
          : nutrition.fiber > filters.maxFiber;
      if (meetsFilter) return false;
    }
    if (filters.useSodiumFilter) {
      final meetsFilter = filters.sodiumComparisonMode
          ? nutrition.sodium < filters.maxSodium
          : nutrition.sodium > filters.maxSodium;
      if (meetsFilter) return false;
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
    this.imageUrl = '',
    this.editingRecipeId = '',
    this.tempIngredientIds = const <String>[],
    this.creationId = '',
    this.tempIngredients = const <String, Ingredient>{},
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
  final String imageUrl;
  final String editingRecipeId;
  final List<String> tempIngredientIds;
  final String creationId;
  final Map<String, Ingredient> tempIngredients;

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
    String? imageUrl,
    String? editingRecipeId,
    List<String>? tempIngredientIds,
    String? creationId,
    Map<String, Ingredient>? tempIngredients,
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
      imageUrl: imageUrl ?? this.imageUrl,
      editingRecipeId: editingRecipeId ?? this.editingRecipeId,
      tempIngredientIds: tempIngredientIds ?? this.tempIngredientIds,
      creationId: creationId ?? this.creationId,
      tempIngredients: tempIngredients ?? this.tempIngredients,
    );
  }

  bool get canProceedFromAbout =>
      name.trim().isNotEmpty && description.trim().isNotEmpty;
  
  bool get isEditing => editingRecipeId.isNotEmpty;
}

class RecipeCreationNotifier extends Notifier<RecipeCreationState> {
  @override
  RecipeCreationState build() {
    return RecipeCreationState(
      creationId: 'creation_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void setEditingRecipeId(String recipeId) {
    state = state.copyWith(editingRecipeId: recipeId);
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

  void setImageUrl(String imageUrl) {
    state = state.copyWith(imageUrl: imageUrl);
  }

  void addTempIngredient(Ingredient ingredient) {
    state = state.copyWith(
      tempIngredientIds: <String>[...state.tempIngredientIds, ingredient.id],
      tempIngredients: <String, Ingredient>{
        ...state.tempIngredients,
        ingredient.id: ingredient,
      },
    );
  }

  Future<void> cleanupTempIngredients(String recipeId) async {
    if (state.tempIngredientIds.isEmpty) return;
    try {
      final ingredientService = ref.read(ingredientServiceProvider);
      await ingredientService.cleanupTemporaryIngredients(recipeId);
      state = state.copyWith(
        tempIngredientIds: const <String>[],
        tempIngredients: const <String, Ingredient>{},
      );
    } catch (e) {
      debugPrint('Error cleaning up temporary ingredients: $e');
    }
  }

  Future<void> finalizeTempIngredients(String recipeId) async {
    if (state.tempIngredientIds.isEmpty) return;
    try {
      final ingredientService = ref.read(ingredientServiceProvider);
      await ingredientService.promoteTemporaryIngredients(recipeId);
      state = state.copyWith(
        tempIngredientIds: const <String>[],
        tempIngredients: const <String, Ingredient>{},
      );
    } catch (e) {
      debugPrint('Error finalizing temporary ingredients: $e');
    }
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
    StreamProvider.family<bool, String>((ref, recipeId) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) return Stream.value(false);
      final recipeService = ref.watch(recipeServiceProvider);
      final recipeRef = recipeService.db.collection(FirestoreConstants.recipes).doc(recipeId);
      final favoriteRef = recipeRef.collection(FirestoreConstants.favorites).doc(userId);
      return favoriteRef.snapshots().map((doc) => doc.exists);
    });

// Notifier: toggle favorite (add or remove).
class ToggleFavoriteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  bool _optimisticState = false;

  Future<void> toggle(String recipeId) async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return;

    // Use the current value from the stream provider
    final isFavoritedAsync = ref.read(isRecipeFavoritedProvider(recipeId));
    final isFavorited = isFavoritedAsync.asData?.value ?? false;
    final recipeService = ref.read(recipeServiceProvider);
    final collectionService = ref.read(collectionServiceProvider);
    final recipeAsync = ref.read(recipeDetailsProvider(recipeId));
    final recipe = recipeAsync.asData?.value;

    // Optimistic UI: update local state immediately
    _optimisticState = !isFavorited;
    state = const AsyncValue.loading();

    try {
      if (isFavorited) {
        await recipeService.removeFavorite(recipeId, userId);
        await collectionService.removeRecipeFromFavorites(recipeId);
      } else {
        await recipeService.addFavorite(recipeId, userId);
        await collectionService.addRecipeToFavorites(
          recipeId: recipeId,
          recipeName: recipe?.name ?? 'Recipe',
          thumbnailUrl: recipe != null && recipe.imageURL.isNotEmpty == true ? recipe.imageURL.first : null,
        );
      }
      state = const AsyncValue.data(null);
    } catch (e) {
      // Rollback optimistic UI if failed
      _optimisticState = isFavorited;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final toggleFavoriteProvider =
    AsyncNotifierProvider<ToggleFavoriteNotifier, void>(
      ToggleFavoriteNotifier.new,
    );

