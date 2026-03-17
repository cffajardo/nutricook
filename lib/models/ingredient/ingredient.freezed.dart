// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ingredient {

 String get id; String? get ownerId; String get name; String get category; String? get description; NutritionInfo? get nutritionPer100g; double? get densityGPerMl;// for liquids
 double? get avgWeightG;// for whole items
 String? get imageURL; bool get archived;@NullableTimestampConverter() DateTime? get archivedAt;@NullableTimestampConverter() DateTime? get deleteAfter;
/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientCopyWith<Ingredient> get copyWith => _$IngredientCopyWithImpl<Ingredient>(this as Ingredient, _$identity);

  /// Serializes this Ingredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ingredient&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.nutritionPer100g, nutritionPer100g) || other.nutritionPer100g == nutritionPer100g)&&(identical(other.densityGPerMl, densityGPerMl) || other.densityGPerMl == densityGPerMl)&&(identical(other.avgWeightG, avgWeightG) || other.avgWeightG == avgWeightG)&&(identical(other.imageURL, imageURL) || other.imageURL == imageURL)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.deleteAfter, deleteAfter) || other.deleteAfter == deleteAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,category,description,nutritionPer100g,densityGPerMl,avgWeightG,imageURL,archived,archivedAt,deleteAfter);

@override
String toString() {
  return 'Ingredient(id: $id, ownerId: $ownerId, name: $name, category: $category, description: $description, nutritionPer100g: $nutritionPer100g, densityGPerMl: $densityGPerMl, avgWeightG: $avgWeightG, imageURL: $imageURL, archived: $archived, archivedAt: $archivedAt, deleteAfter: $deleteAfter)';
}


}

/// @nodoc
abstract mixin class $IngredientCopyWith<$Res>  {
  factory $IngredientCopyWith(Ingredient value, $Res Function(Ingredient) _then) = _$IngredientCopyWithImpl;
@useResult
$Res call({
 String id, String? ownerId, String name, String category, String? description, NutritionInfo? nutritionPer100g, double? densityGPerMl, double? avgWeightG, String? imageURL, bool archived,@NullableTimestampConverter() DateTime? archivedAt,@NullableTimestampConverter() DateTime? deleteAfter
});


$NutritionInfoCopyWith<$Res>? get nutritionPer100g;

}
/// @nodoc
class _$IngredientCopyWithImpl<$Res>
    implements $IngredientCopyWith<$Res> {
  _$IngredientCopyWithImpl(this._self, this._then);

  final Ingredient _self;
  final $Res Function(Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = freezed,Object? name = null,Object? category = null,Object? description = freezed,Object? nutritionPer100g = freezed,Object? densityGPerMl = freezed,Object? avgWeightG = freezed,Object? imageURL = freezed,Object? archived = null,Object? archivedAt = freezed,Object? deleteAfter = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,nutritionPer100g: freezed == nutritionPer100g ? _self.nutritionPer100g : nutritionPer100g // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,densityGPerMl: freezed == densityGPerMl ? _self.densityGPerMl : densityGPerMl // ignore: cast_nullable_to_non_nullable
as double?,avgWeightG: freezed == avgWeightG ? _self.avgWeightG : avgWeightG // ignore: cast_nullable_to_non_nullable
as double?,imageURL: freezed == imageURL ? _self.imageURL : imageURL // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deleteAfter: freezed == deleteAfter ? _self.deleteAfter : deleteAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionInfoCopyWith<$Res>? get nutritionPer100g {
    if (_self.nutritionPer100g == null) {
    return null;
  }

  return $NutritionInfoCopyWith<$Res>(_self.nutritionPer100g!, (value) {
    return _then(_self.copyWith(nutritionPer100g: value));
  });
}
}


