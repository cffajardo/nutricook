import 'package:freezed_annotation/freezed_annotation.dart';
import '../features/utils/timestamp_convert.dart';
import 'nutrition_info.dart';
import 'recipe_ingredient.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,

    @Default(<RecipeIngredient>[])
    List<RecipeIngredient> ingredients,

    @Default(<String>[])
    List<String> steps,

    required NutritionInfo nutrition,

    String? description,

    @Default(0)
    int favoriteCount,

    String? ownerId,

    @Default(<String>[])
    List<String> tags,

    @Default(<String>[])
    List<String> techniqueIds,

    @Default(<String>[])
    List<String> mediaIds,

    @Default(false)
    bool isPublic,

    @Default(false)
    bool isVerified,

    required int servings,

    required int cookTime, // minutes
    required int prepTime, // minutes

    @TimestampConverter()
    required DateTime createdAt,

    @TimestampConverter()
    required DateTime updatedAt,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
}
