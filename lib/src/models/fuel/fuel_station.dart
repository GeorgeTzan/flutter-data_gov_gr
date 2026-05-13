import 'package:freezed_annotation/freezed_annotation.dart';
import 'fuel_type.dart';
import '../shared/prefecture.dart';

part 'fuel_station.freezed.dart';
part 'fuel_station.g.dart';

/// Represents a gas station and its fuel pricing data.
@freezed
class FuelStation with _$FuelStation {
  const factory FuelStation({
    /// Unique identifier for the gas station.
    @JsonKey(name: 'station_id') required String stationId,

    /// Brand name of the station (e.g., Shell, BP).
    required String brand,

    /// Physical address of the station.
    required String address,

    /// The municipality where the station is located.
    required String municipality,

    /// The prefecture where the station is located.
    @PrefectureConverter() required Prefecture prefecture,

    /// GPS Latitude.
    required double latitude,

    /// GPS Longitude.
    required double longitude,

    /// The type of fuel.
    @FuelTypeConverter() @JsonKey(name: 'fuel_type') required FuelType fuelType,

    /// The original fuel type label from the API.
    @JsonKey(name: 'raw_fuel_type') required String rawFuelType,

    /// Price per liter.
    @JsonKey(name: 'fuel_price') required double price,

    /// Date of the price update.
    required DateTime date,
  }) = _FuelStation;

  factory FuelStation.fromJson(Map<String, dynamic> json) =>
      _$FuelStationFromJson(_preProcess(json));

  static Map<String, dynamic> _preProcess(Map<String, dynamic> json) {
    final modifiedJson = Map<String, dynamic>.from(json);
    modifiedJson['raw_fuel_type'] = json['fuel_type'];
    return modifiedJson;
  }
}
