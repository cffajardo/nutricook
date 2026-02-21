// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectionItem _$CollectionItemFromJson(Map<String, dynamic> json) =>
    _CollectionItem(
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      prepTime: (json['prepTime'] as num).toInt(),
      cookTime: (json['cookTime'] as num).toInt(),
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      addedAt: const TimestampConverter().fromJson(
        json['addedAt'] as Timestamp,
      ),
      notes: json['notes'] as String?,
      order: (json['order'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$CollectionItemToJson(_CollectionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'recipeId': instance.recipeId,
      'recipeName': instance.recipeName,
      'thumbnailUrl': instance.thumbnailUrl,
      'tags': instance.tags,
      'prepTime': instance.prepTime,
      'cookTime': instance.cookTime,
      'favoriteCount': instance.favoriteCount,
      'addedAt': const TimestampConverter().toJson(instance.addedAt),
      'notes': instance.notes,
      'order': instance.order,
    };
