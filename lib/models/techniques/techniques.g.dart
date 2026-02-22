// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'techniques.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Technique _$TechniqueFromJson(Map<String, dynamic> json) => _Technique(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  description: json['description'] as String?,
  mediaIDs:
      (json['mediaIDs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$TechniqueToJson(_Technique instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'mediaIDs': instance.mediaIDs,
    };
