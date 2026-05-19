import '../client/data_gov_client.dart';

class TransportService {
  final DataGovClient _client;

  TransportService(this._client);

  Future<List<Map<String, dynamic>>> getPublicTransportStats({DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_transport', parameters: params);
  }

  Future<List<Map<String, dynamic>>> getAirportTraffic({DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_airport', parameters: params);
  }
}
