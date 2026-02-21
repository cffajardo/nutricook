// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'techniques.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Technique {

 String get id; String get name; String? get description; List<String> get mediaIDs;
/// Create a copy of Technique
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TechniqueCopyWith<Technique> get copyWith => _$TechniqueCopyWithImpl<Technique>(this as Technique, _$identity);

  /// Serializes this Technique to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Technique&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.mediaIDs, mediaIDs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(mediaIDs));

@override
String toString() {
  return 'Technique(id: $id, name: $name, description: $description, mediaIDs: $mediaIDs)';
}


}

/// @nodoc
abstract mixin class $TechniqueCopyWith<$Res>  {
  factory $TechniqueCopyWith(Technique value, $Res Function(Technique) _then) = _$TechniqueCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, List<String> mediaIDs
});




}
/// @nodoc
class _$TechniqueCopyWithImpl<$Res>
    implements $TechniqueCopyWith<$Res> {
  _$TechniqueCopyWithImpl(this._self, this._then);

  final Technique _self;
  final $Res Function(Technique) _then;

/// Create a copy of Technique
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? mediaIDs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mediaIDs: null == mediaIDs ? _self.mediaIDs : mediaIDs // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Technique].
extension TechniquePatterns on Technique {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Technique value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Technique() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Technique value)  $default,){
final _that = this;
switch (_that) {
case _Technique():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Technique value)?  $default,){
final _that = this;
switch (_that) {
case _Technique() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  List<String> mediaIDs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Technique() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.mediaIDs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  List<String> mediaIDs)  $default,) {final _that = this;
switch (_that) {
case _Technique():
return $default(_that.id,_that.name,_that.description,_that.mediaIDs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  List<String> mediaIDs)?  $default,) {final _that = this;
switch (_that) {
case _Technique() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.mediaIDs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Technique implements Technique {
  const _Technique({required this.id, required this.name, this.description, final  List<String> mediaIDs = const <String>[]}): _mediaIDs = mediaIDs;
  factory _Technique.fromJson(Map<String, dynamic> json) => _$TechniqueFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
 final  List<String> _mediaIDs;
@override@JsonKey() List<String> get mediaIDs {
  if (_mediaIDs is EqualUnmodifiableListView) return _mediaIDs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaIDs);
}


/// Create a copy of Technique
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TechniqueCopyWith<_Technique> get copyWith => __$TechniqueCopyWithImpl<_Technique>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TechniqueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Technique&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._mediaIDs, _mediaIDs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_mediaIDs));

@override
String toString() {
  return 'Technique(id: $id, name: $name, description: $description, mediaIDs: $mediaIDs)';
}


}

/// @nodoc
abstract mixin class _$TechniqueCopyWith<$Res> implements $TechniqueCopyWith<$Res> {
  factory _$TechniqueCopyWith(_Technique value, $Res Function(_Technique) _then) = __$TechniqueCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, List<String> mediaIDs
});




}
/// @nodoc
class __$TechniqueCopyWithImpl<$Res>
    implements _$TechniqueCopyWith<$Res> {
  __$TechniqueCopyWithImpl(this._self, this._then);

  final _Technique _self;
  final $Res Function(_Technique) _then;

/// Create a copy of Technique
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? mediaIDs = null,}) {
  return _then(_Technique(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mediaIDs: null == mediaIDs ? _self._mediaIDs : mediaIDs // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
