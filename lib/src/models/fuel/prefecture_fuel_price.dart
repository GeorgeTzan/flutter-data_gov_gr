import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/prefecture.dart';
import 'fuel_type.dart';

part 'prefecture_fuel_price.freezed.dart';
part 'prefecture_fuel_price.g.dart';

/// Represents the minimum, maximum, and average fuel prices in a prefecture.
@freezed
class PrefectureFuelPrice with _$PrefectureFuelPrice {
  /// Creates a new [PrefectureFuelPrice] instance.
  const factory PrefectureFuelPrice({
    /// The prefecture (region) of the pricing statistics.
    @PrefectureConverter() required Prefecture prefecture,

    /// The type of fuel.
    @FuelTypeConverter() @JsonKey(name: 'fuel_type') required FuelType fuelType,

    /// The minimum recorded price for this fuel type in the prefecture.
    @JsonKey(name: 'min_price') required double minPrice,

    /// The maximum recorded price for this fuel type in the prefecture.
    @JsonKey(name: 'max_price') required double maxPrice,

    /// The average recorded price for this fuel type in the prefecture.
    @JsonKey(name: 'avg_price') required double avgPrice,

    /// The date when the pricing statistics were recorded.
    required DateTime date,
  }) = _PrefectureFuelPrice;

  /// Creates a [PrefectureFuelPrice] from a JSON map.
  factory PrefectureFuelPrice.fromJson(Map<String, dynamic> json) =>
      _$PrefectureFuelPriceFromJson(json);
}
