import '../client/data_gov_client.dart';

/// A service for fetching education-related metrics (e.g. university statistics) from data.gov.gr.
class EducationService {
  final DataGovClient _client;

  /// Creates a new [EducationService] instance.
  EducationService(this._client);

  /// Fetches university enrollment and graduation statistics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getUniversityStatistics(
      {DateTime? from, DateTime? to}) {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return _client.generic.query('minedu_universities', parameters: params);
  }
}
