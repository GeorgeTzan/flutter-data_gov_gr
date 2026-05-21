import '../client/data_gov_client.dart';

/// A service for fetching public transport and airport traffic statistics from data.gov.gr.
class TransportService {
  final DataGovClient _client;

  /// Creates a new [TransportService] instance.
  TransportService(this._client);

  /// Fetches public transport operational statistics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getPublicTransportStats(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_transport', parameters: params);
  }

  /// Fetches airport passenger and flight traffic metrics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getAirportTraffic(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_airport', parameters: params);
  }
}
