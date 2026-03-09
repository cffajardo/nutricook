import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_step.freezed.dart';
part 'recipe_step.g.dart';

@freezed
abstract class RecipeStep with _$RecipeStep {
  const factory RecipeStep({
    required String instruction,
    @Default(0) int timerSeconds,
  }) = _RecipeStep;

  factory RecipeStep.fromJson(Map<String, dynamic> json) =>
      _$RecipeStepFromJson(json);
}
