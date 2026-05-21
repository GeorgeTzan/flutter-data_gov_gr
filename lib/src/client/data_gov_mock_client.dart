import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'data_gov_client.dart';
import '../utils/mock_data.dart';

/// A mock client for testing the data.gov.gr SDK offline.
///
/// Pre-populates default mock data stubs for the SDK services and allows
/// registering custom stubs for specific endpoints.
class DataGovMockClient extends DataGovClient {
  final Map<String, List<dynamic>> _stubs = {};

  /// Creates a new [DataGovMockClient] instance with predefined mock stubs.
  DataGovMockClient() : super(apiKey: 'mock-key') {
    dio.httpClientAdapter = _MockAdapter(_stubs);
    _seedDefaultStubs();
  }

  void _seedDefaultStubs() {
    stubFuelPrices(MockData.fuelStations);
    stubPrefectureFuelPrices(MockData.prefectureFuelPrices);
    stubVaccinations(MockData.vaccinations);
    stubInternetTraffic(MockData.internetTraffic);
    stubForestFires(MockData.forestFires);
    stubProcurement(MockData.procurementDecisions);

    _stubs['datasets'] = [
      {
        'identifier': 'gas_price_per_station',
        'title': 'Gas Prices (Detailed)',
        'publisher': 'Ministry of Development'
      },
      {
        'identifier': 'min_max_fuel_prices_per_prefecture',
        'title': 'Fuel Prices (Prefecture)',
        'publisher': 'Ministry of Development'
      },
      {
        'identifier': 'mdg_emvolio',
        'title': 'Vaccinations',
        'publisher': 'Ministry of Digital Governance'
      },
      {
        'identifier': 'khmdhs_decisions',
        'title': 'KIMDIS Procurement',
        'publisher': 'Ministry of Development'
      },
      {
        'identifier': 'mcp_forest_fires',
        'title': 'Forest Fires',
        'publisher': 'National Observatory'
      },
      {
        'identifier': 'internet_traffic',
        'title': 'Internet Traffic',
        'publisher': 'GR-IX'
      },
      {
        'identifier': 'public_admin_eval',
        'title': 'Public Admin Evaluation',
        'publisher': 'Ministry of Interior'
      },
    ];

    _stubs['topics'] = [
      'Health',
      'Environment',
      'Economy',
      'Energy',
      'Justice',
      'Telecom',
      'Administration'
    ];
    _stubs['providers'] = [
      'Ministry of Digital Governance',
      'Ministry of Health',
      'Ministry of Finance',
      'Ministry of Development',
      'GR-IX',
      'National Observatory',
    ];
  }

  /// Stubs the detailed fuel station query endpoint with [data].
  void stubFuelPrices(List<Map<String, dynamic>> data) =>
      _stubs['query/gas_price_per_station'] = data;

  /// Stubs the prefecture-level fuel price query endpoint with [data].
  void stubPrefectureFuelPrices(List<Map<String, dynamic>> data) =>
      _stubs['query/min_max_fuel_prices_per_prefecture'] = data;

  /// Stubs the vaccination statistics query endpoint with [data].
  void stubVaccinations(List<Map<String, dynamic>> data) =>
      _stubs['query/mdg_emvolio'] = data;

  /// Stubs the internet traffic query endpoint with [data].
  void stubInternetTraffic(List<Map<String, dynamic>> data) =>
      _stubs['query/internet_traffic'] = data;

  /// Stubs the forest fires query endpoint with [data].
  void stubForestFires(List<Map<String, dynamic>> data) =>
      _stubs['query/mcp_forest_fires'] = data;

  /// Stubs the KIMDIS procurement decisions query endpoint with [data].
  void stubProcurement(List<Map<String, dynamic>> data) =>
      _stubs['query/khmdhs_decisions'] = data;

  /// Stubs a generic query for a specific [datasetId] with [data].
  void stubGeneric(String datasetId, List<Map<String, dynamic>> data) {
    _stubs['query/$datasetId'] = data;
  }

  /// Registers a custom mock [data] response for a specific [endpoint] path.
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
          'X-RateLimit-Reset': [
            '${DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600}'
          ],
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
