import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/utils/timestamp_convert.dart';
import '../nutrition_info/nutrition_info.dart';
import '../recipe_ingredient/recipe_ingredient.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

// recipe.dart
@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    required List<RecipeIngredient> ingredients,
    required List<String> steps,
    required String description,
    required bool isPublic,
    required bool isVerified,
    required int servings,
    required int cookTime,
    required int prepTime,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    NutritionInfo? nutritionTotal,
    NutritionInfo? nutritionPerServing,
    String? ownerID,
    @Default(0) int favoriteCount,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> techniqueIDs,
    @Default(<String>[]) List<String> mediaIDs,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
}
