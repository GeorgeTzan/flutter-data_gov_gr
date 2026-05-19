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

  Stream<List<Map<String, dynamic>>> queryPaged(
    String datasetId, {
    int pageSize = 100,
    Map<String, dynamic>? parameters,
  }) async* {
    var offset = 0;
    bool hasMore = true;

    while (hasMore) {
      final params = <String, dynamic>{
        'offset': offset,
        'limit': pageSize,
      };
      if (parameters != null) params.addAll(parameters);

      final results = await query(datasetId, parameters: params);
      if (results.isEmpty) {
        hasMore = false;
      } else {
        yield results;
        offset += results.length;
        if (results.length < pageSize) hasMore = false;
      }
    }
  }

  Future<String> downloadCsv(
    String datasetId, {
    Map<String, dynamic>? parameters,
  }) async {
    final params = <String, dynamic>{'type': 'csv'};
    if (parameters != null) params.addAll(parameters);
    
    final response = await _client.dio.get(
      'query/download/$datasetId',
      queryParameters: params,
    );
    return response.data.toString();
  }
}
