// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recipe _$RecipeFromJson(Map<String, dynamic> json) => _Recipe(
  id: json['id'] as String,
  name: json['name'] as String,
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RecipeIngredient>[],
  steps:
      (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  nutrition: NutritionInfo.fromJson(json['nutrition'] as Map<String, dynamic>),
  description: json['description'] as String?,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
  ownerId: json['ownerId'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  techniqueIds:
      (json['techniqueIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  mediaIds:
      (json['mediaIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isPublic: json['isPublic'] as bool? ?? false,
  isVerified: json['isVerified'] as bool? ?? false,
  servings: (json['servings'] as num).toInt(),
  cookTime: (json['cookTime'] as num).toInt(),
  prepTime: (json['prepTime'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ingredients': instance.ingredients,
  'steps': instance.steps,
  'nutrition': instance.nutrition,
  'description': instance.description,
  'favoriteCount': instance.favoriteCount,
  'ownerId': instance.ownerId,
  'tags': instance.tags,
  'techniqueIds': instance.techniqueIds,
  'mediaIds': instance.mediaIds,
  'isPublic': instance.isPublic,
  'isVerified': instance.isVerified,
  'servings': instance.servings,
  'cookTime': instance.cookTime,
  'prepTime': instance.prepTime,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
