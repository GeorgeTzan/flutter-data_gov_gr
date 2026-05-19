import 'package:data_gov_gr/src/client/data_gov_client.dart';
import 'package:data_gov_gr/src/models/fuel/fuel_station.dart';
import 'package:data_gov_gr/src/models/fuel/fuel_type.dart';
import 'package:data_gov_gr/src/models/shared/prefecture.dart';
import 'package:data_gov_gr/src/services/fuel_service.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDataGovClient extends Mock implements DataGovClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDataGovClient mockClient;
  late MockDio mockDio;
  late FuelService fuelService;

  setUp(() {
    mockClient = MockDataGovClient();
    mockDio = MockDio();
    fuelService = FuelService(mockClient);

    when(() => mockClient.dio).thenReturn(mockDio);
  });

  group('FuelStation', () {
    test('parses from JSON correctly', () {
      final json = {
        'station_id': '123',
        'brand': 'Shell',
        'address': 'Main St 1',
        'municipality': 'Athens',
        'prefecture': 'ΑΤΤΙΚΗΣ',
        'latitude': 37.9838,
        'longitude': 23.7275,
        'fuel_type': 'Αμόλυβδη 95',
        'fuel_price': 1.85,
        'date': '2024-01-01T00:00:00Z',
      };

      final station = FuelStation.fromJson(json);

      expect(station.stationId, '123');
      expect(station.brand, 'Shell');
      expect(station.prefecture, Prefecture.attica);
      expect(station.fuelType, FuelType.unleaded95);
      expect(station.rawFuelType, 'Αμόλυβδη 95');
      expect(station.price, 1.85);
    });
  });

  group('FuelService', () {
    test('getGasPricesPerStation calls correct endpoint with parameters',
        () async {
      final mockData = [
        {
          'station_id': '123',
          'brand': 'Shell',
          'address': 'Main St 1',
          'municipality': 'Athens',
          'prefecture': 'ΑΤΤΙΚΗΣ',
          'latitude': 37.9838,
          'longitude': 23.7275,
          'fuel_type': 'Αμόλυβδη 95',
          'fuel_price': 1.85,
          'date': '2024-01-01T00:00:00Z',
        }
      ];

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final results = await fuelService.getGasPricesPerStation(
        date: DateTime(2024, 1, 1),
        prefecture: Prefecture.attica,
        fuelType: FuelType.unleaded95,
      );

      expect(results.length, 1);
      expect(results.first.brand, 'Shell');

      verify(() => mockDio.get(
            'query/gas_price_per_station',
            queryParameters: {
              'date': '2024-01-01',
              'prefecture': 'ΑΤΤΙΚΗΣ',
              'fuel_type': 'Αμόλυβδη 95',
            },
          )).called(1);
    });
  });
}
