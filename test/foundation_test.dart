import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  final failures = <int, Matcher>{
    401: isA<AuthenticationException>(),
    403: isA<PermissionException>(),
    404: isA<NotFoundException>(),
    429: isA<RateLimitException>(),
    500: isA<NetworkException>(),
  };
  for (final failure in failures.entries) {
    test(
      'HTTP ${failure.key} is exposed directly as a typed SDK failure',
      () async {
        final adapter = ScriptedAdapter([
          (request) async => ResponseBody.fromString('', failure.key),
        ]);
        final client = DataGovClient(
          config: DataGovConfig(retry: RetryPolicy(maxAttempts: 1)),
          adapter: adapter,
        );
        addTearDown(client.close);
        await expectLater(
          client.catalog.search(CatalogQuery()),
          throwsA(failure.value),
        );
        expect(adapter.requests, hasLength(1));
      },
    );
  }

  test('request timeouts remain distinct from other network errors', () async {
    final adapter = ScriptedAdapter([
      (request) async => throw DioException(
        requestOptions: request,
        type: DioExceptionType.connectionTimeout,
      ),
    ]);
    final client = DataGovClient(
      config: DataGovConfig(retry: RetryPolicy(maxAttempts: 1)),
      adapter: adapter,
    );
    addTearDown(client.close);
    await expectLater(
      client.catalog.search(CatalogQuery()),
      throwsA(isA<RequestTimeoutException>()),
    );
  });

  test('a malformed CKAN envelope does not become an empty result', () async {
    final adapter = ScriptedAdapter([
      (request) async => ResponseBody.fromString('{"result":[]}', 200),
    ]);
    final client = DataGovClient(adapter: adapter);
    addTearDown(client.close);
    await expectLater(
      client.catalog.search(CatalogQuery()),
      throwsA(isA<DecodeException>()),
    );
  });
}
