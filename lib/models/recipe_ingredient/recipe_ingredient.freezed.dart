// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipeIngredient {

 String get ingredientID; String get name; double get quantity; String get unitID; String get unitName; NutritionInfo? get nutritionPer100g; double? get densityGPerMl; double? get avgWeightG; double? get calculatedWeightG; String? get preparation;
/// Create a copy of RecipeIngredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeIngredientCopyWith<RecipeIngredient> get copyWith => _$RecipeIngredientCopyWithImpl<RecipeIngredient>(this as RecipeIngredient, _$identity);

  /// Serializes this RecipeIngredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeIngredient&&(identical(other.ingredientID, ingredientID) || other.ingredientID == ingredientID)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitID, unitID) || other.unitID == unitID)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.nutritionPer100g, nutritionPer100g) || other.nutritionPer100g == nutritionPer100g)&&(identical(other.densityGPerMl, densityGPerMl) || other.densityGPerMl == densityGPerMl)&&(identical(other.avgWeightG, avgWeightG) || other.avgWeightG == avgWeightG)&&(identical(other.calculatedWeightG, calculatedWeightG) || other.calculatedWeightG == calculatedWeightG)&&(identical(other.preparation, preparation) || other.preparation == preparation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ingredientID,name,quantity,unitID,unitName,nutritionPer100g,densityGPerMl,avgWeightG,calculatedWeightG,preparation);

@override
String toString() {
  return 'RecipeIngredient(ingredientID: $ingredientID, name: $name, quantity: $quantity, unitID: $unitID, unitName: $unitName, nutritionPer100g: $nutritionPer100g, densityGPerMl: $densityGPerMl, avgWeightG: $avgWeightG, calculatedWeightG: $calculatedWeightG, preparation: $preparation)';
}


}

