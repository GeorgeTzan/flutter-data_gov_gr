import '../client/data_gov_client.dart';
import '../models/fuel/fuel_station.dart';
import '../models/fuel/fuel_type.dart';
import '../models/fuel/prefecture_fuel_price.dart';
import '../models/shared/prefecture.dart';
import 'fuel_query_builder.dart';

/// A service for querying fuel station data and fuel price statistics from data.gov.gr.
class FuelService {
  final DataGovClient _client;

  /// Creates a new [FuelService] instance.
  FuelService(this._client);

  /// Returns a query builder to construct queries on fuel prices with fluent filters.
  FuelQueryBuilder query() => FuelQueryBuilder(this);

  /// Fetches detailed fuel prices per station, optionally filtered by date, prefecture, and fuel type.
  Future<List<FuelStation>> getGasPricesPerStation({
    DateTime? date,
    Prefecture? prefecture,
    FuelType? fuelType,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (date != null) {
      queryParameters['date'] = date.toIso8601String().split('T').first;
    }
    if (prefecture != null) {
      queryParameters['prefecture'] = prefecture.rawGreekName;
    }
    if (fuelType != null && fuelType != FuelType.unknown) {
      queryParameters['fuel_type'] = fuelType.rawGreekLabel;
    }

    final response = await _client.dio.get(
      'query/gas_price_per_station',
      queryParameters: queryParameters,
    );

    final data = response.data as List;
    return data.map((json) => FuelStation.fromJson(json)).toList();
  }

  /// Fetches prefecture-level min/max/average fuel prices, optionally filtered by date, prefecture, and fuel type.
  Future<List<PrefectureFuelPrice>> getPrefectureFuelPrices({
    DateTime? date,
    Prefecture? prefecture,
    FuelType? fuelType,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (date != null) {
      queryParameters['date'] = date.toIso8601String().split('T').first;
    }
    if (prefecture != null) {
      queryParameters['prefecture'] = prefecture.rawGreekName;
    }
    if (fuelType != null && fuelType != FuelType.unknown) {
      queryParameters['fuel_type'] = fuelType.rawGreekLabel;
    }

    final response = await _client.dio.get(
      'query/min_max_fuel_prices_per_prefecture',
      queryParameters: queryParameters,
    );

    final data = response.data as List;
    return data.map((json) => PrefectureFuelPrice.fromJson(json)).toList();
  }
}
