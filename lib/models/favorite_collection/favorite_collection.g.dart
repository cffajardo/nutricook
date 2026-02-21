// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteCollection _$FavoriteCollectionFromJson(Map<String, dynamic> json) =>
    _FavoriteCollection(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      recipeId: json['recipeId'] as String,
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$FavoriteCollectionToJson(_FavoriteCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'recipeId': instance.recipeId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
