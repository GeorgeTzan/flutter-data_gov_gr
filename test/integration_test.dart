import 'dart:io';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:test/test.dart';

void main() {
  // To run these tests:
  // DATA_GOV_GR_TOKEN=your_token_here dart test test/integration_test.dart
  final token = Platform.environment['DATA_GOV_GR_TOKEN'];

  group('Live API Integration Tests', () {
    late DataGovClient client;

    setUpAll(() {
      if (token == null || token.isEmpty) {
        print('SKIPPING INTEGRATION TESTS: DATA_GOV_GR_TOKEN not set.');
        return;
      }
      client = DataGovClient(apiKey: token);
    });

    test('can fetch real datasets list', () async {
      final datasets = await client.discovery.listDatasets();
      expect(datasets, isNotEmpty);
      print('Verified: Fetched ${datasets.length} datasets from live API.');
    }, skip: token == null ? 'Missing token' : false);

    test('can fetch real topics', () async {
      final topics = await client.discovery.listTopics();
      expect(topics, isNotEmpty);
      print('Verified: Fetched ${topics.length} topics from live API.');
    }, skip: token == null ? 'Missing token' : false);

    test('can fetch real fuel prices (prefecture)', () async {
      final prices = await client.fuel.getPrefectureFuelPrices(
        prefecture: Prefecture.attica,
      );
      expect(prices, isNotEmpty);
      print('Verified: Fetched fuel prices for Attica.');
    }, skip: token == null ? 'Missing token' : false);

    test('can fetch vaccination data', () async {
      final data = await client.health.getVaccinationStatistics();
      expect(data, isNotEmpty);
      print('Verified: Fetched vaccination statistics.');
    }, skip: token == null ? 'Missing token' : false);

    test('generic query works with KIMDIS', () async {
      final data = await client.generic.query('khmdhs_decisions');
      expect(data, isNotEmpty);
      print('Verified: Generic query for khmdhs_decisions successful.');
    }, skip: token == null ? 'Missing token' : false);
  });
}
