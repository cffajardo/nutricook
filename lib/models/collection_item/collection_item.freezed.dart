// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectionItem {

 String get id; String get collectionId; String get recipeId; String get recipeName; String? get thumbnailUrl; List<String> get tags; int get prepTime; int get cookTime; int get favoriteCount;@TimestampConverter() DateTime get addedAt; String? get notes; double get order;
/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionItemCopyWith<CollectionItem> get copyWith => _$CollectionItemCopyWithImpl<CollectionItem>(this as CollectionItem, _$identity);

  /// Serializes this CollectionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.prepTime, prepTime) || other.prepTime == prepTime)&&(identical(other.cookTime, cookTime) || other.cookTime == cookTime)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,collectionId,recipeId,recipeName,thumbnailUrl,const DeepCollectionEquality().hash(tags),prepTime,cookTime,favoriteCount,addedAt,notes,order);

@override
String toString() {
  return 'CollectionItem(id: $id, collectionId: $collectionId, recipeId: $recipeId, recipeName: $recipeName, thumbnailUrl: $thumbnailUrl, tags: $tags, prepTime: $prepTime, cookTime: $cookTime, favoriteCount: $favoriteCount, addedAt: $addedAt, notes: $notes, order: $order)';
}


}

/// @nodoc
abstract mixin class $CollectionItemCopyWith<$Res>  {
  factory $CollectionItemCopyWith(CollectionItem value, $Res Function(CollectionItem) _then) = _$CollectionItemCopyWithImpl;
@useResult
$Res call({
 String id, String collectionId, String recipeId, String recipeName, String? thumbnailUrl, List<String> tags, int prepTime, int cookTime, int favoriteCount,@TimestampConverter() DateTime addedAt, String? notes, double order
});




}
/// @nodoc
class _$CollectionItemCopyWithImpl<$Res>
    implements $CollectionItemCopyWith<$Res> {
  _$CollectionItemCopyWithImpl(this._self, this._then);

  final CollectionItem _self;
  final $Res Function(CollectionItem) _then;

/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? recipeId = null,Object? recipeName = null,Object? thumbnailUrl = freezed,Object? tags = null,Object? prepTime = null,Object? cookTime = null,Object? favoriteCount = null,Object? addedAt = null,Object? notes = freezed,Object? order = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,prepTime: null == prepTime ? _self.prepTime : prepTime // ignore: cast_nullable_to_non_nullable
as int,cookTime: null == cookTime ? _self.cookTime : cookTime // ignore: cast_nullable_to_non_nullable
as int,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionItem].
extension CollectionItemPatterns on CollectionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionItem value)  $default,){
final _that = this;
switch (_that) {
case _CollectionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionItem value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String collectionId,  String recipeId,  String recipeName,  String? thumbnailUrl,  List<String> tags,  int prepTime,  int cookTime,  int favoriteCount, @TimestampConverter()  DateTime addedAt,  String? notes,  double order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
return $default(_that.id,_that.collectionId,_that.recipeId,_that.recipeName,_that.thumbnailUrl,_that.tags,_that.prepTime,_that.cookTime,_that.favoriteCount,_that.addedAt,_that.notes,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String collectionId,  String recipeId,  String recipeName,  String? thumbnailUrl,  List<String> tags,  int prepTime,  int cookTime,  int favoriteCount, @TimestampConverter()  DateTime addedAt,  String? notes,  double order)  $default,) {final _that = this;
switch (_that) {
case _CollectionItem():
return $default(_that.id,_that.collectionId,_that.recipeId,_that.recipeName,_that.thumbnailUrl,_that.tags,_that.prepTime,_that.cookTime,_that.favoriteCount,_that.addedAt,_that.notes,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String collectionId,  String recipeId,  String recipeName,  String? thumbnailUrl,  List<String> tags,  int prepTime,  int cookTime,  int favoriteCount, @TimestampConverter()  DateTime addedAt,  String? notes,  double order)?  $default,) {final _that = this;
switch (_that) {
case _CollectionItem() when $default != null:
return $default(_that.id,_that.collectionId,_that.recipeId,_that.recipeName,_that.thumbnailUrl,_that.tags,_that.prepTime,_that.cookTime,_that.favoriteCount,_that.addedAt,_that.notes,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionItem implements CollectionItem {
  const _CollectionItem({required this.id, required this.collectionId, required this.recipeId, required this.recipeName, this.thumbnailUrl, final  List<String> tags = const <String>[], required this.prepTime, required this.cookTime, this.favoriteCount = 0, @TimestampConverter() required this.addedAt, this.notes, this.order = 0.0}): _tags = tags;
  factory _CollectionItem.fromJson(Map<String, dynamic> json) => _$CollectionItemFromJson(json);

@override final  String id;
@override final  String collectionId;
@override final  String recipeId;
@override final  String recipeName;
@override final  String? thumbnailUrl;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  int prepTime;
@override final  int cookTime;
@override@JsonKey() final  int favoriteCount;
@override@TimestampConverter() final  DateTime addedAt;
@override final  String? notes;
@override@JsonKey() final  double order;

/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionItemCopyWith<_CollectionItem> get copyWith => __$CollectionItemCopyWithImpl<_CollectionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.prepTime, prepTime) || other.prepTime == prepTime)&&(identical(other.cookTime, cookTime) || other.cookTime == cookTime)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,collectionId,recipeId,recipeName,thumbnailUrl,const DeepCollectionEquality().hash(_tags),prepTime,cookTime,favoriteCount,addedAt,notes,order);

@override
String toString() {
  return 'CollectionItem(id: $id, collectionId: $collectionId, recipeId: $recipeId, recipeName: $recipeName, thumbnailUrl: $thumbnailUrl, tags: $tags, prepTime: $prepTime, cookTime: $cookTime, favoriteCount: $favoriteCount, addedAt: $addedAt, notes: $notes, order: $order)';
}


}

/// @nodoc
abstract mixin class _$CollectionItemCopyWith<$Res> implements $CollectionItemCopyWith<$Res> {
  factory _$CollectionItemCopyWith(_CollectionItem value, $Res Function(_CollectionItem) _then) = __$CollectionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String collectionId, String recipeId, String recipeName, String? thumbnailUrl, List<String> tags, int prepTime, int cookTime, int favoriteCount,@TimestampConverter() DateTime addedAt, String? notes, double order
});




}
/// @nodoc
class __$CollectionItemCopyWithImpl<$Res>
    implements _$CollectionItemCopyWith<$Res> {
  __$CollectionItemCopyWithImpl(this._self, this._then);

  final _CollectionItem _self;
  final $Res Function(_CollectionItem) _then;

/// Create a copy of CollectionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? recipeId = null,Object? recipeName = null,Object? thumbnailUrl = freezed,Object? tags = null,Object? prepTime = null,Object? cookTime = null,Object? favoriteCount = null,Object? addedAt = null,Object? notes = freezed,Object? order = null,}) {
  return _then(_CollectionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,prepTime: null == prepTime ? _self.prepTime : prepTime // ignore: cast_nullable_to_non_nullable
as int,cookTime: null == cookTime ? _self.cookTime : cookTime // ignore: cast_nullable_to_non_nullable
as int,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
