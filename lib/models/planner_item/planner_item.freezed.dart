// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planner_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlannerItem {

 String get id; String get ownerId;@TimestampConverter() DateTime get date;@TimestampConverter() DateTime get createdAt; String get mealType; String get recipeId; String get recipeName; String? get thumbnailUrl; double get servingMultiplier; int get prepTime; int get cookTime; String? get notes; bool get isCompleted;
/// Create a copy of PlannerItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannerItemCopyWith<PlannerItem> get copyWith => _$PlannerItemCopyWithImpl<PlannerItem>(this as PlannerItem, _$identity);

  /// Serializes this PlannerItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannerItem&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.servingMultiplier, servingMultiplier) || other.servingMultiplier == servingMultiplier)&&(identical(other.prepTime, prepTime) || other.prepTime == prepTime)&&(identical(other.cookTime, cookTime) || other.cookTime == cookTime)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,date,createdAt,mealType,recipeId,recipeName,thumbnailUrl,servingMultiplier,prepTime,cookTime,notes,isCompleted);

@override
String toString() {
  return 'PlannerItem(id: $id, ownerId: $ownerId, date: $date, createdAt: $createdAt, mealType: $mealType, recipeId: $recipeId, recipeName: $recipeName, thumbnailUrl: $thumbnailUrl, servingMultiplier: $servingMultiplier, prepTime: $prepTime, cookTime: $cookTime, notes: $notes, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $PlannerItemCopyWith<$Res>  {
  factory $PlannerItemCopyWith(PlannerItem value, $Res Function(PlannerItem) _then) = _$PlannerItemCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId,@TimestampConverter() DateTime date,@TimestampConverter() DateTime createdAt, String mealType, String recipeId, String recipeName, String? thumbnailUrl, double servingMultiplier, int prepTime, int cookTime, String? notes, bool isCompleted
});




}
/// @nodoc
class _$PlannerItemCopyWithImpl<$Res>
    implements $PlannerItemCopyWith<$Res> {
  _$PlannerItemCopyWithImpl(this._self, this._then);

  final PlannerItem _self;
  final $Res Function(PlannerItem) _then;

/// Create a copy of PlannerItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? date = null,Object? createdAt = null,Object? mealType = null,Object? recipeId = null,Object? recipeName = null,Object? thumbnailUrl = freezed,Object? servingMultiplier = null,Object? prepTime = null,Object? cookTime = null,Object? notes = freezed,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,servingMultiplier: null == servingMultiplier ? _self.servingMultiplier : servingMultiplier // ignore: cast_nullable_to_non_nullable
as double,prepTime: null == prepTime ? _self.prepTime : prepTime // ignore: cast_nullable_to_non_nullable
as int,cookTime: null == cookTime ? _self.cookTime : cookTime // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlannerItem].
extension PlannerItemPatterns on PlannerItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannerItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannerItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannerItem value)  $default,){
final _that = this;
switch (_that) {
case _PlannerItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannerItem value)?  $default,){
final _that = this;
switch (_that) {
case _PlannerItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId, @TimestampConverter()  DateTime date, @TimestampConverter()  DateTime createdAt,  String mealType,  String recipeId,  String recipeName,  String? thumbnailUrl,  double servingMultiplier,  int prepTime,  int cookTime,  String? notes,  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannerItem() when $default != null:
return $default(_that.id,_that.ownerId,_that.date,_that.createdAt,_that.mealType,_that.recipeId,_that.recipeName,_that.thumbnailUrl,_that.servingMultiplier,_that.prepTime,_that.cookTime,_that.notes,_that.isCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId, @TimestampConverter()  DateTime date, @TimestampConverter()  DateTime createdAt,  String mealType,  String recipeId,  String recipeName,  String? thumbnailUrl,  double servingMultiplier,  int prepTime,  int cookTime,  String? notes,  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _PlannerItem():
return $default(_that.id,_that.ownerId,_that.date,_that.createdAt,_that.mealType,_that.recipeId,_that.recipeName,_that.thumbnailUrl,_that.servingMultiplier,_that.prepTime,_that.cookTime,_that.notes,_that.isCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId, @TimestampConverter()  DateTime date, @TimestampConverter()  DateTime createdAt,  String mealType,  String recipeId,  String recipeName,  String? thumbnailUrl,  double servingMultiplier,  int prepTime,  int cookTime,  String? notes,  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _PlannerItem() when $default != null:
return $default(_that.id,_that.ownerId,_that.date,_that.createdAt,_that.mealType,_that.recipeId,_that.recipeName,_that.thumbnailUrl,_that.servingMultiplier,_that.prepTime,_that.cookTime,_that.notes,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlannerItem implements PlannerItem {
  const _PlannerItem({required this.id, required this.ownerId, @TimestampConverter() required this.date, @TimestampConverter() required this.createdAt, required this.mealType, required this.recipeId, required this.recipeName, this.thumbnailUrl, required this.servingMultiplier, required this.prepTime, required this.cookTime, this.notes, this.isCompleted = false});
  factory _PlannerItem.fromJson(Map<String, dynamic> json) => _$PlannerItemFromJson(json);

@override final  String id;
@override final  String ownerId;
@override@TimestampConverter() final  DateTime date;
@override@TimestampConverter() final  DateTime createdAt;
@override final  String mealType;
@override final  String recipeId;
@override final  String recipeName;
@override final  String? thumbnailUrl;
@override final  double servingMultiplier;
@override final  int prepTime;
@override final  int cookTime;
@override final  String? notes;
@override@JsonKey() final  bool isCompleted;

/// Create a copy of PlannerItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannerItemCopyWith<_PlannerItem> get copyWith => __$PlannerItemCopyWithImpl<_PlannerItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlannerItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannerItem&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.servingMultiplier, servingMultiplier) || other.servingMultiplier == servingMultiplier)&&(identical(other.prepTime, prepTime) || other.prepTime == prepTime)&&(identical(other.cookTime, cookTime) || other.cookTime == cookTime)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,date,createdAt,mealType,recipeId,recipeName,thumbnailUrl,servingMultiplier,prepTime,cookTime,notes,isCompleted);

@override
String toString() {
  return 'PlannerItem(id: $id, ownerId: $ownerId, date: $date, createdAt: $createdAt, mealType: $mealType, recipeId: $recipeId, recipeName: $recipeName, thumbnailUrl: $thumbnailUrl, servingMultiplier: $servingMultiplier, prepTime: $prepTime, cookTime: $cookTime, notes: $notes, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$PlannerItemCopyWith<$Res> implements $PlannerItemCopyWith<$Res> {
  factory _$PlannerItemCopyWith(_PlannerItem value, $Res Function(_PlannerItem) _then) = __$PlannerItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId,@TimestampConverter() DateTime date,@TimestampConverter() DateTime createdAt, String mealType, String recipeId, String recipeName, String? thumbnailUrl, double servingMultiplier, int prepTime, int cookTime, String? notes, bool isCompleted
});




}
/// @nodoc
class __$PlannerItemCopyWithImpl<$Res>
    implements _$PlannerItemCopyWith<$Res> {
  __$PlannerItemCopyWithImpl(this._self, this._then);

  final _PlannerItem _self;
  final $Res Function(_PlannerItem) _then;

/// Create a copy of PlannerItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? date = null,Object? createdAt = null,Object? mealType = null,Object? recipeId = null,Object? recipeName = null,Object? thumbnailUrl = freezed,Object? servingMultiplier = null,Object? prepTime = null,Object? cookTime = null,Object? notes = freezed,Object? isCompleted = null,}) {
  return _then(_PlannerItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,servingMultiplier: null == servingMultiplier ? _self.servingMultiplier : servingMultiplier // ignore: cast_nullable_to_non_nullable
as double,prepTime: null == prepTime ? _self.prepTime : prepTime // ignore: cast_nullable_to_non_nullable
as int,cookTime: null == cookTime ? _self.cookTime : cookTime // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
