import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/utils/timestamp_convert.dart';

part 'media.freezed.dart';
part 'media.g.dart';

@freezed
abstract class Media with _$Media {
  const factory Media({
    required String id,
    required String url,
    required String ownerId,
    required String storagePath,
    String? thumbnailUrl,
    required String type,
    @TimestampConverter() required DateTime uploadedAt,
  }) = _Media;

  factory Media.fromJson(Map<String, dynamic> json) =>
      _$MediaFromJson(json);
}