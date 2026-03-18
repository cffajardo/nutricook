import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/services/generative_ai_service.dart';
import 'package:nutricook/services/ingredient_service.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
// Providers are imported from their respective service/provider files

class CreateIngredientState {
  const CreateIngredientState({
    this.name = '',
    this.description = '',
    this.category = 'Proteins',
    this.isLiquid = false,
    this.nutritionMethod = 'manual', // Either AI or Manual
    this.calories = 0,
    this.carbohydrates = 0.0,
    this.protein = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.imageUrl = '',
    this.isLoadingNutrition = false,
    this.error = '',
    this.success = false,
    this.isTemporary = false,
    this.createdInRecipeId,
    this.editIngredientId,
  });

  final String name;
  final String description;
  final String category;
  final bool isLiquid;
  final String nutritionMethod;
  final int calories;
  final double carbohydrates;
  final double protein;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final String imageUrl; 
  final bool isLoadingNutrition;
  final String error;
  final bool success;
  final bool isTemporary;
  final String? createdInRecipeId;
  final String? editIngredientId;

  bool get isEditing => editIngredientId != null;

  CreateIngredientState copyWith({
    String? name,
    String? description,
    String? category,
    bool? isLiquid,
    String? nutritionMethod,
    int? calories,
    double? carbohydrates,
    double? protein,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    String? imageUrl,
    bool? isLoadingNutrition,
    String? error,
    bool? success,
    bool? isTemporary,
    String? createdInRecipeId,
    String? editIngredientId,
  }) {
    return CreateIngredientState(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isLiquid: isLiquid ?? this.isLiquid,
      nutritionMethod: nutritionMethod ?? this.nutritionMethod,
      calories: calories ?? this.calories,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoadingNutrition: isLoadingNutrition ?? this.isLoadingNutrition,
      error: error ?? this.error,
      success: success ?? this.success,
      isTemporary: isTemporary ?? this.isTemporary,
      createdInRecipeId: createdInRecipeId ?? this.createdInRecipeId,
      editIngredientId: editIngredientId ?? this.editIngredientId,
    );
  }

  Ingredient toIngredient({String? id, String? ownerId}) {
    final nutritionInfo = NutritionInfo(
      calories: calories,
      carbohydrates: carbohydrates,
      protein: protein,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
    );

    return Ingredient(
      id: id ?? '',
      ownerId: ownerId,
      name: name.trim(),
      category: category,
      description: description.trim().isNotEmpty
          ? description.trim()
          : name.trim(),
      nutritionPer100g: nutritionInfo,
      imageURL: imageUrl.isNotEmpty ? imageUrl : null,
    );
  }
}

class CreateIngredientNotifier extends Notifier<CreateIngredientState> {
  @override
  CreateIngredientState build() {
    return const CreateIngredientState();
  }

  void setName(String name) {
    state = state.copyWith(name: name, error: '');
  }

  void setDescription(String description) {
    state = state.copyWith(description: description, error: '');
  }

  void setCategory(String category) {
    state = state.copyWith(category: category, error: '');
  }

  void setIngredientType(bool isLiquid) {
    state = state.copyWith(
      isLiquid: isLiquid,
      error: '',
    );
  }

  void setNutritionMethod(String method) {
    state = state.copyWith(nutritionMethod: method, error: '');
  }

  void setImageUrl(String imageUrl) {
    state = state.copyWith(imageUrl: imageUrl, error: '');
  }

  void setTemporaryStatus({required bool isTemporary, String? recipeId}) {
    state = state.copyWith(
      isTemporary: isTemporary,
      createdInRecipeId: recipeId,
      error: '',
    );
  }

  void setNutritionValue({
    int? calories,
    double? carbohydrates,
    double? protein,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
  }) {
    state = state.copyWith(
      calories: calories,
      carbohydrates: carbohydrates,
      protein: protein,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      error: '',
    );
  }

  void populateFromIngredient(Ingredient ingredient) {
    state = state.copyWith(
      editIngredientId: ingredient.id,
      name: ingredient.name,
      description: ingredient.description,
      category: ingredient.category,
      calories: ingredient.nutritionPer100g?.calories ?? 0,
      carbohydrates: ingredient.nutritionPer100g?.carbohydrates ?? 0.0,
      protein: ingredient.nutritionPer100g?.protein ?? 0.0,
      fat: ingredient.nutritionPer100g?.fat ?? 0.0,
      fiber: ingredient.nutritionPer100g?.fiber ?? 0.0,
      sugar: ingredient.nutritionPer100g?.sugar ?? 0.0,
      sodium: ingredient.nutritionPer100g?.sodium ?? 0.0,
      imageUrl: ingredient.imageURL ?? '',
      isTemporary: false,
      success: false,
      error: '',
    );
  }

