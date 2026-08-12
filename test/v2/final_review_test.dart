import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:data_gov_gr/src/core/ckan_executor.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/core/metadata_cache.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import '../support/fake_clock.dart';

void main() {
  test(
    'public diagnostics consume complete signed URLs and retain safe context',
    () {
      final cause = StateError('private original');
      for (final url in [
        "https://files.test/file?token=prefix'PRIVATE_SUFFIX&limit=10",
        'https://files.test/file?X-Amz-Credential=PRIVATE_USER&X-Amz-Signature=PRIVATE_SIG&limit=10',
        'https://files.test/file?X-Goog-Credential=PRIVATE_USER&X-Goog-Signature=PRIVATE_SIG&limit=10',
        'https://files.test/file?sig=PRIVATE_SIG&limit=10',
        "https://files.test/file?token=%FF'PRIVATE_SUFFIX",
      ]) {
        final error = CkanActionException(
          "Failed ('$url'); safe context",
          details: {
            'nested': [
              {'url': url},
            ],
            'safe': 'use sort id',
          },
          originalError: cause,
        );
        final diagnostic = '${error.message} $error ${error.details}';
        expect(diagnostic, isNot(contains('PRIVATE')));
        expect(diagnostic, contains('safe context'));
        expect(diagnostic, contains('use sort id'));
        expect(error.message, contains("'); safe context"));
        expect(error.originalError, same(cause));
        if (!url.contains('%FF')) expect(diagnostic, contains('limit=10'));
      }
    },
  );

  for (final surface in ['entries', 'organizations', 'pages', 'records']) {
    for (final later in [false, true]) {
      test(
        '$surface cancels pending ${later ? 'later' : 'first'} page promptly',
        () async {
          final pending = Completer<ResponseBody>();
          final started = Completer<void>();
          final adapter = ScriptedAdapter([
            if (later) (_) async => _firstPage(surface),
            (_) {
              started.complete();
              return pending.future;
            },
          ]);
          final client = DataGovClient(adapter: adapter);
          addTearDown(client.close);
          final subscription = _traversal(client, surface).listen((_) {});
          await started.future;
          final cancellation = subscription.cancel();
          await expectLater(
            cancellation.timeout(const Duration(milliseconds: 200)),
            completes,
          );
          expect(adapter.requests.last.cancelToken!.isCancelled, isTrue);
          expect(adapter.requests, hasLength(later ? 2 : 1));
          pending.complete(ResponseBody.fromString('{}', 200));
        },
      );
    }
    test('$surface cancels retry backoff without another request', () async {
      final clock = FakeClock(DateTime.utc(2026));
      final adapter = ScriptedAdapter([
        (_) async => ResponseBody.fromString('unavailable', 503),
      ]);
      final transport = HttpTransport(
        DataGovConfig(),
        adapter: adapter,
        now: clock.now,
        wait: clock.wait,
      );
      addTearDown(transport.close);
      final executor = CkanExecutor(transport, transport.config.actionBaseUrl);
      final subscription = _serviceTraversal(
        CatalogService(executor, MetadataCache(transport.config.metadataCache)),
        DataStoreService(executor),
        surface,
      ).listen((_) {});
      for (var i = 0; i < 100 && clock.pendingWaitCount == 0; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      expect(clock.pendingWaitCount, 1);
      await expectLater(
        subscription.cancel().timeout(const Duration(milliseconds: 200)),
        completes,
      );
      expect(clock.pendingWaitCount, 0);
      expect(adapter.requests, hasLength(1));
    });
  }

  for (final pages in [
    [
      [
        {'_id': 1},
        {'_id': 2},
      ],
      [
        {'_id': 2},
        {'_id': 3},
      ],
    ],
    [
      [
        {'_id': 1},
        {'_id': 1},
      ],
    ],
    [
      [
        {'_id': 1},
        {'value': 'no id'},
      ],
      [
        {'_id': 1},
        {'value': 'no id'},
      ],
    ],
  ]) {
    test('DataStore rejects repeated available identities $pages', () async {
      final adapter = ScriptedAdapter([
        for (var i = 0; i < pages.length; i++)
          (_) async => _success({
            'records': pages[i],
            'offset': i * 2,
            'total': pages.length * 2,
          }),
      ]);
      final client = DataGovClient(adapter: adapter);
      addTearDown(client.close);
      await expectLater(
        client.datastore.records('r', DataStoreQuery()).toList(),
        throwsA(isA<PaginationException>()),
      );
    });
  }

  test(
    'HTTP validation retains sanitized server explanation and CKAN action',
    () async {
      final client = DataGovClient(
        adapter: ScriptedAdapter([
          (_) async => ResponseBody.fromString(
            jsonEncode({
              'success': false,
              'error': {
                '__type': 'Validation Error',
                'sort': ['Unknown field _id'],
                'url': "https://files.test/?token=a'PRIVATE",
                'token': 'PRIVATE',
              },
            }),
            409,
          ),
        ]),
      );
      addTearDown(client.close);
      await expectLater(
        client.datastore.search('r', DataStoreQuery()),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.action, 'action', 'datastore_search')
              .having((e) => e.statusCode, 'status', 409)
              .having(
                (e) => e.details.toString(),
                'explanation',
                contains('Unknown field _id'),
              )
              .having(
                (e) => e.details.toString(),
                'safe details',
                isNot(contains('PRIVATE')),
              ),
        ),
      );
    },
  );
  for (final body in ['not JSON', 'x' * 100000]) {
    test(
      'HTTP error remains primary for invalid or oversized body ${body.length}',
      () async {
        final client = DataGovClient(
          adapter: ScriptedAdapter([
            (_) async => ResponseBody.fromString(body, 409),
          ]),
        );
        addTearDown(client.close);
        await expectLater(
          client.datastore.search('r', DataStoreQuery()),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.action, 'action', 'datastore_search')
                .having((e) => e.statusCode, 'status', 409),
          ),
        );
      },
    );
  }
  test(
    'pending HTTP error body cannot hold the primary failure indefinitely',
    () async {
      var cancelled = false;
      final body = StreamController<Uint8List>(
        onCancel: () {
          cancelled = true;
        },
      );
      final client = DataGovClient(
        adapter: ScriptedAdapter([(_) async => ResponseBody(body.stream, 409)]),
      );
      addTearDown(client.close);
      await expectLater(
        client.datastore
            .search('r', DataStoreQuery())
            .timeout(const Duration(seconds: 1)),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.action,
            'action',
            'datastore_search',
          ),
        ),
      );
      expect(cancelled, isTrue);
      await body.close();
    },
  );

  for (final generator in [true, false]) {
    test(
      'HTTP error budget includes ${generator ? 'async generator' : 'asynchronous onCancel'} cleanup',
      () async {
        final release = Completer<void>();
        addTearDown(() {
          if (!release.isCompleted) release.complete();
        });
        final started = Completer<void>();
        var cleanupRequested = false;
        Stream<Uint8List> generated() async* {
          started.complete();
          try {
            await release.future;
          } finally {
            cleanupRequested = true;
          }
        }

        final controller = StreamController<Uint8List>(
          onListen: started.complete,
          onCancel: () async {
            cleanupRequested = true;
            await release.future;
            throw StateError('late diagnostic cleanup failure');
          },
        );
        final client = DataGovClient(
          adapter: ScriptedAdapter([
            (_) async =>
                ResponseBody(generator ? generated() : controller.stream, 409),
          ]),
        );
        addTearDown(client.close);
        final operation = client.datastore.search('r', DataStoreQuery());
        await started.future;
        await expectLater(
          operation.timeout(const Duration(milliseconds: 400)),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.statusCode, 'status', 409)
                .having((e) => e.action, 'action', 'datastore_search'),
          ),
        );
        if (!generator) expect(cleanupRequested, isTrue);
        release.complete();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(cleanupRequested, isTrue);
      },
    );
  }
  test(
    'HTTP diagnostic cleanup cannot delay external transport cancellation',
    () async {
      final release = Completer<void>();
      addTearDown(() {
        if (!release.isCompleted) release.complete();
      });
      final started = Completer<void>();
      final body = StreamController<Uint8List>(
        onListen: started.complete,
        onCancel: () => release.future,
      );
      final adapter = ScriptedAdapter([
        (_) async => ResponseBody(body.stream, 409),
      ]);
      final client = DataGovClient(adapter: adapter);
      addTearDown(client.close);
      final cancellation = CancellationController();
      final operation = client.datastore.search(
        'r',
        DataStoreQuery(),
        cancellation: cancellation.signal,
      );
      await started.future;
      cancellation.cancel();
      await expectLater(
        operation.timeout(const Duration(milliseconds: 400)),
        throwsA(isA<CancelledException>()),
      );
      expect(adapter.requests.single.cancelToken!.isCancelled, isTrue);
      release.complete();
    },
  );
  for (final network in [false, true]) {
    test(
      'CKAN ${network ? 'network' : 'decode'} failure retains action and original cause',
      () async {
        final client = DataGovClient(
          config: DataGovConfig(retry: RetryPolicy(maxAttempts: 1)),
          adapter: ScriptedAdapter([
            (_) async {
              if (network) throw StateError('transport failed');
              return ResponseBody.fromString('not JSON', 200);
            },
          ]),
        );
        addTearDown(client.close);
        await expectLater(
          client.datastore.search('r', DataStoreQuery()),
          throwsA(
            isA<DataGovException>()
                .having((e) => e.action, 'action', 'datastore_search')
                .having((e) => e.originalError, 'original cause', isNotNull),
          ),
        );
      },
    );
  }
  test(
    '503 Retry-After beyond deadline remains publicly inspectable',
    () async {
      final clock = FakeClock(DateTime.utc(2026));
      final transport = HttpTransport(
        DataGovConfig(),
        adapter: ScriptedAdapter([
          (_) async => ResponseBody.fromString(
            '{}',
            503,
            headers: {
              'retry-after': ['120'],
            },
          ),
        ]),
        now: clock.now,
        wait: clock.wait,
      );
      addTearDown(transport.close);
      await expectLater(
        CkanExecutor(
          transport,
          transport.config.actionBaseUrl,
        ).call('datastore_search'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.retryAt,
            'retryAt',
            DateTime.utc(2026, 1, 1, 0, 2),
          ),
        ),
      );
      expect(clock.pendingWaitCount, 0);
    },
  );

  for (final value in [
    '1e100',
    '9007199254740991.1',
    '-9007199254740991.1',
    '9.0071992547409911e15',
    '9007199254740992',
    '-9007199254740992',
    9007199254740992,
  ]) {
    test('typed count rejects nonportable $value with field and row', () {
      final record = <String, Object?>{
        'area': 'Area',
        'areaid': '1',
        'referencedate': '2026-01-01',
        'daytotal': value,
      };
      final provenance = SourceProvenance(
        resourceId: 'r',
        sourceUrl: 'u',
        retrievedAt: DateTime.utc(2026),
        sourceRow: 7,
      );
      expect(
        () => VaccinationData.fromSourceRecord(record, provenance: provenance),
        throwsA(
          isA<DecodeException>().having((e) => e.details, 'context', {
            'field': 'daytotal',
            'sourceRow': 7,
          }),
        ),
      );
      expect(record['daytotal'], value);
    });
  }
  for (final text in [
    '9007199254740991.0',
    '9.007199254740991e15',
    '-9007199254740991.0',
    '1e3',
  ]) {
    test('typed count preserves exact integral text $text', () {
      final model = VaccinationData.fromSourceRecord(
        {
          'area': 'Area',
          'areaid': '1',
          'referencedate': '2026-01-01',
          'daytotal': text,
        },
        provenance: SourceProvenance(
          resourceId: 'r',
          sourceUrl: 'u',
          retrievedAt: DateTime.utc(2026),
        ),
      );
      expect(model.dayTotal, switch (text) {
        '-9007199254740991.0' => -9007199254740991,
        '1e3' => 1000,
        _ => 9007199254740991,
      });
      expect(model.raw['daytotal'], text);
    });
  }

  for (final value in [9007199254740991, -9007199254740991, 0, -4]) {
    test('typed count preserves portable boundary $value', () {
      final model = VaccinationData.fromSourceRecord(
        {
          'area': 'Area',
          'areaid': '1',
          'referencedate': '2026-01-01',
          'daytotal': '$value',
        },
        provenance: SourceProvenance(
          resourceId: 'r',
          sourceUrl: 'u',
          retrievedAt: DateTime.utc(2026),
        ),
      );
      expect(model.dayTotal, value);
      expect(model.raw['daytotal'], '$value');
      expect(model.dayDiff, isNull);
    });
  }
}

Stream<Object?> _traversal(DataGovClient client, String surface) =>
    _serviceTraversal(client.catalog, client.datastore, surface);
Stream<Object?> _serviceTraversal(
  CatalogService catalog,
  DataStoreService datastore,
  String surface,
) => switch (surface) {
  'entries' => catalog.entries(CatalogQuery(pageSize: 1)),
  'organizations' => catalog.allOrganizations(OrganizationQuery(pageSize: 1)),
  'pages' => datastore.pages('r', DataStoreQuery(limit: 1)),
  _ => datastore.records('r', DataStoreQuery(limit: 1)),
};
ResponseBody _success(Object result) => ResponseBody.fromString(
  jsonEncode({'success': true, 'result': result}),
  200,
);
ResponseBody _firstPage(String surface) => _success(switch (surface) {
  'entries' => {
    'count': 2,
    'results': [
      {'id': 'a'},
    ],
  },
  'organizations' => [
    {'id': 'a'},
  ],
  _ => {
    'records': [
      {'_id': 1},
    ],
    'offset': 0,
    'total': 2,
  },
});
