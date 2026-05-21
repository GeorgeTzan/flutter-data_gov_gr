import '../client/data_gov_client.dart';
import '../models/telecom/internet_traffic.dart';

/// A service for fetching telecommunication and internet traffic data (e.g. GR-IX traffic) from data.gov.gr.
class TelecomService {
  final DataGovClient _client;

  /// Creates a new [TelecomService] instance.
  TelecomService(this._client);

  /// Fetches GR-IX internet traffic volume statistics, optionally filtered by a date range.
  Future<List<InternetTraffic>> getInternetTraffic({
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;

    final response = await _client.dio.get(
      'query/internet_traffic',
      queryParameters: params,
    );

    final data = response.data as List;
    return data.map((json) => InternetTraffic.fromJson(json)).toList();
  }
}
