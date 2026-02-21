import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/utils/timestamp_convert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'favorite_collection.freezed.dart';
part 'favorite_collection.g.dart';

@freezed
abstract class FavoriteCollection with _$FavoriteCollection {
  const factory FavoriteCollection({
    required String id,
    required String ownerId,
    required String recipeId,
    @TimestampConverter() required DateTime createdAt,
  }) = _FavoriteCollection;

  factory FavoriteCollection.fromJson(Map<String, dynamic> json) =>
      _$FavoriteCollectionFromJson(json);
}