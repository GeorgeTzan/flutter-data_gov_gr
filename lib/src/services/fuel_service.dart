import 'package:dio/dio.dart';
import '../client/data_gov_client.dart';
import '../models/fuel/fuel_station.dart';
import '../models/fuel/fuel_type.dart';
import '../models/shared/prefecture.dart';
import 'fuel_query_builder.dart';

class FuelService {
  final DataGovClient _client;

  FuelService(this._client);

  FuelQueryBuilder query() => FuelQueryBuilder(this);

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
      'gas_price_per_station',
      queryParameters: queryParameters,
    );

    final data = response.data as List;
    return data.map((json) => FuelStation.fromJson(json)).toList();
  }
}
