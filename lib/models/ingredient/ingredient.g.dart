// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ingredient _$IngredientFromJson(Map<String, dynamic> json) => _Ingredient(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String?,
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
  imageURL: json['imageURL'] as String?,
  archived: json['archived'] as bool? ?? false,
  archivedAt: const NullableTimestampConverter().fromJson(json['archivedAt']),
  deleteAfter: const NullableTimestampConverter().fromJson(json['deleteAfter']),
);

Map<String, dynamic> _$IngredientToJson(
  _Ingredient instance,
) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'name': instance.name,
  'category': instance.category,
  'description': instance.description,
  'nutritionPer100g': instance.nutritionPer100g?.toJson(),
  'densityGPerMl': instance.densityGPerMl,
  'avgWeightG': instance.avgWeightG,
  'imageURL': instance.imageURL,
  'archived': instance.archived,
  'archivedAt': const NullableTimestampConverter().toJson(instance.archivedAt),
  'deleteAfter': const NullableTimestampConverter().toJson(
    instance.deleteAfter,
  ),
};
