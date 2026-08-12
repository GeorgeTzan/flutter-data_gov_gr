import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:test/test.dart';

void main() {
  test(
    'anonymous construction publishes unavailable quota until a response',
    () async {
      final client = DataGovClient();
      addTearDown(client.close);
      expect(client.currentRateLimitStatus, RateLimitStatus.initial());
      expect(await client.rateLimitStatus.first, RateLimitStatus.initial());
      expect(
        client.catalog.actionBaseUrl.toString(),
        'https://data.gov.gr/api/3/action/',
      );
    },
  );
}