  Future<void> generateNutritionFromAI(String ingredientName) async {
    if (ingredientName.trim().isEmpty) {
      state = state.copyWith(
        error: 'Please enter ingredient name first',
      );
      return;
    }

    try {
      state = state.copyWith(isLoadingNutrition: true, error: '');

      final aiService = ref.read(generativeAiServiceProvider);
      final nutritionData = await aiService.generateNutritionFromAI(
        ingredientName.trim(),
      );

      state = state.copyWith(
        calories: nutritionData.calories,
        carbohydrates: nutritionData.carbohydrates,
        protein: nutritionData.protein,
        fat: nutritionData.fat,
        fiber: nutritionData.fiber,
        sugar: nutritionData.sugar,
        sodium: nutritionData.sodium,
        isLoadingNutrition: false,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingNutrition: false,
        error: 'Failed to generate nutrition: ${e.toString()}',
      );
    }
  }


  Future<Ingredient?> createIngredient() async {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter ingredient name');
      return null;
    }

    // Get current userId for custom ingredient, or null for global
    final userId = ref.read(currentUserIdProvider);
    final isTaken = await ref.read(ingredientServiceProvider).isIngredientNameTaken(
      state.name.trim(),
      ownerId: userId,
    );
    if (isTaken) {
      state = state.copyWith(
        error: 'You already have an ingredient named "${state.name.trim()}"',
      );
      return null;
    }

    if (state.calories == 0 &&
        state.carbohydrates == 0 &&
        state.protein == 0 &&
        state.fat == 0 &&
        state.fiber == 0 &&
        state.sugar == 0 &&
        state.sodium == 0) {
      state = state.copyWith(
        error: 'Please provide nutrition information',
      );
      return null;
    }

    try {
      state = state.copyWith(error: '');

      final nutritionInfo = NutritionInfo(
        calories: state.calories,
        carbohydrates: state.carbohydrates,
        protein: state.protein,
        fat: state.fat,
        fiber: state.fiber,
        sugar: state.sugar,
        sodium: state.sodium,
      );

      final ingredient = Ingredient(
        id: '',
        name: state.name.trim(),
        category: state.category,
        description: state.description.trim().isNotEmpty
            ? state.description.trim()
            : state.name.trim(),
        nutritionPer100g: nutritionInfo,
        imageURL: state.imageUrl.isNotEmpty ? state.imageUrl : null,
        ownerId: userId,
      );

      final ingredientService = ref.read(ingredientServiceProvider);
      final ingredientId = await ingredientService.createIngredient(
        ingredient,
        isTemporary: state.isTemporary,
        createdInRecipeId: state.createdInRecipeId,
      );

      state = state.copyWith(success: true);

      return ingredient.copyWith(id: ingredientId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create ingredient: ${e.toString()}');
      return null;
    }
  }

  Future<bool> updateIngredient() async {
    if (state.editIngredientId == null) return false;
    if (state.name.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter ingredient name');
      return false;
    }

    try {
      state = state.copyWith(error: '');
      final ingredientService = ref.read(ingredientServiceProvider);
      
      // Check if name changed to trigger re-enrichment
      final original = await ingredientService.getIngredientById(state.editIngredientId!);
      final nameChanged = original != null && original.name.toLowerCase() != state.name.trim().toLowerCase();

      final nutritionInfo = NutritionInfo(
        calories: state.calories,
        carbohydrates: state.carbohydrates,
        protein: state.protein,
        fat: state.fat,
        fiber: state.fiber,
        sugar: state.sugar,
        sodium: state.sodium,
      );

      final updatedIngredient = Ingredient(
        id: state.editIngredientId!,
        name: state.name.trim(),
        category: state.category,
        description: state.description.trim().isNotEmpty
            ? state.description.trim()
            : state.name.trim(),
        nutritionPer100g: nutritionInfo,
        imageURL: state.imageUrl.isNotEmpty ? state.imageUrl : null,
        ownerId: original?.ownerId,
      );

      await ingredientService.updateIngredient(updatedIngredient, nameChanged: nameChanged);
      state = state.copyWith(success: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update ingredient: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteIngredient(String id) async {
    try {
      final ingredientService = ref.read(ingredientServiceProvider);
      await ingredientService.deleteIngredient(id);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete ingredient: ${e.toString()}');
      return false;
    }
  }

  Future<Ingredient?> _checkIngredientExists(String ingredientName) async {
    try {
      final ingredientService = ref.read(ingredientServiceProvider);
      final allIngredients = await ingredientService.getAllIngredients();
      
      for (final ingredient in allIngredients) {
        if (ingredient.name.toLowerCase() == ingredientName.toLowerCase()) {
          return ingredient;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  void reset() {
    state = const CreateIngredientState();
  }
}

final createIngredientProvider =
    NotifierProvider<CreateIngredientNotifier, CreateIngredientState>(
  CreateIngredientNotifier.new,
);
