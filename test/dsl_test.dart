import 'package:data_gov_gr/src/client/data_gov_client.dart';
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

  group('FuelQueryBuilder', () {
    test('fetch() calls service with correct parameters from DSL', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: [],
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final testDate = DateTime(2024, 5, 13);

      await fuelService
          .query()
          .atDate(testDate)
          .wherePrefecture(Prefecture.attica)
          .whereFuelType(FuelType.unleaded95)
          .fetch();

      verify(() => mockDio.get(
            'query/gas_price_per_station',
            queryParameters: {
              'date': '2024-05-13',
              'prefecture': 'ΑΤΤΙΚΗΣ',
              'fuel_type': 'Αμόλυβδη 95',
            },
          )).called(1);
    });
  });
}
