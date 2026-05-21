import '../client/data_gov_client.dart';

class JusticeService {
  final DataGovClient _client;

  JusticeService(this._client);

  Future<List<Map<String, dynamic>>> getRoadAccidents(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null)
      params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('mcp_road_accidents', parameters: params);
  }
}
