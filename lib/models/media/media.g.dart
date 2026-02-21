// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Media _$MediaFromJson(Map<String, dynamic> json) => _Media(
  id: json['id'] as String,
  url: json['url'] as String,
  ownerId: json['ownerId'] as String,
  storagePath: json['storagePath'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  type: json['type'] as String,
  uploadedAt: const TimestampConverter().fromJson(
    json['uploadedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$MediaToJson(_Media instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'ownerId': instance.ownerId,
  'storagePath': instance.storagePath,
  'thumbnailUrl': instance.thumbnailUrl,
  'type': instance.type,
  'uploadedAt': const TimestampConverter().toJson(instance.uploadedAt),
};
