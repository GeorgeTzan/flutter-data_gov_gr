// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_limit_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RateLimitStatus _$RateLimitStatusFromJson(Map<String, dynamic> json) {
  return _RateLimitStatus.fromJson(json);
}

/// @nodoc
mixin _$RateLimitStatus {
  /// The number of requests remaining in the current window.
  int get remaining => throw _privateConstructorUsedError;

  /// The maximum number of requests allowed in a window.
  int get limit => throw _privateConstructorUsedError;

  /// The time when the rate limit window will reset.
  DateTime get resetTime => throw _privateConstructorUsedError;

  /// Serializes this RateLimitStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RateLimitStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RateLimitStatusCopyWith<RateLimitStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateLimitStatusCopyWith<$Res> {
  factory $RateLimitStatusCopyWith(
          RateLimitStatus value, $Res Function(RateLimitStatus) then) =
      _$RateLimitStatusCopyWithImpl<$Res, RateLimitStatus>;
  @useResult
  $Res call({int remaining, int limit, DateTime resetTime});
}

/// @nodoc
class _$RateLimitStatusCopyWithImpl<$Res, $Val extends RateLimitStatus>
    implements $RateLimitStatusCopyWith<$Res> {
  _$RateLimitStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RateLimitStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remaining = null,
    Object? limit = null,
    Object? resetTime = null,
  }) {
    return _then(_value.copyWith(
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      resetTime: null == resetTime
          ? _value.resetTime
          : resetTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RateLimitStatusImplCopyWith<$Res>
    implements $RateLimitStatusCopyWith<$Res> {
  factory _$$RateLimitStatusImplCopyWith(_$RateLimitStatusImpl value,
          $Res Function(_$RateLimitStatusImpl) then) =
      __$$RateLimitStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int remaining, int limit, DateTime resetTime});
}

/// @nodoc
class __$$RateLimitStatusImplCopyWithImpl<$Res>
    extends _$RateLimitStatusCopyWithImpl<$Res, _$RateLimitStatusImpl>
    implements _$$RateLimitStatusImplCopyWith<$Res> {
  __$$RateLimitStatusImplCopyWithImpl(
      _$RateLimitStatusImpl _value, $Res Function(_$RateLimitStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of RateLimitStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remaining = null,
    Object? limit = null,
    Object? resetTime = null,
  }) {
    return _then(_$RateLimitStatusImpl(
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      resetTime: null == resetTime
          ? _value.resetTime
          : resetTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RateLimitStatusImpl implements _RateLimitStatus {
  const _$RateLimitStatusImpl(
      {required this.remaining, required this.limit, required this.resetTime});

  factory _$RateLimitStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$RateLimitStatusImplFromJson(json);

  /// The number of requests remaining in the current window.
  @override
  final int remaining;

  /// The maximum number of requests allowed in a window.
  @override
  final int limit;

  /// The time when the rate limit window will reset.
  @override
  final DateTime resetTime;

  @override
  String toString() {
    return 'RateLimitStatus(remaining: $remaining, limit: $limit, resetTime: $resetTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitStatusImpl &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.resetTime, resetTime) ||
                other.resetTime == resetTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, remaining, limit, resetTime);

  /// Create a copy of RateLimitStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitStatusImplCopyWith<_$RateLimitStatusImpl> get copyWith =>
      __$$RateLimitStatusImplCopyWithImpl<_$RateLimitStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RateLimitStatusImplToJson(
      this,
    );
  }
}

abstract class _RateLimitStatus implements RateLimitStatus {
  const factory _RateLimitStatus(
      {required final int remaining,
      required final int limit,
      required final DateTime resetTime}) = _$RateLimitStatusImpl;

  factory _RateLimitStatus.fromJson(Map<String, dynamic> json) =
      _$RateLimitStatusImpl.fromJson;

  /// The number of requests remaining in the current window.
  @override
  int get remaining;

  /// The maximum number of requests allowed in a window.
  @override
  int get limit;

  /// The time when the rate limit window will reset.
  @override
  DateTime get resetTime;

  /// Create a copy of RateLimitStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitStatusImplCopyWith<_$RateLimitStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
