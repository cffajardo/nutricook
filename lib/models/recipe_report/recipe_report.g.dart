// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeReport _$RecipeReportFromJson(Map<String, dynamic> json) =>
    _RecipeReport(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      reporterId: json['reporterId'] as String,
      reason: json['reason'] as String,
      details: json['details'] as String?,
      status: json['status'] as String? ?? 'open',
      reviewedBy: json['reviewedBy'] as String?,
      reviewNote: json['reviewNote'] as String?,
      reviewedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['reviewedAt'],
        const TimestampConverter().fromJson,
      ),
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$RecipeReportToJson(_RecipeReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipeId': instance.recipeId,
      'reporterId': instance.reporterId,
      'reason': instance.reason,
      'details': instance.details,
      'status': instance.status,
      'reviewedBy': instance.reviewedBy,
      'reviewNote': instance.reviewNote,
      'reviewedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.reviewedAt,
        const TimestampConverter().toJson,
      ),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
