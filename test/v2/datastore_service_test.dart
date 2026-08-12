import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/ckan_executor.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/core/raw_json.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/datastore/datastore_query.dart';
import 'package:data_gov_gr/src/services/datastore_service.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import '../support/fake_clock.dart';

void main() {
  final fixtures =
      jsonDecode(
            File('test/fixtures/v2/datastore/pages.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final reliable = (fixtures['reliable'] as List)
      .map((value) => Map<String, Object?>.from(value as Map))
      .toList();

  test(
    'search encodes exact server query without filter parameter overrides',
    () async {
      final rig = _Rig([_success(reliable.first)]);
      final page = await rig.service.search(
        'Αθήνα / ? & + resource',
        DataStoreQuery(
          filters: {
            'resource_id': 'other',
            'offset': 999,
            'limit': 1,
            'count': 2,
            'active': true,
            'null_value': null,
            'name': 'Αθήνα & +',
          },
          text: 'Αθήνα & + "exact"',
          fields: ['name', '_id'],
          sort: [DataStoreSort('name', descending: true), DataStoreSort('_id')],
          limit: 17,
          offset: 7,
        ),
      );
      final request = rig.adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/3/action/datastore_search');
      expect(request.uri.queryParameters, {
        'resource_id': 'Αθήνα / ? & + resource',
        'filters':
            '{"resource_id":"other","offset":999,"limit":1,"count":2,"active":true,"null_value":null,"name":"Αθήνα & +"}',
        'q': 'Αθήνα & + "exact"',
        'fields': 'name,_id',
        'sort': 'name desc,_id asc',
        'limit': '17',
        'offset': '7',
      });
      expect(page.offset, 0);
      expect(page.requestedLimit, 17);
    },
  );

  test('search preserves record types and complete source metadata', () async {
    final rig = _Rig([_success(reliable.first)]);
    final page = await rig.service.search('fixture-id', DataStoreQuery());
    expect(page.records, [
      {'_id': 1, 'value': 'Αθήνα', 'optional': null},
      {'_id': 2, 'value': '002'},
    ]);
    expect(page.fields.first, {'id': '_id', 'type': 'int'});
    expect(page.fields[1]['source_extension'], true);
    expect(page.raw['source_extension'], {'published': true});
    expect(page.total, 5);
    expect(page.totalEstimated, isFalse);
    expect(page.effectiveLimit, 2);
    expect(
      () => page.records.first['value'] = 'changed',
      throwsUnsupportedError,
    );
    expect(
      () => (page.raw['source_extension'] as Map)['published'] = false,
      throwsUnsupportedError,
    );
  });

  test('absent response offset preserves the requested first offset', () async {
    final rig = _Rig([
      _success(
        _page([
          {'_id': 8},
        ], total: 8),
      ),
    ]);
    final pages = await rig.service
        .pages('fixture-id', DataStoreQuery(offset: 7))
        .toList();
    expect(pages.single.offset, 7);
    expect(rig.adapter.requests.single.uri.queryParameters['offset'], '7');
    expect(pages.single.effectiveLimit, isNull);
  });

  for (final offset in [5, 10]) {
    test(
      'exact-end or beyond-end offset $offset returns empty source page',
      () async {
        final rig = _Rig([_success(_page([], total: 5, offset: offset))]);
        final rows = await rig.service
            .records('fixture-id', DataStoreQuery(offset: offset))
            .toList();
        expect(rows, isEmpty);
        expect(rig.adapter.requests, hasLength(1));
        expect(
          rig.adapter.requests.single.uri.queryParameters['offset'],
          '$offset',
        );
      },
    );
  }

  test(
    'server pages of two traverse five rows using actual count and reliable total',
    () async {
      final rig = _Rig(reliable.map(_success).toList());
      final rows = await rig.service
          .records('fixture-id', DataStoreQuery(limit: 100))
          .toList();
      expect(rows.map((row) => row['_id']), [1, 2, 3, 4, 5]);
      expect(
        rig.adapter.requests.map(
          (request) => request.uri.queryParameters['offset'],
        ),
        ['0', '2', '4'],
      );
      expect(
        rig.adapter.requests.every(
          (request) => request.uri.queryParameters['limit'] == '100',
        ),
        isTrue,
      );
    },
  );

  for (final estimated in [true, null]) {
    test(
      'estimated=$estimated total traverses short pages until empty',
      () async {
        final rig = _Rig([
          _success(
            _page(
              [
                {'_id': 1},
                {'_id': 2},
              ],
              total: estimated == true ? 1 : null,
              estimated: estimated,
            ),
          ),
          _success(
            _page(
              [
                {'_id': 3},
              ],
              total: estimated == true ? 1 : null,
              estimated: estimated,
            ),
          ),
          _success(
            _page(
              [],
              total: estimated == true ? 1 : null,
              estimated: estimated,
            ),
          ),
        ]);
        final pages = await rig.service
            .pages('fixture-id', DataStoreQuery())
            .toList();
        expect(pages.expand((page) => page.records).map((row) => row['_id']), [
          1,
          2,
          3,
        ]);
        expect(pages.first.totalEstimated, estimated == true);
        expect(pages.first.total, estimated == true ? 1 : null);
        expect(
          rig.adapter.requests.map(
            (request) => request.uri.queryParameters['offset'],
          ),
          ['0', '2', '3'],
        );
      },
    );
  }

  test('identical_projected_values_are_valid_records', () async {
    final rig = _Rig([
      _success(
        _page([
          {'value': 'equal'},
          {'value': 'equal'},
        ], offset: 0),
      ),
      _success(
        _page([
          {'value': 'equal'},
          {'value': 'equal'},
        ], offset: 2),
      ),
      _success(_page([], offset: 4)),
    ]);
    final rows = await rig.service
        .records('fixture-id', DataStoreQuery(fields: ['value']))
        .toList();
    expect(rows, List.generate(4, (_) => {'value': 'equal'}));
  });

  test(
    'repeated identity page reports pagination instead of looping',
    () async {
      final rig = _Rig([
        _success(
          _page([
            {'_id': 1},
            {'_id': 2},
          ]),
        ),
        _success(
          _page([
            {'_id': 1},
            {'_id': 2},
          ]),
        ),
      ]);
      await expectLater(
        rig.service.records('fixture-id', DataStoreQuery()).toList(),
        throwsA(isA<PaginationException>()),
      );
      expect(rig.adapter.requests, hasLength(2));
    },
  );

  test('empty response with backward offset reports pagination', () async {
    final rig = _Rig([
      _success(
        _page([
          {'_id': 1},
          {'_id': 2},
        ], offset: 0),
      ),
      _success(_page([], offset: 0)),
    ]);
    await expectLater(
      rig.service.pages('fixture-id', DataStoreQuery()).toList(),
      throwsA(isA<PaginationException>()),
    );
    expect(rig.adapter.requests, hasLength(2));
    expect(rig.adapter.requests[1].uri.queryParameters['offset'], '2');
  });

  test('explicit response offset nonprogress reports pagination', () async {
    final rig = _Rig([
      _success(
        _page([
          {'_id': 1},
          {'_id': 2},
        ], offset: 0),
      ),
      _success(
        _page([
          {'_id': 3},
          {'_id': 4},
        ], offset: 0),
      ),
    ]);
    await expectLater(
      rig.service.pages('fixture-id', DataStoreQuery()).toList(),
      throwsA(isA<PaginationException>()),
    );
    expect(rig.adapter.requests, hasLength(2));
  });

  test(
    'explicit advancing response offset supplies the next coordinate',
    () async {
      final rig = _Rig([
        _success(
          _page([
            {'_id': 4},
          ], offset: 3),
        ),
        _success(_page([], offset: 4)),
      ]);
      final pages = await rig.service
          .pages('fixture-id', DataStoreQuery())
          .toList();
      expect(pages.first.offset, 3);
      expect(rig.adapter.requests[1].uri.queryParameters['offset'], '4');
    },
  );

  test('empty sort requests deterministic identity ordering', () async {
    final rig = _Rig([_success(_page([]))]);
    await rig.service.search('fixture-id', DataStoreQuery());
    expect(rig.adapter.requests.single.uri.queryParameters['sort'], '_id asc');
  });

  test(
    'rejected default identity ordering reports validation without fallback',
    () async {
      final rig = _Rig([
        (_) async => ResponseBody.fromString(
          '{"success":false,"error":{"__type":"Validation Error","sort":["Unknown field _id"]}}',
          200,
        ),
      ]);
      await expectLater(
        rig.service.search('fixture-id', DataStoreQuery()),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.action,
            'action',
            'datastore_search',
          ),
        ),
      );
      expect(rig.adapter.requests, hasLength(1));
    },
  );

  for (final mode in ['cancelled', 'closed']) {
    test('$mode after page prevents the next fetch', () async {
      final rig = _Rig([_success(reliable.first)]);
      final cancellation = CancellationController();
      final iterator = StreamIterator(
        rig.service.pages(
          'fixture-id',
          DataStoreQuery(),
          cancellation: cancellation.signal,
        ),
      );
      addTearDown(iterator.cancel);
      expect(await iterator.moveNext(), isTrue);
      if (mode == 'cancelled') {
        cancellation.cancel();
      } else {
        rig.transport.close();
      }
      await expectLater(
        iterator.moveNext(),
        throwsA(
          mode == 'cancelled'
              ? isA<CancelledException>()
              : isA<ClientClosedException>(),
        ),
      );
      expect(rig.adapter.requests, hasLength(1));
    });
  }

  test(
    'page stream fetches lazily and waits for the paused consumer',
    () async {
      final rig = _Rig(reliable.map(_success).toList());
      final stream = rig.service.pages('fixture-id', DataStoreQuery());
      expect(rig.adapter.requests, isEmpty);
      final iterator = StreamIterator(stream);
      expect(await iterator.moveNext(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(rig.adapter.requests, hasLength(1));
      expect(await iterator.moveNext(), isTrue);
      expect(rig.adapter.requests, hasLength(2));
      await iterator.cancel();
      await Future<void>.delayed(Duration.zero);
      expect(rig.adapter.requests, hasLength(2));
    },
  );

  test(
    'record stream retains only its current page until rows are consumed',
    () async {
      final rig = _Rig(reliable.map(_success).toList());
      final iterator = StreamIterator(
        rig.service.records('fixture-id', DataStoreQuery()),
      );
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current['_id'], 1);
      await Future<void>.delayed(Duration.zero);
      expect(rig.adapter.requests, hasLength(1));
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current['_id'], 2);
      expect(rig.adapter.requests, hasLength(1));
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current['_id'], 3);
      expect(rig.adapter.requests, hasLength(2));
      await iterator.cancel();
    },
  );

  test('search has no implicit response cache', () async {
    final rig = _Rig([
      _success(
        _page([
          {'_id': 1, 'value': 'first'},
        ]),
      ),
      _success(
        _page([
          {'_id': 1, 'value': 'second'},
        ]),
      ),
    ]);
    expect(
      (await rig.service.search(
        'fixture-id',
        DataStoreQuery(),
      )).records.single['value'],
      'first',
    );
    expect(
      (await rig.service.search(
        'fixture-id',
        DataStoreQuery(),
      )).records.single['value'],
      'second',
    );
    expect(rig.adapter.requests, hasLength(2));
  });

  for (final result in [
    null,
    [],
    {'records': 'bad'},
    {
      'records': [1],
    },
    {'records': [], 'offset': -1},
    {'records': [], 'total': '5'},
  ]) {
    test('malformed DataStore result $result reports decode error', () async {
      final rig = _Rig([_success(result)]);
      await expectLater(
        rig.service.search('fixture-id', DataStoreQuery()),
        throwsA(isA<DecodeException>()),
      );
    });
  }
}

JsonObject _page(
  List<JsonObject> records, {
  int? offset,
  int? total,
  bool? estimated,
}) => {
  'records': records,
  'fields': [
    {'id': '_id', 'type': 'int'},
  ],
  if (offset != null) 'offset': offset,
  if (total != null) 'total': total,
  if (estimated != null) 'total_was_estimated': estimated,
};

ScriptedStep _success(Object? result) =>
    (_) async => ResponseBody.fromString(
      jsonEncode({'success': true, 'result': result}),
      200,
    );

final class _Rig {
  _Rig(List<ScriptedStep> steps) {
    adapter = ScriptedAdapter(steps);
    final clock = FakeClock(DateTime.utc(2026, 1, 1));
    final base = Uri.parse('https://portal.test/api/3/action/');
    transport = HttpTransport(
      DataGovConfig(actionBaseUrl: base),
      adapter: adapter,
      now: clock.now,
      wait: clock.wait,
      jitter: clock.jitter,
    );
    service = DataStoreService(CkanExecutor(transport, base));
    addTearDown(transport.close);
  }
  late final ScriptedAdapter adapter;
  late final HttpTransport transport;
  late final DataStoreService service;
}
