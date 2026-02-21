// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Nutrition {

 String get id; String get unitId; String get name; String get description; double get recommendedDailyValue;
/// Create a copy of Nutrition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionCopyWith<Nutrition> get copyWith => _$NutritionCopyWithImpl<Nutrition>(this as Nutrition, _$identity);

  /// Serializes this Nutrition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Nutrition&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.recommendedDailyValue, recommendedDailyValue) || other.recommendedDailyValue == recommendedDailyValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,name,description,recommendedDailyValue);

@override
String toString() {
  return 'Nutrition(id: $id, unitId: $unitId, name: $name, description: $description, recommendedDailyValue: $recommendedDailyValue)';
}


}

/// @nodoc
abstract mixin class $NutritionCopyWith<$Res>  {
  factory $NutritionCopyWith(Nutrition value, $Res Function(Nutrition) _then) = _$NutritionCopyWithImpl;
@useResult
$Res call({
 String id, String unitId, String name, String description, double recommendedDailyValue
});




}
/// @nodoc
class _$NutritionCopyWithImpl<$Res>
    implements $NutritionCopyWith<$Res> {
  _$NutritionCopyWithImpl(this._self, this._then);

  final Nutrition _self;
  final $Res Function(Nutrition) _then;

/// Create a copy of Nutrition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? unitId = null,Object? name = null,Object? description = null,Object? recommendedDailyValue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,recommendedDailyValue: null == recommendedDailyValue ? _self.recommendedDailyValue : recommendedDailyValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Nutrition].
extension NutritionPatterns on Nutrition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Nutrition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Nutrition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Nutrition value)  $default,){
final _that = this;
switch (_that) {
case _Nutrition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Nutrition value)?  $default,){
final _that = this;
switch (_that) {
case _Nutrition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String unitId,  String name,  String description,  double recommendedDailyValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Nutrition() when $default != null:
return $default(_that.id,_that.unitId,_that.name,_that.description,_that.recommendedDailyValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String unitId,  String name,  String description,  double recommendedDailyValue)  $default,) {final _that = this;
switch (_that) {
case _Nutrition():
return $default(_that.id,_that.unitId,_that.name,_that.description,_that.recommendedDailyValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String unitId,  String name,  String description,  double recommendedDailyValue)?  $default,) {final _that = this;
switch (_that) {
case _Nutrition() when $default != null:
return $default(_that.id,_that.unitId,_that.name,_that.description,_that.recommendedDailyValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Nutrition implements Nutrition {
  const _Nutrition({required this.id, required this.unitId, required this.name, required this.description, required this.recommendedDailyValue});
  factory _Nutrition.fromJson(Map<String, dynamic> json) => _$NutritionFromJson(json);

@override final  String id;
@override final  String unitId;
@override final  String name;
@override final  String description;
@override final  double recommendedDailyValue;

/// Create a copy of Nutrition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionCopyWith<_Nutrition> get copyWith => __$NutritionCopyWithImpl<_Nutrition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NutritionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Nutrition&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.recommendedDailyValue, recommendedDailyValue) || other.recommendedDailyValue == recommendedDailyValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,name,description,recommendedDailyValue);

@override
String toString() {
  return 'Nutrition(id: $id, unitId: $unitId, name: $name, description: $description, recommendedDailyValue: $recommendedDailyValue)';
}


}

/// @nodoc
abstract mixin class _$NutritionCopyWith<$Res> implements $NutritionCopyWith<$Res> {
  factory _$NutritionCopyWith(_Nutrition value, $Res Function(_Nutrition) _then) = __$NutritionCopyWithImpl;
@override @useResult
$Res call({
 String id, String unitId, String name, String description, double recommendedDailyValue
});




}
/// @nodoc
class __$NutritionCopyWithImpl<$Res>
    implements _$NutritionCopyWith<$Res> {
  __$NutritionCopyWithImpl(this._self, this._then);

  final _Nutrition _self;
  final $Res Function(_Nutrition) _then;

/// Create a copy of Nutrition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? unitId = null,Object? name = null,Object? description = null,Object? recommendedDailyValue = null,}) {
  return _then(_Nutrition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,recommendedDailyValue: null == recommendedDailyValue ? _self.recommendedDailyValue : recommendedDailyValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
