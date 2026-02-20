import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_info.freezed.dart';
part 'nutrition_info.g.dart';

@freezed
abstract class NutritionInfo with _$NutritionInfo {
  const factory NutritionInfo({
    required int calories,
    required double carbohydrates,
    required double protein,
    required double fat,
    required double fiber,
    required double sugar,
    required double sodium,
  }) = _NutritionInfo;

  factory NutritionInfo.fromJson(Map<String, dynamic> json) =>
      _$NutritionInfoFromJson(json);
}