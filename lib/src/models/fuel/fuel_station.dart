import 'package:freezed_annotation/freezed_annotation.dart';
import 'fuel_type.dart';
import '../shared/prefecture.dart';

part 'fuel_station.freezed.dart';
part 'fuel_station.g.dart';

@freezed
class FuelStation with _$FuelStation {
  const factory FuelStation({
    @JsonKey(name: 'station_id') required String stationId,
    required String brand,
    required String address,
    required String municipality,
    @PrefectureConverter() required Prefecture prefecture,
    required double latitude,
    required double longitude,
    @FuelTypeConverter() @JsonKey(name: 'fuel_type') required FuelType fuelType,
    @JsonKey(name: 'raw_fuel_type') required String rawFuelType,
    @JsonKey(name: 'fuel_price') required double price,
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
