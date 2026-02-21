import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/utils/timestamp_convert.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

@freezed 
abstract class Collection with _$Collection {
  const factory Collection({
    required String id,
    required String ownerId,
    required String name,
    required String description,
    String? thumnailUrl,
    @Default(0) int recipeCount,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Collection;

  factory Collection.fromJson(Map<String, dynamic> json) =>
    _$CollectionFromJson(json);
}