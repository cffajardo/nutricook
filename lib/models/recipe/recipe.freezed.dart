// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Recipe {

 String get id; String get name; List<RecipeIngredient> get ingredients; List<RecipeStep> get steps; String get description; bool get isPublic; int get servings; int get cookTime; int get prepTime;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt; bool get archived;@NullableTimestampConverter() DateTime? get archivedAt;@NullableTimestampConverter() DateTime? get deleteAfter; NutritionInfo? get nutritionTotal; NutritionInfo? get nutritionPerServing; String? get ownerId; int get favoriteCount; int get reportCount; List<String> get favoritedBy; List<String> get tags; List<String> get techniqueIDs; List<String> get imageURL;
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCopyWith<Recipe> get copyWith => _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&const DeepCollectionEquality().equals(other.steps, steps)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.cookTime, cookTime) || other.cookTime == cookTime)&&(identical(other.prepTime, prepTime) || other.prepTime == prepTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.deleteAfter, deleteAfter) || other.deleteAfter == deleteAfter)&&(identical(other.nutritionTotal, nutritionTotal) || other.nutritionTotal == nutritionTotal)&&(identical(other.nutritionPerServing, nutritionPerServing) || other.nutritionPerServing == nutritionPerServing)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.reportCount, reportCount) || other.reportCount == reportCount)&&const DeepCollectionEquality().equals(other.favoritedBy, favoritedBy)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.techniqueIDs, techniqueIDs)&&const DeepCollectionEquality().equals(other.imageURL, imageURL));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,const DeepCollectionEquality().hash(ingredients),const DeepCollectionEquality().hash(steps),description,isPublic,servings,cookTime,prepTime,createdAt,updatedAt,archived,archivedAt,deleteAfter,nutritionTotal,nutritionPerServing,ownerId,favoriteCount,reportCount,const DeepCollectionEquality().hash(favoritedBy),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(techniqueIDs),const DeepCollectionEquality().hash(imageURL)]);

@override
String toString() {
  return 'Recipe(id: $id, name: $name, ingredients: $ingredients, steps: $steps, description: $description, isPublic: $isPublic, servings: $servings, cookTime: $cookTime, prepTime: $prepTime, createdAt: $createdAt, updatedAt: $updatedAt, archived: $archived, archivedAt: $archivedAt, deleteAfter: $deleteAfter, nutritionTotal: $nutritionTotal, nutritionPerServing: $nutritionPerServing, ownerId: $ownerId, favoriteCount: $favoriteCount, reportCount: $reportCount, favoritedBy: $favoritedBy, tags: $tags, techniqueIDs: $techniqueIDs, imageURL: $imageURL)';
}


}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res>  {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) = _$RecipeCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<RecipeIngredient> ingredients, List<RecipeStep> steps, String description, bool isPublic, int servings, int cookTime, int prepTime,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt, bool archived,@NullableTimestampConverter() DateTime? archivedAt,@NullableTimestampConverter() DateTime? deleteAfter, NutritionInfo? nutritionTotal, NutritionInfo? nutritionPerServing, String? ownerId, int favoriteCount, int reportCount, List<String> favoritedBy, List<String> tags, List<String> techniqueIDs, List<String> imageURL
});


