// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NutritionInfo _$NutritionInfoFromJson(Map<String, dynamic> json) =>
    _NutritionInfo(
      calories: (json['calories'] as num).toInt(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionInfoToJson(_NutritionInfo instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'carbohydrates': instance.carbohydrates,
      'protein': instance.protein,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'sodium': instance.sodium,
    };
