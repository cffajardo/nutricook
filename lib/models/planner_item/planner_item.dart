import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/utils/timestamp_convert.dart';

part 'planner_item.freezed.dart';
part 'planner_item.g.dart';

@freezed
abstract class PlannerItem with _$PlannerItem {
  const factory PlannerItem({
    required String id,
    required String ownerId,
    @TimestampConverter() required DateTime date,
    @TimestampConverter() required DateTime createdAt,
    required String mealType,
    required String recipeId,
    required String recipeName,
    required String thumbnailUrl,
    required double servingMultiplier,
    required int prepTime,
    required int cookTime,
    String? notes,
    required bool isCompleted,
  }) = _PlannerItem;

  factory PlannerItem.fromJson(Map<String, dynamic> json) =>
      _$PlannerItemFromJson(json);
}