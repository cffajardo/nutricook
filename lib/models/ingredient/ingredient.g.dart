// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ingredient _$IngredientFromJson(Map<String, dynamic> json) => _Ingredient(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  description: json['description'] as String?,
  nutritionPer100g: json['nutritionPer100g'] == null
      ? null
      : NutritionInfo.fromJson(
          json['nutritionPer100g'] as Map<String, dynamic>,
        ),
  densityGPerMl: (json['densityGPerMl'] as num?)?.toDouble(),
  avgWeightG: (json['avgWeightG'] as num?)?.toDouble(),
  mediaIDs:
      (json['mediaIDs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  substituteIDs:
      (json['substituteIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$IngredientToJson(_Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'nutritionPer100g': instance.nutritionPer100g,
      'densityGPerMl': instance.densityGPerMl,
      'avgWeightG': instance.avgWeightG,
      'mediaIDs': instance.mediaIDs,
      'substituteIDs': instance.substituteIDs,
    };
