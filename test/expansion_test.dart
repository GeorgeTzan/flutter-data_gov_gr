import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDataGovClient extends Mock implements DataGovClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDataGovClient mockClient;
  late MockDio mockDio;

  setUp(() {
    mockClient = MockDataGovClient();
    mockDio = MockDio();
    when(() => mockClient.dio).thenReturn(mockDio);
  });

  group('HealthService', () {
    test('getVaccinationStatistics returns data', () async {
      final service = HealthService(mockClient);
      final mockResponse = [
        {
          'area': 'ATHENS',
          'areaid': 1,
          'dailydose1': 100,
          'dailydose2': 50,
          'daydiff': 10,
          'daytotal': 150,
          'referencedate': '2024-05-13T00:00:00Z',
          'totaldose1': 1000,
          'totaldose2': 500,
          'totalvaccinations': 1500,
        }
      ];

      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(),
              ));

      final results = await service.getVaccinationStatistics();
      expect(results.length, 1);
      expect(results.first.area, 'ATHENS');
    });
  });

  group('TelecomService', () {
    test('getInternetTraffic returns data', () async {
      final service = TelecomService(mockClient);
      final mockResponse = [
        {
          'date': '2024-05-13T00:00:00Z',
          'inbound': 100.5,
          'outbound': 90.2,
          'total_traffic': 190.7,
        }
      ];

      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(),
              ));

      final results = await service.getInternetTraffic();
      expect(results.length, 1);
      expect(results.first.inbound, 100.5);
    });
  });

  group('EnvironmentService', () {
    test('getForestFires returns data', () async {
      final service = EnvironmentService(mockClient);
      final mockResponse = [
        {
          'date': '2024-05-13T00:00:00Z',
          'area': 50.0,
          'location': 'Attica',
          'fire_type': 'Forest',
          'cause': 'Unknown',
        }
      ];

      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(),
              ));

      final results = await service.getForestFires();
      expect(results.length, 1);
      expect(results.first.area, 50.0);
    });
  });

  group('DiscoveryService', () {
    test('listDatasets returns metadata', () async {
      final service = DiscoveryService(mockClient);
      final mockResponse = [
        {
          'identifier': 'test_ds',
          'title': 'Test Dataset',
          'description': 'Description',
          'keyword': ['test'],
          'modified': '2024-05-13T00:00:00Z',
          'publisher': 'Ministry',
          'contact_point': 'contact@test.gr',
          'spatial': 'Greece',
          'temporal': '2024',
          'accrual_periodicity': 'Daily',
        }
      ];

      when(() => mockDio.get('datasets/')).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final results = await service.listDatasets();
      expect(results.length, 1);
      expect(results.first.identifier, 'test_ds');
    });
  });

  group('GenericService', () {
    test('query returns raw maps', () async {
      final service = GenericService(mockClient);
      final mockResponse = [
        {'any_key': 'any_value'}
      ];

      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(),
              ));

      final results = await service.query('unknown_id');
      expect(results.length, 1);
      expect(results.first['any_key'], 'any_value');
    });
  });
}