$NutritionInfoCopyWith<$Res>? get nutritionTotal;$NutritionInfoCopyWith<$Res>? get nutritionPerServing;

}
/// @nodoc
class _$RecipeCopyWithImpl<$Res>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._self, this._then);

  final Recipe _self;
  final $Res Function(Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ingredients = null,Object? steps = null,Object? description = null,Object? isPublic = null,Object? servings = null,Object? cookTime = null,Object? prepTime = null,Object? createdAt = null,Object? updatedAt = null,Object? archived = null,Object? archivedAt = freezed,Object? deleteAfter = freezed,Object? nutritionTotal = freezed,Object? nutritionPerServing = freezed,Object? ownerId = freezed,Object? favoriteCount = null,Object? reportCount = null,Object? favoritedBy = null,Object? tags = null,Object? techniqueIDs = null,Object? imageURL = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<RecipeIngredient>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<RecipeStep>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,cookTime: null == cookTime ? _self.cookTime : cookTime // ignore: cast_nullable_to_non_nullable
as int,prepTime: null == prepTime ? _self.prepTime : prepTime // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deleteAfter: freezed == deleteAfter ? _self.deleteAfter : deleteAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,nutritionTotal: freezed == nutritionTotal ? _self.nutritionTotal : nutritionTotal // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,nutritionPerServing: freezed == nutritionPerServing ? _self.nutritionPerServing : nutritionPerServing // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,reportCount: null == reportCount ? _self.reportCount : reportCount // ignore: cast_nullable_to_non_nullable
as int,favoritedBy: null == favoritedBy ? _self.favoritedBy : favoritedBy // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,techniqueIDs: null == techniqueIDs ? _self.techniqueIDs : techniqueIDs // ignore: cast_nullable_to_non_nullable
as List<String>,imageURL: null == imageURL ? _self.imageURL : imageURL // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionInfoCopyWith<$Res>? get nutritionTotal {
    if (_self.nutritionTotal == null) {
    return null;
  }

  return $NutritionInfoCopyWith<$Res>(_self.nutritionTotal!, (value) {
    return _then(_self.copyWith(nutritionTotal: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionInfoCopyWith<$Res>? get nutritionPerServing {
    if (_self.nutritionPerServing == null) {
    return null;
  }

  return $NutritionInfoCopyWith<$Res>(_self.nutritionPerServing!, (value) {
    return _then(_self.copyWith(nutritionPerServing: value));
  });
}
}


/// Adds pattern-matching-related methods to [Recipe].
extension RecipePatterns on Recipe {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recipe value)  $default,){
final _that = this;
switch (_that) {
case _Recipe():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recipe value)?  $default,){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<RecipeIngredient> ingredients,  List<RecipeStep> steps,  String description,  bool isPublic,  int servings,  int cookTime,  int prepTime, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt,  bool archived, @NullableTimestampConverter()  DateTime? archivedAt, @NullableTimestampConverter()  DateTime? deleteAfter,  NutritionInfo? nutritionTotal,  NutritionInfo? nutritionPerServing,  String? ownerId,  int favoriteCount,  int reportCount,  List<String> favoritedBy,  List<String> tags,  List<String> techniqueIDs,  List<String> imageURL)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.name,_that.ingredients,_that.steps,_that.description,_that.isPublic,_that.servings,_that.cookTime,_that.prepTime,_that.createdAt,_that.updatedAt,_that.archived,_that.archivedAt,_that.deleteAfter,_that.nutritionTotal,_that.nutritionPerServing,_that.ownerId,_that.favoriteCount,_that.reportCount,_that.favoritedBy,_that.tags,_that.techniqueIDs,_that.imageURL);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<RecipeIngredient> ingredients,  List<RecipeStep> steps,  String description,  bool isPublic,  int servings,  int cookTime,  int prepTime, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt,  bool archived, @NullableTimestampConverter()  DateTime? archivedAt, @NullableTimestampConverter()  DateTime? deleteAfter,  NutritionInfo? nutritionTotal,  NutritionInfo? nutritionPerServing,  String? ownerId,  int favoriteCount,  int reportCount,  List<String> favoritedBy,  List<String> tags,  List<String> techniqueIDs,  List<String> imageURL)  $default,) {final _that = this;
switch (_that) {
case _Recipe():
return $default(_that.id,_that.name,_that.ingredients,_that.steps,_that.description,_that.isPublic,_that.servings,_that.cookTime,_that.prepTime,_that.createdAt,_that.updatedAt,_that.archived,_that.archivedAt,_that.deleteAfter,_that.nutritionTotal,_that.nutritionPerServing,_that.ownerId,_that.favoriteCount,_that.reportCount,_that.favoritedBy,_that.tags,_that.techniqueIDs,_that.imageURL);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<RecipeIngredient> ingredients,  List<RecipeStep> steps,  String description,  bool isPublic,  int servings,  int cookTime,  int prepTime, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt,  bool archived, @NullableTimestampConverter()  DateTime? archivedAt, @NullableTimestampConverter()  DateTime? deleteAfter,  NutritionInfo? nutritionTotal,  NutritionInfo? nutritionPerServing,  String? ownerId,  int favoriteCount,  int reportCount,  List<String> favoritedBy,  List<String> tags,  List<String> techniqueIDs,  List<String> imageURL)?  $default,) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.name,_that.ingredients,_that.steps,_that.description,_that.isPublic,_that.servings,_that.cookTime,_that.prepTime,_that.createdAt,_that.updatedAt,_that.archived,_that.archivedAt,_that.deleteAfter,_that.nutritionTotal,_that.nutritionPerServing,_that.ownerId,_that.favoriteCount,_that.reportCount,_that.favoritedBy,_that.tags,_that.techniqueIDs,_that.imageURL);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recipe implements Recipe {
  const _Recipe({required this.id, required this.name, required final  List<RecipeIngredient> ingredients, required final  List<RecipeStep> steps, required this.description, required this.isPublic, required this.servings, required this.cookTime, required this.prepTime, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt, this.archived = false, @NullableTimestampConverter() this.archivedAt, @NullableTimestampConverter() this.deleteAfter, this.nutritionTotal, this.nutritionPerServing, this.ownerId, this.favoriteCount = 0, this.reportCount = 0, final  List<String> favoritedBy = const <String>[], final  List<String> tags = const <String>[], final  List<String> techniqueIDs = const <String>[], final  List<String> imageURL = const <String>[]}): _ingredients = ingredients,_steps = steps,_favoritedBy = favoritedBy,_tags = tags,_techniqueIDs = techniqueIDs,_imageURL = imageURL;
  factory _Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

@override final  String id;
@override final  String name;
 final  List<RecipeIngredient> _ingredients;
@override List<RecipeIngredient> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

 final  List<RecipeStep> _steps;
@override List<RecipeStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

@override final  String description;
@override final  bool isPublic;
@override final  int servings;
@override final  int cookTime;
@override final  int prepTime;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;
@override@JsonKey() final  bool archived;
@override@NullableTimestampConverter() final  DateTime? archivedAt;
@override@NullableTimestampConverter() final  DateTime? deleteAfter;
@override final  NutritionInfo? nutritionTotal;
@override final  NutritionInfo? nutritionPerServing;
@override final  String? ownerId;
@override@JsonKey() final  int favoriteCount;
@override@JsonKey() final  int reportCount;
 final  List<String> _favoritedBy;
@override@JsonKey() List<String> get favoritedBy {
  if (_favoritedBy is EqualUnmodifiableListView) return _favoritedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoritedBy);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<String> _techniqueIDs;
@override@JsonKey() List<String> get techniqueIDs {
  if (_techniqueIDs is EqualUnmodifiableListView) return _techniqueIDs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_techniqueIDs);
}

 final  List<String> _imageURL;
