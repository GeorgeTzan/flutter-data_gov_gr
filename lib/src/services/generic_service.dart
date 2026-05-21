import '../client/data_gov_client.dart';

/// A service that allows querying any dynamic or custom dataset identifier on data.gov.gr.
///
/// It will dynamically resolve metadata, download format resources (e.g. CSV or JSON),
/// and parse them on-the-fly, returning standard structured map data.
class GenericService {
  final DataGovClient _client;

  /// Creates a new [GenericService] instance.
  GenericService(this._client);

  /// Queries the specified [datasetId] with optional key-value query parameters [parameters].
  ///
  /// Returns a list of records representing the dataset's rows.
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

  /// Queries paged records of the specified [datasetId] as a stream.
  ///
  /// Requests batches of size [pageSize] and yields them until all records are fetched.
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
      if (parameters != null) {
        params.addAll(parameters);
      }

      final results = await query(datasetId, parameters: params);
      if (results.isEmpty) {
        hasMore = false;
      } else {
        yield results;
        offset += results.length;
        if (results.length < pageSize) {
          hasMore = false;
        }
      }
    }
  }

  /// Downloads the specified [datasetId] directly as a raw CSV string.
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
