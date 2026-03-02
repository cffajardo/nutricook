import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_notifier.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/search/provider/search_provider.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_filters.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_nutrition_total.dart';



final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

final userAllergenProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(authProvider).currentUser;
  if (user == null) return [];
  final userData = await ref.read(userServiceProvider).getUserData(user.uid);
  return userData?['allergens'] as List<String>? ?? [];
});

final recipeNotifierProvider =
    AsyncNotifierProvider<RecipeNotifier, List<Recipe>>(RecipeNotifier.new);

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


final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesAsync = ref.watch(publicRecipesProvider); 
  final allergensAsync = ref.watch(userAllergenProvider);
  final query = ref.watch(searchQueryNotifierProvider);
  final tags = ref.watch(selectedTagsProvider);

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



