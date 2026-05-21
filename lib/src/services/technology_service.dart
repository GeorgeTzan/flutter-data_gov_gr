import '../client/data_gov_client.dart';

class TechnologyService {
  final DataGovClient _client;

  TechnologyService(this._client);

  Future<List<Map<String, dynamic>>> getDigitalAdoption(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null)
      params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('mindigital_adoption', parameters: params);
  }
}
