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
    this.category = 'proteins',
    this.isLiquid = false,
    this.nutritionMethod = 'manual', // 'manual' or 'ai'
    this.calories = 0,
    this.carbohydrates = 0.0,
    this.protein = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.density = null,
    this.avgWeight = null,
    this.imageUrl = '',
    this.isLoadingNutrition = false,
    this.isLoadingPhysicalProperty = false,
    this.error = '',
    this.success = false,
  });

  final String name;
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

  CreateIngredientState copyWith({
    String? name,
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
  }) {
    return CreateIngredientState(
      name: name ?? this.name,
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

    if (state.isLiquid && state.density == null) {
      state = state.copyWith(
        error: 'Please generate density for liquid ingredients',
      );
      return null;
    }

    if (!state.isLiquid && state.avgWeight == null) {
      state = state.copyWith(
        error: 'Please generate average piece weight for solid ingredients',
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
        description: state.name.trim(),
        nutritionPer100g: nutritionInfo,
        densityGPerMl: state.isLiquid ? state.density : null,
        avgWeightG: !state.isLiquid ? state.avgWeight : null,
        imageURL: state.imageUrl.isNotEmpty ? state.imageUrl : null,
      );

      final ingredientService = ref.read(ingredientServiceProvider);
      final ingredientId = await ingredientService.createIngredient(ingredient);

      state = state.copyWith(success: true);

      return ingredient.copyWith(id: ingredientId);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create ingredient: ${e.toString()}',
      );
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
