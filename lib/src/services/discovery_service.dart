import '../client/data_gov_client.dart';
import '../models/discovery/dataset_metadata.dart';

class DiscoveryService {
  final DataGovClient _client;

  DiscoveryService(this._client);

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

  Future<DatasetMetadata> getDatasetMetadata(String identifier) async {
    final response = await _client.dio.get('datasets/$identifier/');
    return DatasetMetadata.fromJson(response.data);
  }

  Future<List<String>> listTopics() async {
    final response = await _client.dio.get('topics/');
    return (response.data as List).cast<String>();
  }

  Future<List<String>> listProviders() async {
    final response = await _client.dio.get('providers/');
    return (response.data as List).cast<String>();
  }
}
