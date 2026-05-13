// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FuelStation _$FuelStationFromJson(Map<String, dynamic> json) {
  return _FuelStation.fromJson(json);
}

/// @nodoc
mixin _$FuelStation {
  @JsonKey(name: 'station_id')
  String get stationId => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get municipality => throw _privateConstructorUsedError;
  @PrefectureConverter()
  Prefecture get prefecture => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  @FuelTypeConverter()
  @JsonKey(name: 'fuel_type')
  FuelType get fuelType => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_fuel_type')
  String get rawFuelType => throw _privateConstructorUsedError;
  @JsonKey(name: 'fuel_price')
  double get price => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Serializes this FuelStation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FuelStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FuelStationCopyWith<FuelStation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FuelStationCopyWith<$Res> {
  factory $FuelStationCopyWith(
          FuelStation value, $Res Function(FuelStation) then) =
      _$FuelStationCopyWithImpl<$Res, FuelStation>;
  @useResult
  $Res call(
      {@JsonKey(name: 'station_id') String stationId,
      String brand,
      String address,
      String municipality,
      @PrefectureConverter() Prefecture prefecture,
      double latitude,
      double longitude,
      @FuelTypeConverter() @JsonKey(name: 'fuel_type') FuelType fuelType,
      @JsonKey(name: 'raw_fuel_type') String rawFuelType,
      @JsonKey(name: 'fuel_price') double price,
      DateTime date});
}

/// @nodoc
class _$FuelStationCopyWithImpl<$Res, $Val extends FuelStation>
    implements $FuelStationCopyWith<$Res> {
  _$FuelStationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FuelStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stationId = null,
    Object? brand = null,
    Object? address = null,
    Object? municipality = null,
    Object? prefecture = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? fuelType = null,
    Object? rawFuelType = null,
    Object? price = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      municipality: null == municipality
          ? _value.municipality
          : municipality // ignore: cast_nullable_to_non_nullable
              as String,
      prefecture: null == prefecture
          ? _value.prefecture
          : prefecture // ignore: cast_nullable_to_non_nullable
              as Prefecture,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      fuelType: null == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as FuelType,
      rawFuelType: null == rawFuelType
          ? _value.rawFuelType
          : rawFuelType // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FuelStationImplCopyWith<$Res>
    implements $FuelStationCopyWith<$Res> {
  factory _$$FuelStationImplCopyWith(
          _$FuelStationImpl value, $Res Function(_$FuelStationImpl) then) =
      __$$FuelStationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'station_id') String stationId,
      String brand,
      String address,
      String municipality,
      @PrefectureConverter() Prefecture prefecture,
      double latitude,
      double longitude,
      @FuelTypeConverter() @JsonKey(name: 'fuel_type') FuelType fuelType,
      @JsonKey(name: 'raw_fuel_type') String rawFuelType,
      @JsonKey(name: 'fuel_price') double price,
      DateTime date});
}

/// @nodoc
class __$$FuelStationImplCopyWithImpl<$Res>
    extends _$FuelStationCopyWithImpl<$Res, _$FuelStationImpl>
    implements _$$FuelStationImplCopyWith<$Res> {
  __$$FuelStationImplCopyWithImpl(
      _$FuelStationImpl _value, $Res Function(_$FuelStationImpl) _then)
      : super(_value, _then);

  /// Create a copy of FuelStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stationId = null,
    Object? brand = null,
    Object? address = null,
    Object? municipality = null,
    Object? prefecture = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? fuelType = null,
    Object? rawFuelType = null,
    Object? price = null,
    Object? date = null,
  }) {
    return _then(_$FuelStationImpl(
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      municipality: null == municipality
          ? _value.municipality
          : municipality // ignore: cast_nullable_to_non_nullable
              as String,
      prefecture: null == prefecture
          ? _value.prefecture
          : prefecture // ignore: cast_nullable_to_non_nullable
              as Prefecture,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      fuelType: null == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as FuelType,
      rawFuelType: null == rawFuelType
          ? _value.rawFuelType
          : rawFuelType // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
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
class _$FuelStationImpl implements _FuelStation {
  const _$FuelStationImpl(
      {@JsonKey(name: 'station_id') required this.stationId,
      required this.brand,
      required this.address,
      required this.municipality,
      @PrefectureConverter() required this.prefecture,
      required this.latitude,
      required this.longitude,
      @FuelTypeConverter() @JsonKey(name: 'fuel_type') required this.fuelType,
      @JsonKey(name: 'raw_fuel_type') required this.rawFuelType,
      @JsonKey(name: 'fuel_price') required this.price,
      required this.date});

  factory _$FuelStationImpl.fromJson(Map<String, dynamic> json) =>
      _$$FuelStationImplFromJson(json);

  @override
  @JsonKey(name: 'station_id')
  final String stationId;
  @override
  final String brand;
  @override
  final String address;
  @override
  final String municipality;
  @override
  @PrefectureConverter()
  final Prefecture prefecture;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  @FuelTypeConverter()
  @JsonKey(name: 'fuel_type')
  final FuelType fuelType;
  @override
  @JsonKey(name: 'raw_fuel_type')
  final String rawFuelType;
  @override
  @JsonKey(name: 'fuel_price')
  final double price;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'FuelStation(stationId: $stationId, brand: $brand, address: $address, municipality: $municipality, prefecture: $prefecture, latitude: $latitude, longitude: $longitude, fuelType: $fuelType, rawFuelType: $rawFuelType, price: $price, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FuelStationImpl &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.municipality, municipality) ||
                other.municipality == municipality) &&
            (identical(other.prefecture, prefecture) ||
                other.prefecture == prefecture) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.rawFuelType, rawFuelType) ||
                other.rawFuelType == rawFuelType) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stationId,
      brand,
      address,
      municipality,
      prefecture,
      latitude,
      longitude,
      fuelType,
      rawFuelType,
      price,
      date);

  /// Create a copy of FuelStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FuelStationImplCopyWith<_$FuelStationImpl> get copyWith =>
      __$$FuelStationImplCopyWithImpl<_$FuelStationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FuelStationImplToJson(
      this,
    );
  }
}

abstract class _FuelStation implements FuelStation {
  const factory _FuelStation(
      {@JsonKey(name: 'station_id') required final String stationId,
      required final String brand,
      required final String address,
      required final String municipality,
      @PrefectureConverter() required final Prefecture prefecture,
      required final double latitude,
      required final double longitude,
      @FuelTypeConverter()
      @JsonKey(name: 'fuel_type')
      required final FuelType fuelType,
      @JsonKey(name: 'raw_fuel_type') required final String rawFuelType,
      @JsonKey(name: 'fuel_price') required final double price,
      required final DateTime date}) = _$FuelStationImpl;

  factory _FuelStation.fromJson(Map<String, dynamic> json) =
      _$FuelStationImpl.fromJson;

  @override
  @JsonKey(name: 'station_id')
  String get stationId;
  @override
  String get brand;
  @override
  String get address;
  @override
  String get municipality;
  @override
  @PrefectureConverter()
  Prefecture get prefecture;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  @FuelTypeConverter()
  @JsonKey(name: 'fuel_type')
  FuelType get fuelType;
  @override
  @JsonKey(name: 'raw_fuel_type')
  String get rawFuelType;
  @override
  @JsonKey(name: 'fuel_price')
  double get price;
  @override
  DateTime get date;

  /// Create a copy of FuelStation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FuelStationImplCopyWith<_$FuelStationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
