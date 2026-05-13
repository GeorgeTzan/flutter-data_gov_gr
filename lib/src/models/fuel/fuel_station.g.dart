// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FuelStationImpl _$$FuelStationImplFromJson(Map<String, dynamic> json) =>
    _$FuelStationImpl(
      stationId: json['station_id'] as String,
      brand: json['brand'] as String,
      address: json['address'] as String,
      municipality: json['municipality'] as String,
      prefecture:
          const PrefectureConverter().fromJson(json['prefecture'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      fuelType: const FuelTypeConverter().fromJson(json['fuel_type'] as String),
      rawFuelType: json['raw_fuel_type'] as String,
      price: (json['fuel_price'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$FuelStationImplToJson(_$FuelStationImpl instance) =>
    <String, dynamic>{
      'station_id': instance.stationId,
      'brand': instance.brand,
      'address': instance.address,
      'municipality': instance.municipality,
      'prefecture': const PrefectureConverter().toJson(instance.prefecture),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'fuel_type': const FuelTypeConverter().toJson(instance.fuelType),
      'raw_fuel_type': instance.rawFuelType,
      'fuel_price': instance.price,
      'date': instance.date.toIso8601String(),
    };
