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

 String get id; String get name; String get category; String? get description; NutritionInfo? get nutritionPer100g; double? get densityGPerMl;// for liquids
 double? get avgWeightG;// for whole items
 List<String> get mediaIDs; List<String> get substituteIDs;
/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientCopyWith<Ingredient> get copyWith => _$IngredientCopyWithImpl<Ingredient>(this as Ingredient, _$identity);

  /// Serializes this Ingredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ingredient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.nutritionPer100g, nutritionPer100g) || other.nutritionPer100g == nutritionPer100g)&&(identical(other.densityGPerMl, densityGPerMl) || other.densityGPerMl == densityGPerMl)&&(identical(other.avgWeightG, avgWeightG) || other.avgWeightG == avgWeightG)&&const DeepCollectionEquality().equals(other.mediaIDs, mediaIDs)&&const DeepCollectionEquality().equals(other.substituteIDs, substituteIDs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,description,nutritionPer100g,densityGPerMl,avgWeightG,const DeepCollectionEquality().hash(mediaIDs),const DeepCollectionEquality().hash(substituteIDs));

@override
String toString() {
  return 'Ingredient(id: $id, name: $name, category: $category, description: $description, nutritionPer100g: $nutritionPer100g, densityGPerMl: $densityGPerMl, avgWeightG: $avgWeightG, mediaIDs: $mediaIDs, substituteIDs: $substituteIDs)';
}


}

/// @nodoc
abstract mixin class $IngredientCopyWith<$Res>  {
  factory $IngredientCopyWith(Ingredient value, $Res Function(Ingredient) _then) = _$IngredientCopyWithImpl;
@useResult
$Res call({
 String id, String name, String category, String? description, NutritionInfo? nutritionPer100g, double? densityGPerMl, double? avgWeightG, List<String> mediaIDs, List<String> substituteIDs
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? description = freezed,Object? nutritionPer100g = freezed,Object? densityGPerMl = freezed,Object? avgWeightG = freezed,Object? mediaIDs = null,Object? substituteIDs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,nutritionPer100g: freezed == nutritionPer100g ? _self.nutritionPer100g : nutritionPer100g // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,densityGPerMl: freezed == densityGPerMl ? _self.densityGPerMl : densityGPerMl // ignore: cast_nullable_to_non_nullable
as double?,avgWeightG: freezed == avgWeightG ? _self.avgWeightG : avgWeightG // ignore: cast_nullable_to_non_nullable
as double?,mediaIDs: null == mediaIDs ? _self.mediaIDs : mediaIDs // ignore: cast_nullable_to_non_nullable
as List<String>,substituteIDs: null == substituteIDs ? _self.substituteIDs : substituteIDs // ignore: cast_nullable_to_non_nullable
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String? description,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  List<String> mediaIDs,  List<String> substituteIDs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.description,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.mediaIDs,_that.substituteIDs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String? description,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  List<String> mediaIDs,  List<String> substituteIDs)  $default,) {final _that = this;
switch (_that) {
case _Ingredient():
return $default(_that.id,_that.name,_that.category,_that.description,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.mediaIDs,_that.substituteIDs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String category,  String? description,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  List<String> mediaIDs,  List<String> substituteIDs)?  $default,) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.description,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.mediaIDs,_that.substituteIDs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ingredient implements Ingredient {
  const _Ingredient({required this.id, required this.name, required this.category, this.description, this.nutritionPer100g, this.densityGPerMl, this.avgWeightG, final  List<String> mediaIDs = const <String>[], final  List<String> substituteIDs = const <String>[]}): _mediaIDs = mediaIDs,_substituteIDs = substituteIDs;
  factory _Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

@override final  String id;
@override final  String name;
@override final  String category;
@override final  String? description;
@override final  NutritionInfo? nutritionPer100g;
@override final  double? densityGPerMl;
// for liquids
@override final  double? avgWeightG;
// for whole items
 final  List<String> _mediaIDs;
// for whole items
@override@JsonKey() List<String> get mediaIDs {
  if (_mediaIDs is EqualUnmodifiableListView) return _mediaIDs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaIDs);
}

 final  List<String> _substituteIDs;
@override@JsonKey() List<String> get substituteIDs {
  if (_substituteIDs is EqualUnmodifiableListView) return _substituteIDs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_substituteIDs);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ingredient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.nutritionPer100g, nutritionPer100g) || other.nutritionPer100g == nutritionPer100g)&&(identical(other.densityGPerMl, densityGPerMl) || other.densityGPerMl == densityGPerMl)&&(identical(other.avgWeightG, avgWeightG) || other.avgWeightG == avgWeightG)&&const DeepCollectionEquality().equals(other._mediaIDs, _mediaIDs)&&const DeepCollectionEquality().equals(other._substituteIDs, _substituteIDs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,description,nutritionPer100g,densityGPerMl,avgWeightG,const DeepCollectionEquality().hash(_mediaIDs),const DeepCollectionEquality().hash(_substituteIDs));

@override
String toString() {
  return 'Ingredient(id: $id, name: $name, category: $category, description: $description, nutritionPer100g: $nutritionPer100g, densityGPerMl: $densityGPerMl, avgWeightG: $avgWeightG, mediaIDs: $mediaIDs, substituteIDs: $substituteIDs)';
}


}

/// @nodoc
abstract mixin class _$IngredientCopyWith<$Res> implements $IngredientCopyWith<$Res> {
  factory _$IngredientCopyWith(_Ingredient value, $Res Function(_Ingredient) _then) = __$IngredientCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String category, String? description, NutritionInfo? nutritionPer100g, double? densityGPerMl, double? avgWeightG, List<String> mediaIDs, List<String> substituteIDs
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? description = freezed,Object? nutritionPer100g = freezed,Object? densityGPerMl = freezed,Object? avgWeightG = freezed,Object? mediaIDs = null,Object? substituteIDs = null,}) {
  return _then(_Ingredient(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,nutritionPer100g: freezed == nutritionPer100g ? _self.nutritionPer100g : nutritionPer100g // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,densityGPerMl: freezed == densityGPerMl ? _self.densityGPerMl : densityGPerMl // ignore: cast_nullable_to_non_nullable
as double?,avgWeightG: freezed == avgWeightG ? _self.avgWeightG : avgWeightG // ignore: cast_nullable_to_non_nullable
as double?,mediaIDs: null == mediaIDs ? _self._mediaIDs : mediaIDs // ignore: cast_nullable_to_non_nullable
as List<String>,substituteIDs: null == substituteIDs ? _self._substituteIDs : substituteIDs // ignore: cast_nullable_to_non_nullable
as List<String>,
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
