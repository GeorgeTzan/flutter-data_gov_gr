import 'package:dio/dio.dart';
import '../client/data_gov_client.dart';
import '../models/fuel/fuel_station.dart';
import '../models/fuel/fuel_type.dart';
import '../models/shared/prefecture.dart';

/// Service for fetching fuel-related data from data.gov.gr.
class FuelService {
  final DataGovClient _client;

  FuelService(this._client);

  /// Fetches gas prices per station.
  ///
  /// [date] filters for a specific day.
  /// [prefecture] filters by region.
  /// [fuelType] filters by fuel category.
  Future<List<FuelStation>> getGasPricesPerStation({
    DateTime? date,
    Prefecture? prefecture,
    FuelType? fuelType,
  }) async {
    final Map<String, dynamic> queryParameters = {};

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
      'gas_price_per_station',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => FuelStation.fromJson(json)).toList();
  }
}
