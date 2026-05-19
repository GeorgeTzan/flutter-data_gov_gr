import 'dart:io';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:test/test.dart';

void main() {
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

    test('can fetch real topics', () async {
      final topics = await client.discovery.listTopics();
      expect(topics, isNotEmpty);
      print('Verified: Fetched ${topics.length} topics from live API.');
    }, skip: token == null ? 'Missing token' : false);

    test('can fetch vaccination data', () async {
      final data = await client.health.getVaccinationStatistics(
        from: DateTime(2021, 5, 1),
        to: DateTime(2021, 5, 7),
      );
      expect(data, isNotEmpty);
      print('Verified: Fetched vaccination statistics.');
    }, skip: token == null ? 'Missing token' : false);

    test('generic query works with internet traffic', () async {
      final data = await client.generic.query(
        'internet_traffic',
        parameters: {
          'date_from': '2021-01-01',
          'date_to': '2021-01-02',
        },
      );
      expect(data, isNotEmpty);
      print('Verified: Generic query for internet_traffic successful.');
    }, skip: token == null ? 'Missing token' : false);
  });
}