/// Adds pattern-matching-related methods to [Ingredient].
extension IngredientPatterns on Ingredient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ingredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ingredient value)  $default,){
final _that = this;
switch (_that) {
case _Ingredient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ingredient value)?  $default,){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? ownerId,  String name,  String category,  String? description,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  String? imageURL,  bool archived, @NullableTimestampConverter()  DateTime? archivedAt, @NullableTimestampConverter()  DateTime? deleteAfter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.category,_that.description,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.imageURL,_that.archived,_that.archivedAt,_that.deleteAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? ownerId,  String name,  String category,  String? description,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  String? imageURL,  bool archived, @NullableTimestampConverter()  DateTime? archivedAt, @NullableTimestampConverter()  DateTime? deleteAfter)  $default,) {final _that = this;
switch (_that) {
case _Ingredient():
return $default(_that.id,_that.ownerId,_that.name,_that.category,_that.description,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.imageURL,_that.archived,_that.archivedAt,_that.deleteAfter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? ownerId,  String name,  String category,  String? description,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  String? imageURL,  bool archived, @NullableTimestampConverter()  DateTime? archivedAt, @NullableTimestampConverter()  DateTime? deleteAfter)?  $default,) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.category,_that.description,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.imageURL,_that.archived,_that.archivedAt,_that.deleteAfter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ingredient implements Ingredient {
  const _Ingredient({required this.id, this.ownerId, required this.name, required this.category, this.description, this.nutritionPer100g, this.densityGPerMl, this.avgWeightG, this.imageURL, this.archived = false, @NullableTimestampConverter() this.archivedAt, @NullableTimestampConverter() this.deleteAfter});
  factory _Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

@override final  String id;
@override final  String? ownerId;
@override final  String name;
@override final  String category;
@override final  String? description;
@override final  NutritionInfo? nutritionPer100g;
@override final  double? densityGPerMl;
// for liquids
@override final  double? avgWeightG;
// for whole items
@override final  String? imageURL;
@override@JsonKey() final  bool archived;
@override@NullableTimestampConverter() final  DateTime? archivedAt;
@override@NullableTimestampConverter() final  DateTime? deleteAfter;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientCopyWith<_Ingredient> get copyWith => __$IngredientCopyWithImpl<_Ingredient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ingredient&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.nutritionPer100g, nutritionPer100g) || other.nutritionPer100g == nutritionPer100g)&&(identical(other.densityGPerMl, densityGPerMl) || other.densityGPerMl == densityGPerMl)&&(identical(other.avgWeightG, avgWeightG) || other.avgWeightG == avgWeightG)&&(identical(other.imageURL, imageURL) || other.imageURL == imageURL)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.deleteAfter, deleteAfter) || other.deleteAfter == deleteAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,category,description,nutritionPer100g,densityGPerMl,avgWeightG,imageURL,archived,archivedAt,deleteAfter);

@override
String toString() {
  return 'Ingredient(id: $id, ownerId: $ownerId, name: $name, category: $category, description: $description, nutritionPer100g: $nutritionPer100g, densityGPerMl: $densityGPerMl, avgWeightG: $avgWeightG, imageURL: $imageURL, archived: $archived, archivedAt: $archivedAt, deleteAfter: $deleteAfter)';
}


}

/// @nodoc
abstract mixin class _$IngredientCopyWith<$Res> implements $IngredientCopyWith<$Res> {
  factory _$IngredientCopyWith(_Ingredient value, $Res Function(_Ingredient) _then) = __$IngredientCopyWithImpl;
@override @useResult
$Res call({
 String id, String? ownerId, String name, String category, String? description, NutritionInfo? nutritionPer100g, double? densityGPerMl, double? avgWeightG, String? imageURL, bool archived,@NullableTimestampConverter() DateTime? archivedAt,@NullableTimestampConverter() DateTime? deleteAfter
});


@override $NutritionInfoCopyWith<$Res>? get nutritionPer100g;

}
/// @nodoc
class __$IngredientCopyWithImpl<$Res>
    implements _$IngredientCopyWith<$Res> {
  __$IngredientCopyWithImpl(this._self, this._then);

  final _Ingredient _self;
  final $Res Function(_Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = freezed,Object? name = null,Object? category = null,Object? description = freezed,Object? nutritionPer100g = freezed,Object? densityGPerMl = freezed,Object? avgWeightG = freezed,Object? imageURL = freezed,Object? archived = null,Object? archivedAt = freezed,Object? deleteAfter = freezed,}) {
  return _then(_Ingredient(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,nutritionPer100g: freezed == nutritionPer100g ? _self.nutritionPer100g : nutritionPer100g // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,densityGPerMl: freezed == densityGPerMl ? _self.densityGPerMl : densityGPerMl // ignore: cast_nullable_to_non_nullable
as double?,avgWeightG: freezed == avgWeightG ? _self.avgWeightG : avgWeightG // ignore: cast_nullable_to_non_nullable
as double?,imageURL: freezed == imageURL ? _self.imageURL : imageURL // ignore: cast_nullable_to_non_nullable
as String?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deleteAfter: freezed == deleteAfter ? _self.deleteAfter : deleteAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionInfoCopyWith<$Res>? get nutritionPer100g {
    if (_self.nutritionPer100g == null) {
    return null;
  }

  return $NutritionInfoCopyWith<$Res>(_self.nutritionPer100g!, (value) {
    return _then(_self.copyWith(nutritionPer100g: value));
  });
}
}

// dart format on
