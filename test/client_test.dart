import 'package:data_gov_gr/src/client/data_gov_client.dart';
import 'package:data_gov_gr/src/models/shared/rate_limit_status.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  const testApiKey = 'test-key';

  group('DataGovClient', () {
    late DataGovClient client;

    setUp(() {
      client = DataGovClient(apiKey: testApiKey);
    });

    tearDown(() {
      client.dispose();
    });

    test('initializes with correct base URL and headers', () {
      expect(client.dio.options.baseUrl, 'https://data.gov.gr/api/v1/');
      expect(client.dio.options.headers['Authorization'], 'Token $testApiKey');
      expect(client.dio.options.headers['User-Agent'],
          contains('data_gov_gr_sdk_dart'));
    });

    test('rateLimitStatus stream starts with initial value', () async {
      final status = await client.rateLimitStatus.first;
      expect(status, RateLimitStatus.initial());
    });
  });
}
