import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

ResponseBody envelope(
  Object? result, {
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(
  jsonEncode({'success': true, 'result': result}),
  200,
  headers: headers,
);

DataGovClient clientFor(ScriptedAdapter adapter, {bool own = false}) {
  final client = DataGovClient(
    config: DataGovConfig(
      actionBaseUrl: Uri.parse('https://portal.test/api/3/action/'),
      apiKey: 'selected-key',
      retry: RetryPolicy(maxAttempts: 1),
      disposeInjectedAdapter: own,
    ),
    adapter: adapter,
  );
  addTearDown(client.close);
  return client;
}

void main() {
  test(
    'entry and resource metadata caches retain distinct entity types',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => envelope({'id': 'same', 'title': 'catalog title'}),
        (request) async =>
            envelope({'id': 'same', 'url': 'https://files.test/same.csv'}),
      ]);
      final client = clientFor(adapter);
      expect((await client.catalog.getEntry('same')).title, 'catalog title');
      expect(
        (await client.catalog.getResource('same')).url,
        'https://files.test/same.csv',
      );
      expect((await client.catalog.getEntry('same')).title, 'catalog title');
      expect(
        (await client.catalog.getResource('same')).url,
        'https://files.test/same.csv',
      );
      expect(adapter.requests, hasLength(2));
    },
  );

  test(
    'public client queries all services through the selected adapter',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => envelope(
          {
            'count': 1,
            'results': [
              {'id': 'entry', 'type': 'dataset'},
            ],
          },
          headers: {
            'x-ratelimit-remaining': ['8'],
          },
        ),
        (request) async => envelope({
          'id': 'resource',
          'package_id': 'entry',
          'url': 'https://files.test/raw.bin',
        }),
        (request) async => envelope({
          'records': [
            {'_id': 1, 'code': '00123'},
          ],
          'fields': [
            {'id': 'code', 'type': 'text'},
          ],
          'total': 1,
        }),
        (request) async => ResponseBody(
          Stream.value(Uint8List.fromList([0, 255, 1])),
          200,
          headers: {
            'x-ratelimit-remaining': ['7'],
          },
        ),
      ]);
      final client = clientFor(adapter);
      expect(client.currentRateLimitStatus.available, isFalse);
      expect((await client.rateLimitStatus.first).available, isFalse);
      expect(
        (await client.catalog.search(CatalogQuery())).entries.single.id,
        'entry',
      );
      expect((await client.rateLimitStatus.first).remaining, 8);
      final resource = await client.catalog.getResource('resource');
      expect(
        (await client.datastore.search(
          resource.id,
          DataStoreQuery(),
        )).records.single['code'],
        '00123',
      );
      final download = await client.resources.download(resource);
      expect(await download.bytes.expand((chunk) => chunk).toList(), [
        0,
        255,
        1,
      ]);
      expect(download.provenance.entryId, 'entry');
      expect(client.currentRateLimitStatus.remaining, 7);
      expect((await client.rateLimitStatus.first).remaining, 7);
      expect(adapter.requests.map((request) => request.uri.path), [
        '/api/3/action/package_search',
        '/api/3/action/resource_show',
        '/api/3/action/datastore_search',
        '/raw.bin',
      ]);
      expect(adapter.requests.first.uri.queryParameters['rows'], '100');
      expect(adapter.requests.first.uri.queryParameters['sort'], 'id asc');
      expect(adapter.requests[2].uri.queryParameters['limit'], '100');
      expect(adapter.requests[2].uri.queryParameters['sort'], '_id asc');
      expect(adapter.requests.first.headers['Authorization'], 'selected-key');
      expect(
        adapter.requests.last.headers.keys.map((key) => key.toLowerCase()),
        isNot(contains('authorization')),
      );
    },
  );

  test(
    'metadata is retained locally and never shared across clients',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => envelope({'id': 'same', 'title': 'first'}),
        (request) async => envelope({'id': 'same', 'title': 'second'}),
        (request) async => envelope({'id': 'same', 'title': 'refreshed'}),
      ]);
      final first = clientFor(adapter);
      final second = clientFor(adapter);
      expect((await first.catalog.getEntry('same')).title, 'first');
      expect((await first.catalog.getEntry('same')).title, 'first');
      expect((await second.catalog.getEntry('same')).title, 'second');
      first.catalog.clearCache();
      expect((await second.catalog.getEntry('same')).title, 'second');
      expect((await first.catalog.getEntry('same')).title, 'refreshed');
      expect(adapter.requests, hasLength(3));
    },
  );

  test(
    'CKAN unsuccessful envelopes escape directly as SDK exceptions',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => ResponseBody.fromString(
          '{"success":false,"error":{"message":"missing"}}',
          200,
        ),
      ]);
      await expectLater(
        clientFor(adapter).catalog.search(CatalogQuery()),
        throwsA(
          isA<CkanActionException>().having(
            (error) => error.action,
            'action',
            'package_search',
          ),
        ),
      );
      expect(adapter.requests, hasLength(1));
    },
  );

  test(
    'close rejects every service and retains caller adapter ownership',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => envelope({'id': 'cached'}),
        (request) async => envelope({'count': 0, 'results': []}),
      ]);
      final client = clientFor(adapter);
      await client.catalog.getEntry('cached');
      client.close();
      client.close();
      await expectLater(
        client.catalog.search(CatalogQuery()),
        throwsA(isA<ClientClosedException>()),
      );
      await expectLater(
        client.catalog.getEntry('cached'),
        throwsA(isA<ClientClosedException>()),
      );
      await expectLater(
        client.datastore.search('', DataStoreQuery()),
        throwsA(isA<ClientClosedException>()),
      );
      await expectLater(
        client.resources.download(ResourceMetadata.fromJson({})),
        throwsA(isA<ClientClosedException>()),
      );
      expect(adapter.closeCount, 0);
      expect(
        (await clientFor(adapter).catalog.search(CatalogQuery())).total,
        0,
      );
      expect(adapter.requests, hasLength(2));
    },
  );

  test('configured adapter ownership closes it exactly once', () {
    final adapter = ScriptedAdapter([]);
    final client = clientFor(adapter, own: true);
    client.close();
    client.close();
    expect(adapter.closeCount, 1);
  });

  for (final closeClient in [false, true]) {
    test(
      '${closeClient ? 'closing' : 'cancelling'} aborts an active download source',
      () async {
        final cancelled = Completer<void>();
        final source = StreamController<Uint8List>(
          onCancel: cancelled.complete,
        );
        source.add(Uint8List.fromList([1]));
        final adapter = ScriptedAdapter([
          (request) async => ResponseBody(source.stream, 200),
        ]);
        final client = clientFor(adapter);
        final cancellation = CancellationController();
        final download = await client.resources.download(
          ResourceMetadata.fromJson({
            'id': 'stream',
            'url': 'https://files.test/stream',
          }),
          cancellation: cancellation.signal,
        );
        final failure = expectLater(
          download.bytes.drain<void>(),
          throwsA(
            closeClient
                ? isA<ClientClosedException>()
                : isA<CancelledException>(),
          ),
        );
        if (closeClient) {
          client.close();
        } else {
          cancellation.cancel('stop');
        }
        await failure;
        await cancelled.future;
        expect(adapter.closeCount, 0);
      },
    );
  }
}
