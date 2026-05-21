import '../client/data_gov_client.dart';

/// A service for fetching safety, crime, and road accident statistics from data.gov.gr.
class JusticeService {
  final DataGovClient _client;

  /// Creates a new [JusticeService] instance.
  JusticeService(this._client);

  /// Fetches road accident statistics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getRoadAccidents(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('mcp_road_accidents', parameters: params);
  }
}
