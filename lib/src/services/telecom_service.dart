import '../client/data_gov_client.dart';
import '../models/telecom/internet_traffic.dart';

class TelecomService {
  final DataGovClient _client;

  TelecomService(this._client);

  Future<List<InternetTraffic>> getInternetTraffic({
    DateTime? from,
    DateTime? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;

    final response = await _client.dio.get(
      'query/internet_traffic',
      queryParameters: params,
    );

    final data = response.data as List;
    return data.map((json) => InternetTraffic.fromJson(json)).toList();
  }
}
