import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'data_gov_client.dart';
import '../utils/mock_data.dart';

/// A mock implementation of [DataGovClient] for testing purposes.
///
/// This client does not make real network requests. Instead, it returns
/// stubbed responses that can be configured by the user.
class DataGovMockClient extends DataGovClient {
  final Map<String, List<Map<String, dynamic>>> _stubs = {};

  DataGovMockClient() : super(apiKey: 'mock-key') {
    // Inject a custom adapter that returns stubbed data
    dio.httpClientAdapter = _MockAdapter(_stubs);
    
    // Seed with some default realistic data
    stubFuelPrices(MockData.fuelStations);
  }

  /// Stubs the response for fuel prices.
  void stubFuelPrices(List<Map<String, dynamic>> data) {
    _stubs['gas_price_per_station'] = data;
  }

  /// Registers a custom stub for any endpoint.
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