/// @nodoc
abstract mixin class $RecipeIngredientCopyWith<$Res>  {
  factory $RecipeIngredientCopyWith(RecipeIngredient value, $Res Function(RecipeIngredient) _then) = _$RecipeIngredientCopyWithImpl;
@useResult
$Res call({
 String ingredientID, String name, double quantity, String unitID, String unitName, NutritionInfo? nutritionPer100g, double? densityGPerMl, double? avgWeightG, double? calculatedWeightG, String? preparation
});


$NutritionInfoCopyWith<$Res>? get nutritionPer100g;

}
/// @nodoc
class _$RecipeIngredientCopyWithImpl<$Res>
    implements $RecipeIngredientCopyWith<$Res> {
  _$RecipeIngredientCopyWithImpl(this._self, this._then);

  final RecipeIngredient _self;
  final $Res Function(RecipeIngredient) _then;

/// Create a copy of RecipeIngredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredientID = null,Object? name = null,Object? quantity = null,Object? unitID = null,Object? unitName = null,Object? nutritionPer100g = freezed,Object? densityGPerMl = freezed,Object? avgWeightG = freezed,Object? calculatedWeightG = freezed,Object? preparation = freezed,}) {
  return _then(_self.copyWith(
ingredientID: null == ingredientID ? _self.ingredientID : ingredientID // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitID: null == unitID ? _self.unitID : unitID // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,nutritionPer100g: freezed == nutritionPer100g ? _self.nutritionPer100g : nutritionPer100g // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,densityGPerMl: freezed == densityGPerMl ? _self.densityGPerMl : densityGPerMl // ignore: cast_nullable_to_non_nullable
as double?,avgWeightG: freezed == avgWeightG ? _self.avgWeightG : avgWeightG // ignore: cast_nullable_to_non_nullable
as double?,calculatedWeightG: freezed == calculatedWeightG ? _self.calculatedWeightG : calculatedWeightG // ignore: cast_nullable_to_non_nullable
as double?,preparation: freezed == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RecipeIngredient
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


/// Adds pattern-matching-related methods to [RecipeIngredient].
extension RecipeIngredientPatterns on RecipeIngredient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeIngredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeIngredient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeIngredient value)  $default,){
final _that = this;
switch (_that) {
case _RecipeIngredient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeIngredient value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeIngredient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ingredientID,  String name,  double quantity,  String unitID,  String unitName,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  double? calculatedWeightG,  String? preparation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeIngredient() when $default != null:
return $default(_that.ingredientID,_that.name,_that.quantity,_that.unitID,_that.unitName,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.calculatedWeightG,_that.preparation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ingredientID,  String name,  double quantity,  String unitID,  String unitName,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  double? calculatedWeightG,  String? preparation)  $default,) {final _that = this;
switch (_that) {
case _RecipeIngredient():
return $default(_that.ingredientID,_that.name,_that.quantity,_that.unitID,_that.unitName,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.calculatedWeightG,_that.preparation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ingredientID,  String name,  double quantity,  String unitID,  String unitName,  NutritionInfo? nutritionPer100g,  double? densityGPerMl,  double? avgWeightG,  double? calculatedWeightG,  String? preparation)?  $default,) {final _that = this;
switch (_that) {
case _RecipeIngredient() when $default != null:
return $default(_that.ingredientID,_that.name,_that.quantity,_that.unitID,_that.unitName,_that.nutritionPer100g,_that.densityGPerMl,_that.avgWeightG,_that.calculatedWeightG,_that.preparation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeIngredient implements RecipeIngredient {
  const _RecipeIngredient({required this.ingredientID, required this.name, required this.quantity, required this.unitID, required this.unitName, this.nutritionPer100g, this.densityGPerMl, this.avgWeightG, this.calculatedWeightG, this.preparation});
  factory _RecipeIngredient.fromJson(Map<String, dynamic> json) => _$RecipeIngredientFromJson(json);

@override final  String ingredientID;
@override final  String name;
@override final  double quantity;
@override final  String unitID;
@override final  String unitName;
@override final  NutritionInfo? nutritionPer100g;
@override final  double? densityGPerMl;
@override final  double? avgWeightG;
@override final  double? calculatedWeightG;
@override final  String? preparation;

/// Create a copy of RecipeIngredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeIngredientCopyWith<_RecipeIngredient> get copyWith => __$RecipeIngredientCopyWithImpl<_RecipeIngredient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeIngredientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeIngredient&&(identical(other.ingredientID, ingredientID) || other.ingredientID == ingredientID)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitID, unitID) || other.unitID == unitID)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.nutritionPer100g, nutritionPer100g) || other.nutritionPer100g == nutritionPer100g)&&(identical(other.densityGPerMl, densityGPerMl) || other.densityGPerMl == densityGPerMl)&&(identical(other.avgWeightG, avgWeightG) || other.avgWeightG == avgWeightG)&&(identical(other.calculatedWeightG, calculatedWeightG) || other.calculatedWeightG == calculatedWeightG)&&(identical(other.preparation, preparation) || other.preparation == preparation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ingredientID,name,quantity,unitID,unitName,nutritionPer100g,densityGPerMl,avgWeightG,calculatedWeightG,preparation);

@override
String toString() {
  return 'RecipeIngredient(ingredientID: $ingredientID, name: $name, quantity: $quantity, unitID: $unitID, unitName: $unitName, nutritionPer100g: $nutritionPer100g, densityGPerMl: $densityGPerMl, avgWeightG: $avgWeightG, calculatedWeightG: $calculatedWeightG, preparation: $preparation)';
}


}

/// @nodoc
abstract mixin class _$RecipeIngredientCopyWith<$Res> implements $RecipeIngredientCopyWith<$Res> {
  factory _$RecipeIngredientCopyWith(_RecipeIngredient value, $Res Function(_RecipeIngredient) _then) = __$RecipeIngredientCopyWithImpl;
@override @useResult
$Res call({
 String ingredientID, String name, double quantity, String unitID, String unitName, NutritionInfo? nutritionPer100g, double? densityGPerMl, double? avgWeightG, double? calculatedWeightG, String? preparation
});


@override $NutritionInfoCopyWith<$Res>? get nutritionPer100g;

}
/// @nodoc
class __$RecipeIngredientCopyWithImpl<$Res>
    implements _$RecipeIngredientCopyWith<$Res> {
  __$RecipeIngredientCopyWithImpl(this._self, this._then);

  final _RecipeIngredient _self;
  final $Res Function(_RecipeIngredient) _then;

/// Create a copy of RecipeIngredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredientID = null,Object? name = null,Object? quantity = null,Object? unitID = null,Object? unitName = null,Object? nutritionPer100g = freezed,Object? densityGPerMl = freezed,Object? avgWeightG = freezed,Object? calculatedWeightG = freezed,Object? preparation = freezed,}) {
  return _then(_RecipeIngredient(
ingredientID: null == ingredientID ? _self.ingredientID : ingredientID // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitID: null == unitID ? _self.unitID : unitID // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,nutritionPer100g: freezed == nutritionPer100g ? _self.nutritionPer100g : nutritionPer100g // ignore: cast_nullable_to_non_nullable
as NutritionInfo?,densityGPerMl: freezed == densityGPerMl ? _self.densityGPerMl : densityGPerMl // ignore: cast_nullable_to_non_nullable
as double?,avgWeightG: freezed == avgWeightG ? _self.avgWeightG : avgWeightG // ignore: cast_nullable_to_non_nullable
as double?,calculatedWeightG: freezed == calculatedWeightG ? _self.calculatedWeightG : calculatedWeightG // ignore: cast_nullable_to_non_nullable
as double?,preparation: freezed == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RecipeIngredient
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
