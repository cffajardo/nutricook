// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recipe _$RecipeFromJson(Map<String, dynamic> json) => _Recipe(
  id: json['id'] as String,
  name: json['name'] as String,
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
  description: json['description'] as String,
  isPublic: json['isPublic'] as bool,
  isVerified: json['isVerified'] as bool,
  servings: (json['servings'] as num).toInt(),
  cookTime: (json['cookTime'] as num).toInt(),
  prepTime: (json['prepTime'] as num).toInt(),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
  nutritionTotal: json['nutritionTotal'] == null
      ? null
      : NutritionInfo.fromJson(json['nutritionTotal'] as Map<String, dynamic>),
  nutritionPerServing: json['nutritionPerServing'] == null
      ? null
      : NutritionInfo.fromJson(
          json['nutritionPerServing'] as Map<String, dynamic>,
        ),
  ownerID: json['ownerID'] as String?,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  techniqueIDs:
      (json['techniqueIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  mediaIDs:
      (json['mediaIDs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ingredients': instance.ingredients,
  'steps': instance.steps,
  'description': instance.description,
  'isPublic': instance.isPublic,
  'isVerified': instance.isVerified,
  'servings': instance.servings,
  'cookTime': instance.cookTime,
  'prepTime': instance.prepTime,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'nutritionTotal': instance.nutritionTotal,
  'nutritionPerServing': instance.nutritionPerServing,
  'ownerID': instance.ownerID,
  'favoriteCount': instance.favoriteCount,
  'tags': instance.tags,
  'techniqueIDs': instance.techniqueIDs,
  'mediaIDs': instance.mediaIDs,
};
