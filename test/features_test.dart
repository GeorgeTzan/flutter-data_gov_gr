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

  group('GenericService Features', () {
    test('downloadCsv calls download endpoint and returns string', () async {
      final service = GenericService(mockClient);
      const csvData = 'id,name\n1,test';

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: csvData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await service.downloadCsv('test_dataset');

      expect(result, csvData);
      verify(() => mockDio.get(
            'query/download/test_dataset',
            queryParameters: {'type': 'csv'},
          )).called(1);
    });
  });

  group('Client Configuration', () {
    test('DataGovClient has correct default timeouts', () {
      final client = DataGovClient(apiKey: 'key');
      expect(client.dio.options.connectTimeout, const Duration(seconds: 60));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 60));
    });
  });
}
