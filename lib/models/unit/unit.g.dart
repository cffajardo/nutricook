// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Unit _$UnitFromJson(Map<String, dynamic> json) => _Unit(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  multiplier: (json['multiplier'] as num).toDouble(),
  type: json['type'] as String,
);

Map<String, dynamic> _$UnitToJson(_Unit instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'multiplier': instance.multiplier,
  'type': instance.type,
};
