// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Collection _$CollectionFromJson(Map<String, dynamic> json) => _Collection(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  thumnailUrl: json['thumnailUrl'] as String?,
  recipeCount: (json['recipeCount'] as num?)?.toInt() ?? 0,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$CollectionToJson(_Collection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'name': instance.name,
      'description': instance.description,
      'thumnailUrl': instance.thumnailUrl,
      'recipeCount': instance.recipeCount,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
