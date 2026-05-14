import '../client/data_gov_client.dart';
import '../models/health/vaccination_data.dart';

class HealthService {
  final DataGovClient _client;

  HealthService(this._client);

  Future<List<VaccinationData>> getVaccinationStatistics({
    DateTime? from,
    DateTime? to,
    String? area,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    if (area != null) params['area'] = area;

    final response = await _client.dio.get(
      'query/mdg_emvolio',
      queryParameters: params,
    );

    final data = response.data as List;
    return data.map((json) => VaccinationData.fromJson(json)).toList();
  }
}
