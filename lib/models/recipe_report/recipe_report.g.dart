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
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
