import '../client/data_gov_client.dart';
import '../models/environment/forest_fire.dart';

class EnvironmentService {
  final DataGovClient _client;

  EnvironmentService(this._client);

  Future<List<ForestFire>> getForestFires({
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;

    final response = await _client.dio.get(
      'mcp_forest_fires',
      queryParameters: params,
    );

    final data = response.data as List;
    return data.map((json) => ForestFire.fromJson(json)).toList();
  }
}
