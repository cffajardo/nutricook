import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/services/generative_ai_service.dart';
import 'package:nutricook/services/ingredient_service.dart';

// Service providers
final generativeAiServiceProvider = Provider<GenerativeAiService>((ref) {
  return GenerativeAiService();
});

final ingredientServiceProvider = Provider<IngredientService>((ref) {
  return IngredientService();
});

// State class for ingredient creation form
class CreateIngredientState {
  const CreateIngredientState({
    this.name = '',
    this.description = '',
    this.category = 'Proteins',
    this.isLiquid = false,
    this.nutritionMethod = 'manual', // 'manual' or 'ai'
    this.calories = 0,
    this.carbohydrates = 0.0,
    this.protein = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.density,
    this.avgWeight,
    this.imageUrl = '',
    this.isLoadingNutrition = false,
    this.isLoadingPhysicalProperty = false,
    this.error = '',
    this.success = false,
    this.isTemporary = false,
    this.createdInRecipeId,
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
  final double? density; // for liquids
  final double? avgWeight; // for solids
  final String imageUrl; // ingredient image from R2
  final bool isLoadingNutrition;
  final bool isLoadingPhysicalProperty;
  final String error;
  final bool success;
  final bool isTemporary;
  final String? createdInRecipeId;

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
    double? density,
    double? avgWeight,
    String? imageUrl,
    bool? isLoadingNutrition,
    bool? isLoadingPhysicalProperty,
    String? error,
    bool? success,
    bool? isTemporary,
    String? createdInRecipeId,
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
      density: density ?? this.density,
      avgWeight: avgWeight ?? this.avgWeight,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoadingNutrition: isLoadingNutrition ?? this.isLoadingNutrition,
      isLoadingPhysicalProperty:
          isLoadingPhysicalProperty ?? this.isLoadingPhysicalProperty,
      error: error ?? this.error,
      success: success ?? this.success,
      isTemporary: isTemporary ?? this.isTemporary,
      createdInRecipeId: createdInRecipeId ?? this.createdInRecipeId,
    );
  }
}

// Notifier for managing ingredient creation (modern Riverpod pattern)
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
      density: null,
      avgWeight: null,
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

  Future<void> generatePhysicalProperty(String ingredientName) async {
    if (ingredientName.trim().isEmpty) {
      state = state.copyWith(
        error: 'Please enter ingredient name first',
      );
      return;
    }

    try {
      state = state.copyWith(isLoadingPhysicalProperty: true, error: '');

      final aiService = ref.read(generativeAiServiceProvider);

      if (state.isLiquid) {
        // Generate density for liquids
        final density = await aiService.generateDensityFromAI(
          ingredientName.trim(),
        );
        state = state.copyWith(
          density: density,
          isLoadingPhysicalProperty: false,
          error: '',
        );
      } else {
        // Generate average weight for solids
        final avgWeight = await aiService.generateAveragePieceWeightFromAI(
          ingredientName.trim(),
        );
        state = state.copyWith(
          avgWeight: avgWeight,
          isLoadingPhysicalProperty: false,
          error: '',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingPhysicalProperty: false,
        error: 'Failed to generate property: ${e.toString()}',
      );
    }
  }

  Future<Ingredient?> createIngredient() async {
    // Validation
    if (state.name.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter ingredient name');
      return null;
    }

    // Check if ingredient with same name already exists
    final existingIngredient = await _checkIngredientExists(state.name.trim());
    if (existingIngredient != null) {
      state = state.copyWith(
        error: 'An ingredient named "${state.name.trim()}" already exists',
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

    // density and avgWeight are now optional to allow creation even if AI generation fails
    // but they remain preferred for unit conversion accuracy.

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

      // DEBUG: Verify NutritionInfo was created correctly
      debugPrint('📋 NUTRITION INFO DEBUG (Provider):');
      debugPrint('  Calories: ${nutritionInfo.calories}');
      debugPrint('  Carbs: ${nutritionInfo.carbohydrates}');
      debugPrint('  Protein: ${nutritionInfo.protein}');
      debugPrint('  Fat: ${nutritionInfo.fat}');
      debugPrint('  Fiber: ${nutritionInfo.fiber}');
      debugPrint('  Sugar: ${nutritionInfo.sugar}');
      debugPrint('  Sodium: ${nutritionInfo.sodium}');
      debugPrint('  ToJson: ${nutritionInfo.toJson()}');

      final ingredient = Ingredient(
        id: '',
        name: state.name.trim(),
        category: state.category,
        description: state.description.trim().isNotEmpty
            ? state.description.trim()
            : state.name.trim(),
        nutritionPer100g: nutritionInfo,
        densityGPerMl: state.isLiquid ? state.density : null,
        avgWeightG: !state.isLiquid ? state.avgWeight : null,
        imageURL: state.imageUrl.isNotEmpty ? state.imageUrl : null,
      );

      debugPrint('📦 INGREDIENT CREATED (Provider):');
      debugPrint('  Name: ${ingredient.name}');
      debugPrint('  Category: ${ingredient.category}');
      debugPrint('  NutritionInfo field: ${ingredient.nutritionPer100g}');

      final ingredientService = ref.read(ingredientServiceProvider);
      final ingredientId = await ingredientService.createIngredient(
        ingredient,
        isTemporary: state.isTemporary,
        createdInRecipeId: state.createdInRecipeId,
      );

      state = state.copyWith(success: true);

      return ingredient.copyWith(id: ingredientId);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create ingredient: ${e.toString()}',
      );
      return null;
    }
  }

  Future<Ingredient?> _checkIngredientExists(String ingredientName) async {
    try {
      final ingredientService = ref.read(ingredientServiceProvider);
      final allIngredients = await ingredientService.getAllIngredients();
      
      // Case-insensitive search for existing ingredient with same name
      for (final ingredient in allIngredients) {
        if (ingredient.name.toLowerCase() == ingredientName.toLowerCase()) {
          return ingredient;
        }
      }
      
      return null;
    } catch (e) {
      // If check fails, allow creation to proceed
      return null;
    }
  }

  void reset() {
    state = const CreateIngredientState();
  }
}

// Provider using modern Riverpod Notifier pattern
final createIngredientProvider =
    NotifierProvider<CreateIngredientNotifier, CreateIngredientState>(
  CreateIngredientNotifier.new,
);
