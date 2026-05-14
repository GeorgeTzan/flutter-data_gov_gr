import '../client/data_gov_client.dart';

class GenericService {
  final DataGovClient _client;

  GenericService(this._client);

  Future<List<Map<String, dynamic>>> query(
    String datasetId, {
    Map<String, dynamic>? parameters,
  }) async {
    final response = await _client.dio.get(
      'query/$datasetId',
      queryParameters: parameters,
    );
    final data = response.data as List;
    return data.map((json) => json as Map<String, dynamic>).toList();
  }
}
