// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipeReport {

 String get id; String get recipeId; String get reporterId; String get reason; String? get details; String get status; String? get reviewedBy; String? get reviewNote;@TimestampConverter() DateTime? get reviewedAt;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of RecipeReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeReportCopyWith<RecipeReport> get copyWith => _$RecipeReportCopyWithImpl<RecipeReport>(this as RecipeReport, _$identity);

  /// Serializes this RecipeReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeReport&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.details, details) || other.details == details)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipeId,reporterId,reason,details,status,reviewedBy,reviewNote,reviewedAt,createdAt,updatedAt);

@override
String toString() {
  return 'RecipeReport(id: $id, recipeId: $recipeId, reporterId: $reporterId, reason: $reason, details: $details, status: $status, reviewedBy: $reviewedBy, reviewNote: $reviewNote, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RecipeReportCopyWith<$Res>  {
  factory $RecipeReportCopyWith(RecipeReport value, $Res Function(RecipeReport) _then) = _$RecipeReportCopyWithImpl;
@useResult
$Res call({
 String id, String recipeId, String reporterId, String reason, String? details, String status, String? reviewedBy, String? reviewNote,@TimestampConverter() DateTime? reviewedAt,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$RecipeReportCopyWithImpl<$Res>
    implements $RecipeReportCopyWith<$Res> {
  _$RecipeReportCopyWithImpl(this._self, this._then);

  final RecipeReport _self;
  final $Res Function(RecipeReport) _then;

/// Create a copy of RecipeReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipeId = null,Object? reporterId = null,Object? reason = null,Object? details = freezed,Object? status = null,Object? reviewedBy = freezed,Object? reviewNote = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeReport].
extension RecipeReportPatterns on RecipeReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeReport value)  $default,){
final _that = this;
switch (_that) {
case _RecipeReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeReport value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String recipeId,  String reporterId,  String reason,  String? details,  String status,  String? reviewedBy,  String? reviewNote, @TimestampConverter()  DateTime? reviewedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeReport() when $default != null:
return $default(_that.id,_that.recipeId,_that.reporterId,_that.reason,_that.details,_that.status,_that.reviewedBy,_that.reviewNote,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String recipeId,  String reporterId,  String reason,  String? details,  String status,  String? reviewedBy,  String? reviewNote, @TimestampConverter()  DateTime? reviewedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RecipeReport():
return $default(_that.id,_that.recipeId,_that.reporterId,_that.reason,_that.details,_that.status,_that.reviewedBy,_that.reviewNote,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String recipeId,  String reporterId,  String reason,  String? details,  String status,  String? reviewedBy,  String? reviewNote, @TimestampConverter()  DateTime? reviewedAt, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecipeReport() when $default != null:
return $default(_that.id,_that.recipeId,_that.reporterId,_that.reason,_that.details,_that.status,_that.reviewedBy,_that.reviewNote,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeReport implements RecipeReport {
  const _RecipeReport({required this.id, required this.recipeId, required this.reporterId, required this.reason, this.details, this.status = 'open', this.reviewedBy, this.reviewNote, @TimestampConverter() this.reviewedAt, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt});
  factory _RecipeReport.fromJson(Map<String, dynamic> json) => _$RecipeReportFromJson(json);

@override final  String id;
@override final  String recipeId;
@override final  String reporterId;
@override final  String reason;
@override final  String? details;
@override@JsonKey() final  String status;
@override final  String? reviewedBy;
@override final  String? reviewNote;
@override@TimestampConverter() final  DateTime? reviewedAt;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of RecipeReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeReportCopyWith<_RecipeReport> get copyWith => __$RecipeReportCopyWithImpl<_RecipeReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeReport&&(identical(other.id, id) || other.id == id)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.details, details) || other.details == details)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipeId,reporterId,reason,details,status,reviewedBy,reviewNote,reviewedAt,createdAt,updatedAt);

@override
String toString() {
  return 'RecipeReport(id: $id, recipeId: $recipeId, reporterId: $reporterId, reason: $reason, details: $details, status: $status, reviewedBy: $reviewedBy, reviewNote: $reviewNote, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RecipeReportCopyWith<$Res> implements $RecipeReportCopyWith<$Res> {
  factory _$RecipeReportCopyWith(_RecipeReport value, $Res Function(_RecipeReport) _then) = __$RecipeReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String recipeId, String reporterId, String reason, String? details, String status, String? reviewedBy, String? reviewNote,@TimestampConverter() DateTime? reviewedAt,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$RecipeReportCopyWithImpl<$Res>
    implements _$RecipeReportCopyWith<$Res> {
  __$RecipeReportCopyWithImpl(this._self, this._then);

  final _RecipeReport _self;
  final $Res Function(_RecipeReport) _then;

/// Create a copy of RecipeReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipeId = null,Object? reporterId = null,Object? reason = null,Object? details = freezed,Object? status = null,Object? reviewedBy = freezed,Object? reviewNote = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_RecipeReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
