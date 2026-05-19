// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prefecture_fuel_price.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PrefectureFuelPrice _$PrefectureFuelPriceFromJson(Map<String, dynamic> json) {
  return _PrefectureFuelPrice.fromJson(json);
}

/// @nodoc
mixin _$PrefectureFuelPrice {
  @PrefectureConverter()
  Prefecture get prefecture => throw _privateConstructorUsedError;
  @FuelTypeConverter()
  @JsonKey(name: 'fuel_type')
  FuelType get fuelType => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_price')
  double get minPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_price')
  double get maxPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_price')
  double get avgPrice => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Serializes this PrefectureFuelPrice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrefectureFuelPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrefectureFuelPriceCopyWith<PrefectureFuelPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrefectureFuelPriceCopyWith<$Res> {
  factory $PrefectureFuelPriceCopyWith(
          PrefectureFuelPrice value, $Res Function(PrefectureFuelPrice) then) =
      _$PrefectureFuelPriceCopyWithImpl<$Res, PrefectureFuelPrice>;
  @useResult
  $Res call(
      {@PrefectureConverter() Prefecture prefecture,
      @FuelTypeConverter() @JsonKey(name: 'fuel_type') FuelType fuelType,
      @JsonKey(name: 'min_price') double minPrice,
      @JsonKey(name: 'max_price') double maxPrice,
      @JsonKey(name: 'avg_price') double avgPrice,
      DateTime date});
}

/// @nodoc
class _$PrefectureFuelPriceCopyWithImpl<$Res, $Val extends PrefectureFuelPrice>
    implements $PrefectureFuelPriceCopyWith<$Res> {
  _$PrefectureFuelPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrefectureFuelPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prefecture = null,
    Object? fuelType = null,
    Object? minPrice = null,
    Object? maxPrice = null,
    Object? avgPrice = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      prefecture: null == prefecture
          ? _value.prefecture
          : prefecture // ignore: cast_nullable_to_non_nullable
              as Prefecture,
      fuelType: null == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as FuelType,
      minPrice: null == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double,
      maxPrice: null == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double,
      avgPrice: null == avgPrice
          ? _value.avgPrice
          : avgPrice // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrefectureFuelPriceImplCopyWith<$Res>
    implements $PrefectureFuelPriceCopyWith<$Res> {
  factory _$$PrefectureFuelPriceImplCopyWith(_$PrefectureFuelPriceImpl value,
          $Res Function(_$PrefectureFuelPriceImpl) then) =
      __$$PrefectureFuelPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@PrefectureConverter() Prefecture prefecture,
      @FuelTypeConverter() @JsonKey(name: 'fuel_type') FuelType fuelType,
      @JsonKey(name: 'min_price') double minPrice,
      @JsonKey(name: 'max_price') double maxPrice,
      @JsonKey(name: 'avg_price') double avgPrice,
      DateTime date});
}

/// @nodoc
class __$$PrefectureFuelPriceImplCopyWithImpl<$Res>
    extends _$PrefectureFuelPriceCopyWithImpl<$Res, _$PrefectureFuelPriceImpl>
    implements _$$PrefectureFuelPriceImplCopyWith<$Res> {
  __$$PrefectureFuelPriceImplCopyWithImpl(_$PrefectureFuelPriceImpl _value,
      $Res Function(_$PrefectureFuelPriceImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrefectureFuelPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prefecture = null,
    Object? fuelType = null,
    Object? minPrice = null,
    Object? maxPrice = null,
    Object? avgPrice = null,
    Object? date = null,
  }) {
    return _then(_$PrefectureFuelPriceImpl(
      prefecture: null == prefecture
          ? _value.prefecture
          : prefecture // ignore: cast_nullable_to_non_nullable
              as Prefecture,
      fuelType: null == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as FuelType,
      minPrice: null == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double,
      maxPrice: null == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double,
      avgPrice: null == avgPrice
          ? _value.avgPrice
          : avgPrice // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrefectureFuelPriceImpl implements _PrefectureFuelPrice {
  const _$PrefectureFuelPriceImpl(
      {@PrefectureConverter() required this.prefecture,
      @FuelTypeConverter() @JsonKey(name: 'fuel_type') required this.fuelType,
      @JsonKey(name: 'min_price') required this.minPrice,
      @JsonKey(name: 'max_price') required this.maxPrice,
      @JsonKey(name: 'avg_price') required this.avgPrice,
      required this.date});

  factory _$PrefectureFuelPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrefectureFuelPriceImplFromJson(json);

  @override
  @PrefectureConverter()
  final Prefecture prefecture;
  @override
  @FuelTypeConverter()
  @JsonKey(name: 'fuel_type')
  final FuelType fuelType;
  @override
  @JsonKey(name: 'min_price')
  final double minPrice;
  @override
  @JsonKey(name: 'max_price')
  final double maxPrice;
  @override
  @JsonKey(name: 'avg_price')
  final double avgPrice;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'PrefectureFuelPrice(prefecture: $prefecture, fuelType: $fuelType, minPrice: $minPrice, maxPrice: $maxPrice, avgPrice: $avgPrice, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrefectureFuelPriceImpl &&
            (identical(other.prefecture, prefecture) ||
                other.prefecture == prefecture) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.avgPrice, avgPrice) ||
                other.avgPrice == avgPrice) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, prefecture, fuelType, minPrice, maxPrice, avgPrice, date);

  /// Create a copy of PrefectureFuelPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrefectureFuelPriceImplCopyWith<_$PrefectureFuelPriceImpl> get copyWith =>
      __$$PrefectureFuelPriceImplCopyWithImpl<_$PrefectureFuelPriceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrefectureFuelPriceImplToJson(
      this,
    );
  }
}

abstract class _PrefectureFuelPrice implements PrefectureFuelPrice {
  const factory _PrefectureFuelPrice(
      {@PrefectureConverter() required final Prefecture prefecture,
      @FuelTypeConverter()
      @JsonKey(name: 'fuel_type')
      required final FuelType fuelType,
      @JsonKey(name: 'min_price') required final double minPrice,
      @JsonKey(name: 'max_price') required final double maxPrice,
      @JsonKey(name: 'avg_price') required final double avgPrice,
      required final DateTime date}) = _$PrefectureFuelPriceImpl;

  factory _PrefectureFuelPrice.fromJson(Map<String, dynamic> json) =
      _$PrefectureFuelPriceImpl.fromJson;

  @override
  @PrefectureConverter()
  Prefecture get prefecture;
  @override
  @FuelTypeConverter()
  @JsonKey(name: 'fuel_type')
  FuelType get fuelType;
  @override
  @JsonKey(name: 'min_price')
  double get minPrice;
  @override
  @JsonKey(name: 'max_price')
  double get maxPrice;
  @override
  @JsonKey(name: 'avg_price')
  double get avgPrice;
  @override
  DateTime get date;

  /// Create a copy of PrefectureFuelPrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrefectureFuelPriceImplCopyWith<_$PrefectureFuelPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
