import '../client/data_gov_client.dart';

class SocietyService {
  final DataGovClient _client;

  SocietyService(this._client);

  Future<List<Map<String, dynamic>>> getEmploymentStatistics({DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_employment', parameters: params);
  }

  Future<List<Map<String, dynamic>>> getUnemploymentStatistics({DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_unemployment', parameters: params);
  }
}
