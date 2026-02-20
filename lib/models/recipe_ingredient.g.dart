// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    _RecipeIngredient(
      ingredientId: json['ingredientId'] as String,
      unitId: json['unitId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitName: json['unitName'] as String,
      preparation: json['preparation'] as String,
    );

Map<String, dynamic> _$RecipeIngredientToJson(_RecipeIngredient instance) =>
    <String, dynamic>{
      'ingredientId': instance.ingredientId,
      'unitId': instance.unitId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unitName': instance.unitName,
      'preparation': instance.preparation,
    };
