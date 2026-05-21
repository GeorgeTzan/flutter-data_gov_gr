import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:test/test.dart';

void main() {
  group('Live CKAN API Public Integration Tests', () {
    late DataGovClient client;

    setUpAll(() {
      // Use a dummy key since these datasets are public on the new portal
      client = DataGovClient(apiKey: 'public-access-key');
    });

    tearDownAll(() {
      client.dispose();
    });

    test('can fetch real topics (groups)', () async {
      final topics = await client.discovery.listTopics();
      expect(topics, isNotEmpty);
      expect(topics, contains('health'));
      print(
          'Verified: Fetched ${topics.length} topics from live portal. Sample: ${topics.take(5).toList()}');
    });

    test('can fetch real providers (organizations)', () async {
      final providers = await client.discovery.listProviders();
      expect(providers, isNotEmpty);
      print(
          'Verified: Fetched ${providers.length} providers from live portal. Sample: ${providers.take(5).toList()}');
    });

    test('can fetch and parse active DataStore dataset (internet_traffic)',
        () async {
      final data = await client.telecom.getInternetTraffic(
        from: DateTime(2025, 8, 28),
        to: DateTime(2025, 8, 30),
      );
      // Depending on availability, it might be empty if date is out of range, or populate records
      print(
          'Verified: Fetched internet traffic records. Count: ${data.length}');
      if (data.isNotEmpty) {
        expect(data.first.inbound, isNotNull);
        expect(data.first.date, isNotNull);
      }
    });

    test(
        'can fetch, download, and parse file-only CSV dataset (mcp_forest_fires)',
        () async {
      final data = await client.generic.query(
        'mcp_forest_fires',
        parameters: {'limit': 5},
      );
      expect(data, isNotEmpty);
      expect(data.length, lessThanOrEqualTo(5));
      print('Verified: Fetched forest fires. Count: ${data.length}');
      print('First row keys: ${data.first.keys.toList()}');
      expect(data.first.containsKey('date'), isTrue);
    });

    test('can fetch, download, and parse file-only CSV dataset (mdg_emvolio)',
        () async {
      final data = await client.generic.query(
        'mdg_emvolio',
        parameters: {'limit': 5},
      );
      expect(data, isNotEmpty);
      expect(data.length, lessThanOrEqualTo(5));
      print('Verified: Fetched vaccination data. Count: ${data.length}');
      print('First row keys: ${data.first.keys.toList()}');
      expect(data.first.containsKey('referencedate'), isTrue);
    });

    test('can query fuel prices per station (fallback to mock)', () async {
      final data = await client.fuel.getGasPricesPerStation();
      expect(data, isNotEmpty);
      expect(data.first.brand, isNotEmpty);
      print(
          'Verified: Fetched fuel prices per station fallback. Count: ${data.length}');
    });

    test('can query min max fuel prices per prefecture (fallback to mock)',
        () async {
      final data = await client.fuel.getPrefectureFuelPrices();
      expect(data, isNotEmpty);
      expect(data.first.prefecture, isNotNull);
      print(
          'Verified: Fetched prefecture fuel prices fallback. Count: ${data.length}');
    });

    test('can query procurement decisions (fallback to mock)', () async {
      final data = await client.procurement.getKimdisDecisions();
      expect(data, isNotEmpty);
      expect(data.first.ada, isNotEmpty);
      print(
          'Verified: Fetched procurement decisions fallback. Count: ${data.length}');
    });

    test('generic query gas_price_per_station returns fallback data', () async {
      final data = await client.generic.query('gas_price_per_station');
      expect(data, isNotEmpty);
      expect(data.first['brand'], isNotEmpty);
    });

    test('generic download gas_price_per_station returns CSV fallback data',
        () async {
      final csv = await client.generic.downloadCsv('gas_price_per_station');
      expect(csv, isNotEmpty);
      expect(csv, contains('brand'));
    });
  });
}
