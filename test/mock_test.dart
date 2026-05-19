import 'package:data_gov_gr/src/client/data_gov_mock_client.dart';
import 'package:data_gov_gr/src/services/fuel_service.dart';
import 'package:test/test.dart';

void main() {
  group('DataGovMockClient', () {
    late DataGovMockClient mockClient;
    late FuelService fuelService;

    setUp(() {
      mockClient = DataGovMockClient();
      fuelService = FuelService(mockClient);
    });

    test('returns default realistic data if no stub is provided', () async {
      final results = await fuelService.getGasPricesPerStation();

      expect(results.length, 1);
      expect(results.any((s) => s.brand == 'EKO'), isTrue);
    });

    test('returns custom stubbed data when configured', () async {
      final customData = [
        {
          'station_id': '9999',
          'brand': 'Custom Brand',
          'address': 'Custom address',
          'municipality': 'Custom City',
          'prefecture': 'ΑΤΤΙΚΗΣ',
          'latitude': 0.0,
          'longitude': 0.0,
          'fuel_type': 'Αμόλυβδη 95',
          'fuel_price': 1.0,
          'date': '2024-01-01T00:00:00Z',
        }
      ];

      mockClient.stubFuelPrices(customData);

      final results = await fuelService.getGasPricesPerStation();

      expect(results.length, 1);
      expect(results.first.brand, 'Custom Brand');
    });

    test('updates rate limit status from headers', () async {
      await fuelService.getGasPricesPerStation();

      final status =
          await mockClient.rateLimitStatus.firstWhere((s) => s.limit > 0);
      expect(status.remaining, 999);
      expect(status.limit, 1000);
    });
  });
}