@override@JsonKey() List<String> get imageURL {
  if (_imageURL is EqualUnmodifiableListView) return _imageURL;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageURL);
}


/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCopyWith<_Recipe> get copyWith => __$RecipeCopyWithImpl<_Recipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&const DeepCollectionEquality().equals(other._steps, _steps)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.cookTime, cookTime) || other.cookTime == cookTime)&&(identical(other.prepTime, prepTime) || other.prepTime == prepTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.deleteAfter, deleteAfter) || other.deleteAfter == deleteAfter)&&(identical(other.nutritionTotal, nutritionTotal) || other.nutritionTotal == nutritionTotal)&&(identical(other.nutritionPerServing, nutritionPerServing) || other.nutritionPerServing == nutritionPerServing)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.reportCount, reportCount) || other.reportCount == reportCount)&&const DeepCollectionEquality().equals(other._favoritedBy, _favoritedBy)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._techniqueIDs, _techniqueIDs)&&const DeepCollectionEquality().equals(other._imageURL, _imageURL));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_steps),description,isPublic,servings,cookTime,prepTime,createdAt,updatedAt,archived,archivedAt,deleteAfter,nutritionTotal,nutritionPerServing,ownerId,favoriteCount,reportCount,const DeepCollectionEquality().hash(_favoritedBy),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_techniqueIDs),const DeepCollectionEquality().hash(_imageURL)]);

