// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'internet_traffic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InternetTraffic _$InternetTrafficFromJson(Map<String, dynamic> json) {
  return _InternetTraffic.fromJson(json);
}

/// @nodoc
mixin _$InternetTraffic {
  DateTime get date => throw _privateConstructorUsedError;
  double get inbound => throw _privateConstructorUsedError;
  double get outbound => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_traffic')
  double get totalTraffic => throw _privateConstructorUsedError;

  /// Serializes this InternetTraffic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InternetTraffic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InternetTrafficCopyWith<InternetTraffic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InternetTrafficCopyWith<$Res> {
  factory $InternetTrafficCopyWith(
          InternetTraffic value, $Res Function(InternetTraffic) then) =
      _$InternetTrafficCopyWithImpl<$Res, InternetTraffic>;
  @useResult
  $Res call(
      {DateTime date,
      double inbound,
      double outbound,
      @JsonKey(name: 'total_traffic') double totalTraffic});
}

/// @nodoc
class _$InternetTrafficCopyWithImpl<$Res, $Val extends InternetTraffic>
    implements $InternetTrafficCopyWith<$Res> {
  _$InternetTrafficCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InternetTraffic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? inbound = null,
    Object? outbound = null,
    Object? totalTraffic = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inbound: null == inbound
          ? _value.inbound
          : inbound // ignore: cast_nullable_to_non_nullable
              as double,
      outbound: null == outbound
          ? _value.outbound
          : outbound // ignore: cast_nullable_to_non_nullable
              as double,
      totalTraffic: null == totalTraffic
          ? _value.totalTraffic
          : totalTraffic // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InternetTrafficImplCopyWith<$Res>
    implements $InternetTrafficCopyWith<$Res> {
  factory _$$InternetTrafficImplCopyWith(_$InternetTrafficImpl value,
          $Res Function(_$InternetTrafficImpl) then) =
      __$$InternetTrafficImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double inbound,
      double outbound,
      @JsonKey(name: 'total_traffic') double totalTraffic});
}

/// @nodoc
class __$$InternetTrafficImplCopyWithImpl<$Res>
    extends _$InternetTrafficCopyWithImpl<$Res, _$InternetTrafficImpl>
    implements _$$InternetTrafficImplCopyWith<$Res> {
  __$$InternetTrafficImplCopyWithImpl(
      _$InternetTrafficImpl _value, $Res Function(_$InternetTrafficImpl) _then)
      : super(_value, _then);

  /// Create a copy of InternetTraffic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? inbound = null,
    Object? outbound = null,
    Object? totalTraffic = null,
  }) {
    return _then(_$InternetTrafficImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inbound: null == inbound
          ? _value.inbound
          : inbound // ignore: cast_nullable_to_non_nullable
              as double,
      outbound: null == outbound
          ? _value.outbound
          : outbound // ignore: cast_nullable_to_non_nullable
              as double,
      totalTraffic: null == totalTraffic
          ? _value.totalTraffic
          : totalTraffic // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InternetTrafficImpl implements _InternetTraffic {
  const _$InternetTrafficImpl(
      {required this.date,
      required this.inbound,
      required this.outbound,
      @JsonKey(name: 'total_traffic') required this.totalTraffic});

  factory _$InternetTrafficImpl.fromJson(Map<String, dynamic> json) =>
      _$$InternetTrafficImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double inbound;
  @override
  final double outbound;
  @override
  @JsonKey(name: 'total_traffic')
  final double totalTraffic;

  @override
  String toString() {
    return 'InternetTraffic(date: $date, inbound: $inbound, outbound: $outbound, totalTraffic: $totalTraffic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InternetTrafficImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.inbound, inbound) || other.inbound == inbound) &&
            (identical(other.outbound, outbound) ||
                other.outbound == outbound) &&
            (identical(other.totalTraffic, totalTraffic) ||
                other.totalTraffic == totalTraffic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, inbound, outbound, totalTraffic);

  /// Create a copy of InternetTraffic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InternetTrafficImplCopyWith<_$InternetTrafficImpl> get copyWith =>
      __$$InternetTrafficImplCopyWithImpl<_$InternetTrafficImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InternetTrafficImplToJson(
      this,
    );
  }
}

abstract class _InternetTraffic implements InternetTraffic {
  const factory _InternetTraffic(
          {required final DateTime date,
          required final double inbound,
          required final double outbound,
          @JsonKey(name: 'total_traffic') required final double totalTraffic}) =
      _$InternetTrafficImpl;

  factory _InternetTraffic.fromJson(Map<String, dynamic> json) =
      _$InternetTrafficImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get inbound;
  @override
  double get outbound;
  @override
  @JsonKey(name: 'total_traffic')
  double get totalTraffic;

  /// Create a copy of InternetTraffic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InternetTrafficImplCopyWith<_$InternetTrafficImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
