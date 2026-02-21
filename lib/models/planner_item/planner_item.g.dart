// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlannerItem _$PlannerItemFromJson(Map<String, dynamic> json) => _PlannerItem(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  mealType: json['mealType'] as String,
  recipeId: json['recipeId'] as String,
  recipeName: json['recipeName'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  servingMultiplier: (json['servingMultiplier'] as num).toDouble(),
  prepTime: (json['prepTime'] as num).toInt(),
  cookTime: (json['cookTime'] as num).toInt(),
  notes: json['notes'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$PlannerItemToJson(_PlannerItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'mealType': instance.mealType,
      'recipeId': instance.recipeId,
      'recipeName': instance.recipeName,
      'thumbnailUrl': instance.thumbnailUrl,
      'servingMultiplier': instance.servingMultiplier,
      'prepTime': instance.prepTime,
      'cookTime': instance.cookTime,
      'notes': instance.notes,
      'isCompleted': instance.isCompleted,
    };
