import '../client/data_gov_client.dart';
import '../models/environment/forest_fire.dart';

/// A service for fetching environmental data (e.g. forest fire records) from data.gov.gr.
class EnvironmentService {
  final DataGovClient _client;

  /// Creates a new [EnvironmentService] instance.
  EnvironmentService(this._client);

  /// Fetches forest fire records, optionally filtered by a date range.
  Future<List<ForestFire>> getForestFires({
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;

    final response = await _client.dio.get(
      'query/mcp_forest_fires',
      queryParameters: params,
    );

    final data = response.data as List;
    return data.map((json) => ForestFire.fromJson(json)).toList();
  }
}
