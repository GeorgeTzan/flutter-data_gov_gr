// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefecture_fuel_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrefectureFuelPriceImpl _$$PrefectureFuelPriceImplFromJson(
        Map<String, dynamic> json) =>
    _$PrefectureFuelPriceImpl(
      prefecture:
          const PrefectureConverter().fromJson(json['prefecture'] as String),
      fuelType: const FuelTypeConverter().fromJson(json['fuel_type'] as String),
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$PrefectureFuelPriceImplToJson(
        _$PrefectureFuelPriceImpl instance) =>
    <String, dynamic>{
      'prefecture': const PrefectureConverter().toJson(instance.prefecture),
      'fuel_type': const FuelTypeConverter().toJson(instance.fuelType),
      'min_price': instance.minPrice,
      'max_price': instance.maxPrice,
      'avg_price': instance.avgPrice,
      'date': instance.date.toIso8601String(),
    };
