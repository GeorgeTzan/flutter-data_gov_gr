// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_limit_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RateLimitStatus {

/// The maximum requests allowed in the current quota window.
 int? get limit;/// Requests remaining in the current quota window.
 int? get remaining;/// The published quota reset time, if available.
 DateTime? get resetAt;
/// Create a copy of RateLimitStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateLimitStatusCopyWith<RateLimitStatus> get copyWith => _$RateLimitStatusCopyWithImpl<RateLimitStatus>(this as RateLimitStatus, _$identity);

  /// Serializes this RateLimitStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateLimitStatus&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.resetAt, resetAt) || other.resetAt == resetAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,remaining,resetAt);

@override
String toString() {
  return 'RateLimitStatus(limit: $limit, remaining: $remaining, resetAt: $resetAt)';
}


}

/// @nodoc
abstract mixin class $RateLimitStatusCopyWith<$Res>  {
  factory $RateLimitStatusCopyWith(RateLimitStatus value, $Res Function(RateLimitStatus) _then) = _$RateLimitStatusCopyWithImpl;
@useResult
$Res call({
 int? limit, int? remaining, DateTime? resetAt
});




}
/// @nodoc
class _$RateLimitStatusCopyWithImpl<$Res>
    implements $RateLimitStatusCopyWith<$Res> {
  _$RateLimitStatusCopyWithImpl(this._self, this._then);

  final RateLimitStatus _self;
  final $Res Function(RateLimitStatus) _then;

/// Create a copy of RateLimitStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = freezed,Object? remaining = freezed,Object? resetAt = freezed,}) {
  return _then(_self.copyWith(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,resetAt: freezed == resetAt ? _self.resetAt : resetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RateLimitStatus].
extension RateLimitStatusPatterns on RateLimitStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RateLimitStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RateLimitStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RateLimitStatus value)  $default,){
final _that = this;
switch (_that) {
case _RateLimitStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RateLimitStatus value)?  $default,){
final _that = this;
switch (_that) {
case _RateLimitStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? limit,  int? remaining,  DateTime? resetAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RateLimitStatus() when $default != null:
return $default(_that.limit,_that.remaining,_that.resetAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? limit,  int? remaining,  DateTime? resetAt)  $default,) {final _that = this;
switch (_that) {
case _RateLimitStatus():
return $default(_that.limit,_that.remaining,_that.resetAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? limit,  int? remaining,  DateTime? resetAt)?  $default,) {final _that = this;
switch (_that) {
case _RateLimitStatus() when $default != null:
return $default(_that.limit,_that.remaining,_that.resetAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RateLimitStatus extends RateLimitStatus {
  const _RateLimitStatus({this.limit, this.remaining, this.resetAt}): super._();
  factory _RateLimitStatus.fromJson(Map<String, dynamic> json) => _$RateLimitStatusFromJson(json);

/// The maximum requests allowed in the current quota window.
@override final  int? limit;
/// Requests remaining in the current quota window.
@override final  int? remaining;
/// The published quota reset time, if available.
@override final  DateTime? resetAt;

/// Create a copy of RateLimitStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RateLimitStatusCopyWith<_RateLimitStatus> get copyWith => __$RateLimitStatusCopyWithImpl<_RateLimitStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RateLimitStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RateLimitStatus&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.resetAt, resetAt) || other.resetAt == resetAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,remaining,resetAt);

@override
String toString() {
  return 'RateLimitStatus(limit: $limit, remaining: $remaining, resetAt: $resetAt)';
}


}

/// @nodoc
abstract mixin class _$RateLimitStatusCopyWith<$Res> implements $RateLimitStatusCopyWith<$Res> {
  factory _$RateLimitStatusCopyWith(_RateLimitStatus value, $Res Function(_RateLimitStatus) _then) = __$RateLimitStatusCopyWithImpl;
@override @useResult
$Res call({
 int? limit, int? remaining, DateTime? resetAt
});




}
/// @nodoc
class __$RateLimitStatusCopyWithImpl<$Res>
    implements _$RateLimitStatusCopyWith<$Res> {
  __$RateLimitStatusCopyWithImpl(this._self, this._then);

  final _RateLimitStatus _self;
  final $Res Function(_RateLimitStatus) _then;

/// Create a copy of RateLimitStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = freezed,Object? remaining = freezed,Object? resetAt = freezed,}) {
  return _then(_RateLimitStatus(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,remaining: freezed == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int?,resetAt: freezed == resetAt ? _self.resetAt : resetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