@override
String toString() {
  return 'Recipe(id: $id, name: $name, ingredients: $ingredients, steps: $steps, description: $description, isPublic: $isPublic, servings: $servings, cookTime: $cookTime, prepTime: $prepTime, createdAt: $createdAt, updatedAt: $updatedAt, archived: $archived, archivedAt: $archivedAt, deleteAfter: $deleteAfter, nutritionTotal: $nutritionTotal, nutritionPerServing: $nutritionPerServing, ownerId: $ownerId, favoriteCount: $favoriteCount, reportCount: $reportCount, favoritedBy: $favoritedBy, tags: $tags, techniqueIDs: $techniqueIDs, imageURL: $imageURL)';
}


}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) = __$RecipeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<RecipeIngredient> ingredients, List<RecipeStep> steps, String description, bool isPublic, int servings, int cookTime, int prepTime,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt, bool archived,@NullableTimestampConverter() DateTime? archivedAt,@NullableTimestampConverter() DateTime? deleteAfter, NutritionInfo? nutritionTotal, NutritionInfo? nutritionPerServing, String? ownerId, int favoriteCount, int reportCount, List<String> favoritedBy, List<String> tags, List<String> techniqueIDs, List<String> imageURL
});


@override $NutritionInfoCopyWith<$Res>? get nutritionTotal;@override $NutritionInfoCopyWith<$Res>? get nutritionPerServing;

}
/// @nodoc
class __$RecipeCopyWithImpl<$Res>
    implements _$RecipeCopyWith<$Res> {
  __$RecipeCopyWithImpl(this._self, this._then);

  final _Recipe _self;
  final $Res Function(_Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ingredients = null,Object? steps = null,Object? description = null,Object? isPublic = null,Object? servings = null,Object? cookTime = null,Object? prepTime = null,Object? createdAt = null,Object? updatedAt = null,Object? archived = null,Object? archivedAt = freezed,Object? deleteAfter = freezed,Object? nutritionTotal = freezed,Object? nutritionPerServing = freezed,Object? ownerId = freezed,Object? favoriteCount = null,Object? reportCount = null,Object? favoritedBy = null,Object? tags = null,Object? techniqueIDs = null,Object? imageURL = null,}) {
  return _then(_Recipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<RecipeIngredient>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<RecipeStep>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,cookTime: null == cookTime ? _self.cookTime : cookTime // ignore: cast_nullable_to_non_nullable
as int,prepTime: null == prepTime ? _self.prepTime : prepTime // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deleteAfter: freezed == deleteAfter ? _self.deleteAfter : deleteAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,nutritionTotal: freezed == nutritionTotal ? _self.nutritionTotal : nutritionTotal // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,nutritionPerServing: freezed == nutritionPerServing ? _self.nutritionPerServing : nutritionPerServing // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,reportCount: null == reportCount ? _self.reportCount : reportCount // ignore: cast_nullable_to_non_nullable
as int,favoritedBy: null == favoritedBy ? _self._favoritedBy : favoritedBy // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,techniqueIDs: null == techniqueIDs ? _self._techniqueIDs : techniqueIDs // ignore: cast_nullable_to_non_nullable
as List<String>,imageURL: null == imageURL ? _self._imageURL : imageURL // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionInfoCopyWith<$Res>? get nutritionTotal {
    if (_self.nutritionTotal == null) {
    return null;
  }

  return $NutritionInfoCopyWith<$Res>(_self.nutritionTotal!, (value) {
    return _then(_self.copyWith(nutritionTotal: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionInfoCopyWith<$Res>? get nutritionPerServing {
    if (_self.nutritionPerServing == null) {
    return null;
  }

  return $NutritionInfoCopyWith<$Res>(_self.nutritionPerServing!, (value) {
    return _then(_self.copyWith(nutritionPerServing: value));
  });
}
}

// dart format on
