import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nutricook/services/recipe_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/features/auth/auth_provider.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

//Public Recipes
final publicRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final recipeService = ref.watch(recipeServiceProvider);
  return recipeService.getPublicRecipes();
});

//Trending Recipes (Most Favorites)
final trendingRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.read(recipeServiceProvider).getTrendingRecipes();
});

//Recipe Details
final recipeDetailsProvider = StreamProvider.family<Recipe?, String>((ref, recipeId) {
  return ref.read(recipeServiceProvider).getRecipeById(recipeId);
});

//User Created Recipes
final userRecipesProvider = StreamProvider<List<Recipe>>((ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return Stream.value([]); 
    } else {
      return ref.read(recipeServiceProvider).getUserRecipes(userId);
    }
});

// Search Providers ---

@riverpod
class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounceTimer;

  @override
  String build() => '';
  void setQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = query;
    });
  }

}

final searchQueryNotifierProvider =
    NotifierProvider.autoDispose<SearchQueryNotifier, String>(SearchQueryNotifier.new);



