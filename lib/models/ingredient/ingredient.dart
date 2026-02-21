import 'package:freezed_annotation/freezed_annotation.dart';
import '../nutrition_info/nutrition_info.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String id,
    required String name,
    required String category,
    String? description,
    NutritionInfo? nutritionPer100g,
    double? densityGPerMl,   // for liquids
    double? avgWeightG,      // for whole items
    @Default(<String>[]) List<String> mediaIDs,
    @Default(<String>[]) List<String> substituteIDs,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}