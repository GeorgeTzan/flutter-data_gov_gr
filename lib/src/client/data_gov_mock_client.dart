import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'data_gov_client.dart';
import '../utils/mock_data.dart';

class DataGovMockClient extends DataGovClient {
  final Map<String, List<dynamic>> _stubs = {};

  DataGovMockClient() : super(apiKey: 'mock-key') {
    dio.httpClientAdapter = _MockAdapter(_stubs);
    _seedDefaultStubs();
  }

  void _seedDefaultStubs() {
    stubFuelPrices(MockData.fuelStations);
    stubVaccinations(MockData.vaccinations);
    stubInternetTraffic(MockData.internetTraffic);
    stubForestFires(MockData.forestFires);
    
    _stubs['datasets'] = [
      {'identifier': 'gas_price_per_station', 'title': 'Gas Prices', 'publisher': 'Ministry of Development', 'description': 'Retail fuel prices', 'keyword': ['fuel'], 'modified': '2024-05-13T00:00:00Z', 'spatial': 'Greece', 'temporal': '2024'},
      {'identifier': 'mdg_emvolio', 'title': 'Vaccinations', 'publisher': 'Ministry of Digital Governance', 'description': 'COVID-19 Stats', 'keyword': ['health'], 'modified': '2024-05-13T00:00:00Z', 'spatial': 'Greece', 'temporal': '2024'},
      {'identifier': 'khmahe-api', 'title': 'KIMDIS Public Procurement', 'publisher': 'Ministry of Development', 'description': 'Contract data', 'keyword': ['finance'], 'modified': '2024-05-13T00:00:00Z', 'spatial': 'Greece', 'temporal': '2024'},
    ];

    _stubs['topics'] = ['Health', 'Environment', 'Economy', 'Energy', 'Justice'];
    _stubs['providers'] = ['Ministry of Digital Governance', 'Ministry of Health', 'Ministry of Finance'];
  }

  void stubFuelPrices(List<Map<String, dynamic>> data) => _stubs['query/gas_price_per_station'] = data;
  void stubVaccinations(List<Map<String, dynamic>> data) => _stubs['query/mdg_emvolio'] = data;
  void stubInternetTraffic(List<Map<String, dynamic>> data) => _stubs['query/internet_traffic'] = data;
  void stubForestFires(List<Map<String, dynamic>> data) => _stubs['query/mcp_forest_fires'] = data;

  void stubGeneric(String datasetId, List<Map<String, dynamic>> data) {
    _stubs['query/$datasetId'] = data;
  }

  void registerStub(String endpoint, List<dynamic> data) {
    _stubs[endpoint] = data;
  }
}

class _MockAdapter implements HttpClientAdapter {
  final Map<String, List<dynamic>> stubs;

  _MockAdapter(this.stubs);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    
    if (stubs.containsKey(path)) {
      return ResponseBody.fromString(
        jsonEncode(stubs[path]),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'X-RateLimit-Limit': ['1000'],
          'X-RateLimit-Remaining': ['999'],
          'X-RateLimit-Reset': ['${DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600}'],
        },
      );
    }

    return ResponseBody.fromString(
      '{"error": "Not Found", "path": "$path"}',
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
