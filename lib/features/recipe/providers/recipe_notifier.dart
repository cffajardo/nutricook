import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';




class RecipeNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];
    return ref.watch(recipeServiceProvider).getUserRecipes(userId).first;
  }

  Future<void> createRecipe(Recipe recipe) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recipeServiceProvider).createRecipe(recipe);
      return [...state.value ?? [], recipe];
    });
  }

  Future<void> deleteRecipe(String recipeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recipeServiceProvider).deleteRecipe(recipeId);
      return state.value?.where((r) => r.id != recipeId).toList() ?? [];
    });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recipeServiceProvider).updateRecipe(recipe);
      return state.value?.map((r) => r.id == recipe.id ? recipe : r).toList() ?? [];
    });
  }
}