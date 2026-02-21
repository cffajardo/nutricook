// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    _RecipeIngredient(
      ingredientID: json['ingredientID'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitID: json['unitID'] as String,
      unitName: json['unitName'] as String,
      nutritionPer100g: json['nutritionPer100g'] == null
          ? null
          : NutritionInfo.fromJson(
              json['nutritionPer100g'] as Map<String, dynamic>,
            ),
      densityGPerMl: (json['densityGPerMl'] as num?)?.toDouble(),
      avgWeightG: (json['avgWeightG'] as num?)?.toDouble(),
      calculatedWeightG: (json['calculatedWeightG'] as num?)?.toDouble(),
      preparation: json['preparation'] as String?,
    );

Map<String, dynamic> _$RecipeIngredientToJson(_RecipeIngredient instance) =>
    <String, dynamic>{
      'ingredientID': instance.ingredientID,
      'name': instance.name,
      'quantity': instance.quantity,
      'unitID': instance.unitID,
      'unitName': instance.unitName,
      'nutritionPer100g': instance.nutritionPer100g,
      'densityGPerMl': instance.densityGPerMl,
      'avgWeightG': instance.avgWeightG,
      'calculatedWeightG': instance.calculatedWeightG,
      'preparation': instance.preparation,
    };
