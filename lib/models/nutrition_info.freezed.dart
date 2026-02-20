// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NutritionInfo {

 int get calories; double get carbohydrates; double get protein; double get fat; double get fiber; double get sugar; double get sodium;
/// Create a copy of NutritionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionInfoCopyWith<NutritionInfo> get copyWith => _$NutritionInfoCopyWithImpl<NutritionInfo>(this as NutritionInfo, _$identity);

  /// Serializes this NutritionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionInfo&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbohydrates, carbohydrates) || other.carbohydrates == carbohydrates)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugar, sugar) || other.sugar == sugar)&&(identical(other.sodium, sodium) || other.sodium == sodium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calories,carbohydrates,protein,fat,fiber,sugar,sodium);

@override
String toString() {
  return 'NutritionInfo(calories: $calories, carbohydrates: $carbohydrates, protein: $protein, fat: $fat, fiber: $fiber, sugar: $sugar, sodium: $sodium)';
}


}

/// @nodoc
abstract mixin class $NutritionInfoCopyWith<$Res>  {
  factory $NutritionInfoCopyWith(NutritionInfo value, $Res Function(NutritionInfo) _then) = _$NutritionInfoCopyWithImpl;
@useResult
$Res call({
 int calories, double carbohydrates, double protein, double fat, double fiber, double sugar, double sodium
});




}
/// @nodoc
class _$NutritionInfoCopyWithImpl<$Res>
    implements $NutritionInfoCopyWith<$Res> {
  _$NutritionInfoCopyWithImpl(this._self, this._then);

  final NutritionInfo _self;
  final $Res Function(NutritionInfo) _then;

/// Create a copy of NutritionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calories = null,Object? carbohydrates = null,Object? protein = null,Object? fat = null,Object? fiber = null,Object? sugar = null,Object? sodium = null,}) {
  return _then(_self.copyWith(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,carbohydrates: null == carbohydrates ? _self.carbohydrates : carbohydrates // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double,sugar: null == sugar ? _self.sugar : sugar // ignore: cast_nullable_to_non_nullable
as double,sodium: null == sodium ? _self.sodium : sodium // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NutritionInfo].
extension NutritionInfoPatterns on NutritionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionInfo value)  $default,){
final _that = this;
switch (_that) {
case _NutritionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int calories,  double carbohydrates,  double protein,  double fat,  double fiber,  double sugar,  double sodium)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionInfo() when $default != null:
return $default(_that.calories,_that.carbohydrates,_that.protein,_that.fat,_that.fiber,_that.sugar,_that.sodium);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int calories,  double carbohydrates,  double protein,  double fat,  double fiber,  double sugar,  double sodium)  $default,) {final _that = this;
switch (_that) {
case _NutritionInfo():
return $default(_that.calories,_that.carbohydrates,_that.protein,_that.fat,_that.fiber,_that.sugar,_that.sodium);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int calories,  double carbohydrates,  double protein,  double fat,  double fiber,  double sugar,  double sodium)?  $default,) {final _that = this;
switch (_that) {
case _NutritionInfo() when $default != null:
return $default(_that.calories,_that.carbohydrates,_that.protein,_that.fat,_that.fiber,_that.sugar,_that.sodium);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NutritionInfo implements NutritionInfo {
  const _NutritionInfo({required this.calories, required this.carbohydrates, required this.protein, required this.fat, required this.fiber, required this.sugar, required this.sodium});
  factory _NutritionInfo.fromJson(Map<String, dynamic> json) => _$NutritionInfoFromJson(json);

@override final  int calories;
@override final  double carbohydrates;
@override final  double protein;
@override final  double fat;
@override final  double fiber;
@override final  double sugar;
@override final  double sodium;

/// Create a copy of NutritionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionInfoCopyWith<_NutritionInfo> get copyWith => __$NutritionInfoCopyWithImpl<_NutritionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionInfo&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbohydrates, carbohydrates) || other.carbohydrates == carbohydrates)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugar, sugar) || other.sugar == sugar)&&(identical(other.sodium, sodium) || other.sodium == sodium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,calories,carbohydrates,protein,fat,fiber,sugar,sodium);

@override
String toString() {
  return 'NutritionInfo(calories: $calories, carbohydrates: $carbohydrates, protein: $protein, fat: $fat, fiber: $fiber, sugar: $sugar, sodium: $sodium)';
}


}

/// @nodoc
abstract mixin class _$NutritionInfoCopyWith<$Res> implements $NutritionInfoCopyWith<$Res> {
  factory _$NutritionInfoCopyWith(_NutritionInfo value, $Res Function(_NutritionInfo) _then) = __$NutritionInfoCopyWithImpl;
@override @useResult
$Res call({
 int calories, double carbohydrates, double protein, double fat, double fiber, double sugar, double sodium
});




}
/// @nodoc
class __$NutritionInfoCopyWithImpl<$Res>
    implements _$NutritionInfoCopyWith<$Res> {
  __$NutritionInfoCopyWithImpl(this._self, this._then);

  final _NutritionInfo _self;
  final $Res Function(_NutritionInfo) _then;

/// Create a copy of NutritionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calories = null,Object? carbohydrates = null,Object? protein = null,Object? fat = null,Object? fiber = null,Object? sugar = null,Object? sodium = null,}) {
  return _then(_NutritionInfo(
calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,carbohydrates: null == carbohydrates ? _self.carbohydrates : carbohydrates // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as double,sugar: null == sugar ? _self.sugar : sugar // ignore: cast_nullable_to_non_nullable
as double,sodium: null == sodium ? _self.sodium : sodium // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
