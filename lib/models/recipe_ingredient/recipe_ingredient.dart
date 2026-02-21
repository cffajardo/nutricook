import 'package:freezed_annotation/freezed_annotation.dart';
import '../nutrition_info/nutrition_info.dart';
part 'recipe_ingredient.freezed.dart';
part 'recipe_ingredient.g.dart';


@freezed
abstract class RecipeIngredient with _$RecipeIngredient {
  const factory RecipeIngredient({
    required String ingredientID,   
    required String name,           
    required double quantity,       
    required String unitID,         
    required String unitName,       
    NutritionInfo? nutritionPer100g, 
    double? densityGPerMl,           
    double? avgWeightG,              
    double? calculatedWeightG,       
    String? preparation,             
  }) = _RecipeIngredient;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);
}