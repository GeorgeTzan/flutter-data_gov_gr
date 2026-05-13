import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'data_gov_client.dart';
import '../utils/mock_data.dart';

class DataGovMockClient extends DataGovClient {
  final Map<String, List<Map<String, dynamic>>> _stubs = {};

  DataGovMockClient() : super(apiKey: 'mock-key') {
    dio.httpClientAdapter = _MockAdapter(_stubs);
    stubFuelPrices(MockData.fuelStations);
  }

  void stubFuelPrices(List<Map<String, dynamic>> data) {
    _stubs['gas_price_per_station'] = data;
  }

  void registerStub(String endpoint, List<Map<String, dynamic>> data) {
    _stubs[endpoint] = data;
  }
}

class _MockAdapter implements HttpClientAdapter {
  final Map<String, List<Map<String, dynamic>>> stubs;

  _MockAdapter(this.stubs);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    
    if (stubs.containsKey(path)) {
      final data = stubs[path]!;
      final jsonString = jsonEncode(data);
      return ResponseBody.fromString(
        jsonString,
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
      '{"error": "Not Found"}',
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
