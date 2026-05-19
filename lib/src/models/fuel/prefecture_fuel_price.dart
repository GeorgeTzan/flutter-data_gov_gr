import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/prefecture.dart';
import 'fuel_type.dart';

part 'prefecture_fuel_price.freezed.dart';
part 'prefecture_fuel_price.g.dart';

@freezed
class PrefectureFuelPrice with _$PrefectureFuelPrice {
  const factory PrefectureFuelPrice({
    @PrefectureConverter() required Prefecture prefecture,
    @FuelTypeConverter() @JsonKey(name: 'fuel_type') required FuelType fuelType,
    @JsonKey(name: 'min_price') required double minPrice,
    @JsonKey(name: 'max_price') required double maxPrice,
    @JsonKey(name: 'avg_price') required double avgPrice,
    required DateTime date,
  }) = _PrefectureFuelPrice;

  factory PrefectureFuelPrice.fromJson(Map<String, dynamic> json) =>
      _$PrefectureFuelPriceFromJson(json);
}
