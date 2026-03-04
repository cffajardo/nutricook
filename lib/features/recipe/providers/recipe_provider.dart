import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_filters.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_nutrition_total.dart';



final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

final publicRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.watch(recipeServiceProvider).getPublicRecipes();
});

final trendingRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.watch(recipeServiceProvider).getTrendingRecipes();
});

final recipeDetailsProvider = StreamProvider.family<Recipe?, String>((ref, recipeId) {
  return ref.watch(recipeServiceProvider).getRecipeById(recipeId);
});

final userRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(recipeServiceProvider).getUserRecipes(userId);
});

final recipeNutritionTotalsProvider = Provider<NutritionInfo Function(Recipe)>((ref) {
  return (recipe) => calculateRecipeNutritionTotals(recipe);
});

final recipeNutritionPerServingProvider = Provider<NutritionInfo Function(Recipe)>((ref) {
  return (recipe) => calculateRecipeNutritionPerServing(recipe);
});

class RecipeFilterInput {
  RecipeFilterInput({
    this.query = '',
    List<String> tags = const <String>[],
  }) : tags = List.unmodifiable(tags);

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

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final filteredRecipesProvider = Provider.family<AsyncValue<List<Recipe>>, RecipeFilterInput>((ref, input) {
  final recipesAsync = ref.watch(publicRecipesProvider); 
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



