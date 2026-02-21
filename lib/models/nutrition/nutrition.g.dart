// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Nutrition _$NutritionFromJson(Map<String, dynamic> json) => _Nutrition(
  id: json['id'] as String,
  unitId: json['unitId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  recommendedDailyValue: (json['recommendedDailyValue'] as num).toDouble(),
);

Map<String, dynamic> _$NutritionToJson(_Nutrition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unitId': instance.unitId,
      'name': instance.name,
      'description': instance.description,
      'recommendedDailyValue': instance.recommendedDailyValue,
    };
