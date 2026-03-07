import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/features/utils/timestamp_convert.dart';

part 'recipe_report.freezed.dart';
part 'recipe_report.g.dart';

@freezed
abstract class RecipeReport with _$RecipeReport {
  const factory RecipeReport({
    required String id,
    required String recipeId,
    required String reporterId,
    required String reason,
    String? details,
    @Default('open') String status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _RecipeReport;

  factory RecipeReport.fromJson(Map<String, dynamic> json) =>
      _$RecipeReportFromJson(json);
}
