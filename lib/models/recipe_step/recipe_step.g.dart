// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) => _RecipeStep(
  instruction: json['instruction'] as String,
  timerSeconds: (json['timerSeconds'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RecipeStepToJson(_RecipeStep instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'timerSeconds': instance.timerSeconds,
    };
