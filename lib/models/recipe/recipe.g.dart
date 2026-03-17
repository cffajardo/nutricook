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
  steps: (json['steps'] as List<dynamic>)
      .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  description: json['description'] as String,
  isPublic: json['isPublic'] as bool,
  servings: (json['servings'] as num).toInt(),
  cookTime: (json['cookTime'] as num).toInt(),
  prepTime: (json['prepTime'] as num).toInt(),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
  archived: json['archived'] as bool? ?? false,
  archivedAt: const NullableTimestampConverter().fromJson(json['archivedAt']),
  deleteAfter: const NullableTimestampConverter().fromJson(json['deleteAfter']),
  nutritionTotal: json['nutritionTotal'] == null
      ? null
      : NutritionInfo.fromJson(json['nutritionTotal'] as Map<String, dynamic>),
  nutritionPerServing: json['nutritionPerServing'] == null
      ? null
      : NutritionInfo.fromJson(
          json['nutritionPerServing'] as Map<String, dynamic>,
        ),
  ownerId: json['ownerId'] as String?,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
  reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
  favoritedBy:
      (json['favoritedBy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  techniqueIDs:
      (json['techniqueIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  imageURL:
      (json['imageURL'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
  'steps': instance.steps.map((e) => e.toJson()).toList(),
  'description': instance.description,
  'isPublic': instance.isPublic,
  'servings': instance.servings,
  'cookTime': instance.cookTime,
  'prepTime': instance.prepTime,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'archived': instance.archived,
  'archivedAt': const NullableTimestampConverter().toJson(instance.archivedAt),
  'deleteAfter': const NullableTimestampConverter().toJson(
    instance.deleteAfter,
  ),
  'nutritionTotal': instance.nutritionTotal?.toJson(),
  'nutritionPerServing': instance.nutritionPerServing?.toJson(),
  'ownerId': instance.ownerId,
  'favoriteCount': instance.favoriteCount,
  'reportCount': instance.reportCount,
  'favoritedBy': instance.favoritedBy,
  'tags': instance.tags,
  'techniqueIDs': instance.techniqueIDs,
  'imageURL': instance.imageURL,
};
