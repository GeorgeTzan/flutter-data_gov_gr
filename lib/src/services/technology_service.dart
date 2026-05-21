import '../client/data_gov_client.dart';

/// A service for fetching technology adoption and digital governance statistics from data.gov.gr.
class TechnologyService {
  final DataGovClient _client;

  /// Creates a new [TechnologyService] instance.
  TechnologyService(this._client);

  /// Fetches metrics on digital services adoption, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getDigitalAdoption(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('mindigital_adoption', parameters: params);
  }
}
