import '../client/data_gov_client.dart';

/// A service for fetching societal metrics (employment and unemployment statistics) from data.gov.gr.
class SocietyService {
  final DataGovClient _client;

  /// Creates a new [SocietyService] instance.
  SocietyService(this._client);

  /// Fetches labor market employment statistics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getEmploymentStatistics(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_employment', parameters: params);
  }

  /// Fetches labor market unemployment statistics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getUnemploymentStatistics(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minfin_unemployment', parameters: params);
  }
}
