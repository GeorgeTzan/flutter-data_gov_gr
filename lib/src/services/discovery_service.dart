import '../client/data_gov_client.dart';
import '../models/discovery/dataset_metadata.dart';

/// A service for discovering datasets, metadata, topics, and publishers/providers on data.gov.gr.
class DiscoveryService {
  final DataGovClient _client;

  /// Creates a new [DiscoveryService] instance.
  DiscoveryService(this._client);

  /// Lists metadata for all available datasets on data.gov.gr.
  Future<List<DatasetMetadata>> listDatasets() async {
    final response = await _client.dio.get('datasets/');
    final dynamic responseData = response.data;

    List data;
    if (responseData is Map) {
      data = responseData['results'] as List;
    } else {
      data = responseData as List;
    }

    return data.map((json) => DatasetMetadata.fromJson(json)).toList();
  }

  /// Retrieves metadata for a specific dataset identified by [identifier].
  Future<DatasetMetadata> getDatasetMetadata(String identifier) async {
    final response = await _client.dio.get('datasets/$identifier/');
    return DatasetMetadata.fromJson(response.data);
  }

  /// Lists all topic names/categories available on the portal.
  Future<List<String>> listTopics() async {
    final response = await _client.dio.get('topics/');
    return (response.data as List).cast<String>();
  }

  /// Lists all publishing organizations/providers available on the portal.
  Future<List<String>> listProviders() async {
    final response = await _client.dio.get('providers/');
    return (response.data as List).cast<String>();
  }
}
