import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/utils/timestamp_convert.dart';
import '../nutrition_info/nutrition_info.dart';
import '../recipe_ingredient/recipe_ingredient.dart';
import '../recipe_step/recipe_step.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
    required String description,
    required bool isPublic,
    required int servings,
    required int cookTime,
    required int prepTime,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @Default(false) bool archived,
    @NullableTimestampConverter() DateTime? archivedAt,
    @NullableTimestampConverter() DateTime? deleteAfter,
    NutritionInfo? nutritionTotal,
    NutritionInfo? nutritionPerServing,
    String? ownerId,
    @Default(0) int favoriteCount,
    @Default(0) int reportCount,
    @Default(<String>[]) List<String> favoritedBy,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> techniqueIDs,
    @Default(<String>[]) List<String> imageURL,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
