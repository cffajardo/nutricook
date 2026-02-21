import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/utils/timestamp_convert.dart';

part 'collection_item.freezed.dart';
part 'collection_item.g.dart';

@freezed 
abstract class CollectionItem with _$CollectionItem {
  const factory CollectionItem({
    required String id,
    required String collectionId,
    required String recipeId,
    required String recipeName,
    String? thumbnailUrl,  
    @Default(<String>[]) List<String> tags,
    required int prepTime,
    required int cookTime,
    @Default(0) int favoriteCount,
    @TimestampConverter() required DateTime addedAt,
    String? notes,
    @Default(0.0) double order,
  }) = _CollectionItem;

  factory CollectionItem.fromJson(Map<String, dynamic> json) =>
    _$CollectionItemFromJson(json);
}