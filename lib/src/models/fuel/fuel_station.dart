import 'package:freezed_annotation/freezed_annotation.dart';
import 'fuel_type.dart';
import '../shared/prefecture.dart';

part 'fuel_station.freezed.dart';
part 'fuel_station.g.dart';

/// Represents a fuel station and the price of a specific fuel type.
@freezed
class FuelStation with _$FuelStation {
  /// Creates a new [FuelStation] instance.
  const factory FuelStation({
    /// The unique identifier of the fuel station.
    @JsonKey(name: 'station_id') required String stationId,

    /// The brand/owner name of the fuel station (e.g. Shell, BP).
    required String brand,

    /// The street address of the fuel station.
    required String address,

    /// The municipality where the fuel station is located.
    required String municipality,

    /// The prefecture (region) of the fuel station.
    @PrefectureConverter() required Prefecture prefecture,

    /// The latitude coordinate of the fuel station location.
    required double latitude,

    /// The longitude coordinate of the fuel station location.
    required double longitude,

    /// The normalized type of fuel.
    @FuelTypeConverter() @JsonKey(name: 'fuel_type') required FuelType fuelType,

    /// The raw string representation of the fuel type as returned by the API.
    @JsonKey(name: 'raw_fuel_type') required String rawFuelType,

    /// The price of the fuel.
    @JsonKey(name: 'fuel_price') required double price,

    /// The date when the fuel price was last updated.
    required DateTime date,
  }) = _FuelStation;

  /// Creates a [FuelStation] from a JSON map.
  factory FuelStation.fromJson(Map<String, dynamic> json) =>
      _$FuelStationFromJson(_preProcess(json));

  static Map<String, dynamic> _preProcess(Map<String, dynamic> json) {
    final modifiedJson = Map<String, dynamic>.from(json);
    modifiedJson['raw_fuel_type'] = json['fuel_type'];
    return modifiedJson;
  }
}
