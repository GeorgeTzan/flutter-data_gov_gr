import '../client/data_gov_client.dart';

class EducationService {
  final DataGovClient _client;

  EducationService(this._client);

  Future<List<Map<String, dynamic>>> getUniversityStatistics({DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minedu_universities', parameters: params);
  }
}
