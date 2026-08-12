import 'dart:convert';
import 'dart:io';

import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/ckan_executor.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/core/metadata_cache.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/catalog/catalog_query.dart';
import 'package:data_gov_gr/src/models/catalog/organization.dart';
import 'package:data_gov_gr/src/services/catalog_service.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import '../support/fake_clock.dart';

Map<String, Object?> fixture(String name) => Map<String, Object?>.from(
  jsonDecode(File('test/fixtures/v2/catalog/$name.json').readAsStringSync())
      as Map,
);

ScriptedStep result(Object? value) =>
    (_) async => ResponseBody.fromString(
      jsonEncode({'success': true, 'result': value}),
      200,
    );

Map<String, Object?> page(List<Object?> entries, int count) => {
  'count': count,
  'results': entries,
};

Map<String, Object?> entry(String id) => {'id': id, 'type': 'dataset'};

final class Harness {
  Harness(List<ScriptedStep> steps, {MetadataCachePolicy? policy}) {
    adapter = ScriptedAdapter(steps);
    transport = HttpTransport(
      DataGovConfig(actionBaseUrl: base, retry: RetryPolicy(maxAttempts: 1)),
      adapter: adapter,
      now: clock.now,
      wait: clock.wait,
      jitter: clock.jitter,
    );
    cache = MetadataCache(
      policy ?? MetadataCachePolicy.defaults,
      now: clock.now,
    );
    catalog = CatalogService(CkanExecutor(transport, base), cache);
    addTearDown(transport.close);
  }

  static final base = Uri.parse('https://selected.test/api/3/action/');
  final clock = FakeClock(DateTime.utc(2026));
  late final ScriptedAdapter adapter;
  late final HttpTransport transport;
  late final MetadataCache cache;
  late final CatalogService catalog;
}

void main() {
  test(
    'search retains every kind, resource, malformed URL and raw facet key',
    () async {
      final h = Harness([result(fixture('mixed_entries'))]);
      final found = await h.catalog.search(CatalogQuery());
      expect(found.entries.map((e) => e.kind), [
        'dataset',
        'service',
        'decision',
        'future-kind',
      ]);
      expect(found.entries.first.resources.length, 3);
      expect(found.entries.first.resources[1].url, 'http://bad host/file.csv');
      expect(found.entries.first.resources[1].fileUri, isNull);
      expect(found.entries.first.raw['custom'], {'retained': true});
      expect(found.entries.last.resources.single.id, 'no-url');
      expect(found.entries.first.metadataCreated, isNull);
      expect(found.rawFacets['theme'], {
        'items': [
          {'name': '["AGRI", "ECON"]', 'count': 2},
        ],
      });
      expect(found.total, 4);
      expect(found.requestedPageSize, 100);
      expect(found.effectivePageSize, isNull);
      expect(h.catalog.actionBaseUrl, Harness.base);
    },
  );

  test('serializes the package search query and never caches search', () async {
    final h = Harness([result(page([], 0)), result(page([], 7))]);
    final query = CatalogQuery(
      text: 'water',
      filters: ['type:dataset', 'organization:city'],
      facets: ['theme', 'type'],
      sort: 'name asc',
      offset: 9,
      pageSize: 23,
    );
    expect((await h.catalog.search(query)).total, 0);
    expect((await h.catalog.search(query)).total, 7);
    final request = h.adapter.requests.first;
    expect(request.uri.path, '/api/3/action/package_search');
    expect(request.method, 'GET');
    expect(request.uri.queryParameters, {
      'q': 'water',
      'fq': '(type:dataset) AND (organization:city)',
      'facet.field': '["theme","type"]',
      'sort': 'name asc',
      'start': '9',
      'rows': '23',
    });
  });

  test('independent filters preserve OR precedence', () async {
    final h = Harness([result(page([], 0))]);
    await h.catalog.search(
      CatalogQuery(
        filters: ['type:dataset OR type:service', 'organization:city'],
      ),
    );
    expect(
      h.adapter.requests.single.uri.queryParameters['fq'],
      '(type:dataset OR type:service) AND (organization:city)',
    );
  });

  test('traverses 1203 entries without a catalog cap', () async {
    final h = Harness([
      for (var offset = 0; offset < 1203; offset += 100)
        result(
          page([
            for (var i = offset; i < offset + 100 && i < 1203; i++)
              entry('id-$i'),
          ], 1203),
        ),
    ]);
    expect(await h.catalog.entries(CatalogQuery()).length, 1203);
    expect(h.adapter.requests.length, 13);
    expect(h.adapter.requests.last.uri.queryParameters['start'], '1200');
    expect(h.adapter.requests.first.uri.queryParameters['sort'], 'id asc');
  });

  test('clamped and short pages advance by their actual count', () async {
    final h = Harness([
      result(page([entry('a'), entry('b')], 4)),
      result(page([entry('c')], 4)),
      result(page([entry('d')], 4)),
    ]);
    expect(
      (await h.catalog.entries(CatalogQuery()).toList()).map((e) => e.id),
      ['a', 'b', 'c', 'd'],
    );
    expect(h.adapter.requests.map((r) => r.uri.queryParameters['start']), [
      '0',
      '2',
      '3',
    ]);
  });

  test(
    'empty page stops even when the source total still predicts entries',
    () async {
      final h = Harness([
        result(page([entry('a')], 99)),
        result(page([], 99)),
      ]);
      expect(await h.catalog.entries(CatalogQuery()).length, 1);
      expect(h.adapter.requests.length, 2);
    },
  );

  test('each search page reports its changed source total', () async {
    final h = Harness([
      result(page([entry('a')], 5)),
      result(page([entry('b')], 2)),
    ]);
    expect((await h.catalog.search(CatalogQuery())).total, 5);
    expect((await h.catalog.search(CatalogQuery(offset: 1))).total, 2);
  });

  test('traversal stops at the most recently published total', () async {
    final h = Harness([
      result(page([entry('a')], 5)),
      result(page([entry('b')], 2)),
    ]);
    expect(await h.catalog.entries(CatalogQuery()).length, 2);
    expect(h.adapter.requests.length, 2);
  });

  for (final repeated in [true, false]) {
    test(
      'rejects ${repeated ? 'repeated pages' : 'overlapping duplicate IDs'}',
      () async {
        final h = Harness([
          result(page([entry('a'), entry('b')], 5)),
          result(
            page(
              repeated ? [entry('a'), entry('b')] : [entry('c'), entry('b')],
              5,
            ),
          ),
        ]);
        await expectLater(
          h.catalog.entries(CatalogQuery()).toList(),
          throwsA(isA<PaginationException>()),
        );
        expect(h.adapter.requests.length, 2);
      },
    );
  }

  test('rejects duplicate identifiers within a page', () async {
    final h = Harness([
      result(page([entry('a'), entry('a')], 2)),
    ]);
    await expectLater(
      h.catalog.entries(CatalogQuery()).toList(),
      throwsA(isA<PaginationException>()),
    );
  });

  test('cancellation between emitted entries prevents another page', () async {
    final h = Harness([
      result(page([entry('a')], 5)),
    ]);
    final cancellation = CancellationController();
    await expectLater(
      h.catalog.entries(CatalogQuery(), cancellation: cancellation.signal).map((
        e,
      ) {
        cancellation.cancel();
        return e;
      }).toList(),
      throwsA(isA<CancelledException>()),
    );
    expect(h.adapter.requests.length, 1);
  });

  test('stopping a stream subscription does not fetch another page', () async {
    final h = Harness([
      result(page([entry('a')], 5)),
    ]);
    expect((await h.catalog.entries(CatalogQuery()).first).id, 'a');
    expect(h.adapter.requests.length, 1);
  });

  test(
    'package_show and resource_show cache separately with exact IDs',
    () async {
      final h = Harness([
        result({'id': 'same', 'type': 'service'}),
        result({'id': 'same', 'url': 'bad url'}),
      ]);
      expect((await h.catalog.getEntry('same')).kind, 'service');
      expect((await h.catalog.getResource('same')).url, 'bad url');
      expect((await h.catalog.getEntry('same')).id, 'same');
      expect((await h.catalog.getResource('same')).fileUri, isNull);
      expect(h.adapter.requests.map((r) => r.uri.path), [
        '/api/3/action/package_show',
        '/api/3/action/resource_show',
      ]);
      expect(h.adapter.requests.map((r) => r.uri.queryParameters), [
        {'id': 'same'},
        {'id': 'same'},
      ]);
    },
  );

  test(
    'entry refresh replaces cached metadata and TTL expires from insertion',
    () async {
      final h = Harness([
        result({'id': 'a', 'title': 'old'}),
        result({'id': 'a', 'title': 'new'}),
        result({'id': 'a', 'title': 'expired'}),
      ]);
      expect((await h.catalog.getEntry('a')).title, 'old');
      h.clock.advance(const Duration(minutes: 4));
      expect((await h.catalog.getEntry('a')).title, 'old');
      expect((await h.catalog.getEntry('a', refresh: true)).title, 'new');
      h.clock.advance(const Duration(minutes: 5));
      expect((await h.catalog.getEntry('a')).title, 'expired');
      expect(h.adapter.requests.length, 3);
    },
  );

  test('cache accounts for retained UTF8 JSON bytes', () async {
    final h = Harness([
      result({'id': 'ααα'}),
      result({'id': 'ααα'}),
    ], policy: MetadataCachePolicy(maxBytes: 14));
    await h.catalog.getEntry('a');
    await h.catalog.getEntry('a');
    expect(h.adapter.requests.length, 2);
  });

  test(
    'clearCache removes catalog metadata and preserves unrelated cache values',
    () async {
      final h = Harness([result(entry('a')), result(entry('a'))]);
      h.cache.put('unrelated', {'id': 'other'}, jsonBytes: 14);
      await h.catalog.getEntry('a');
      h.catalog.clearCache();
      await h.catalog.getEntry('a');
      expect(h.adapter.requests.length, 2);
      expect(h.cache.get('unrelated'), {'id': 'other'});
    },
  );

  test(
    'organization_list uses POST full fields and caches page coordinates separately',
    () async {
      final organizations = fixture('organizations')['organizations'] as List;
      final h = Harness([
        result(organizations.sublist(0, 2)),
        result(organizations.sublist(2)),
      ]);
      final first = await h.catalog.organizations(
        OrganizationQuery(pageSize: 2),
      );
      expect(first.organizations.map((o) => o.id), ['org-1', 'org-2']);
      expect(first.organizations.first.raw['custom'], {'retained': true});
      expect(first.total, isNull);
      await h.catalog.organizations(OrganizationQuery(pageSize: 2));
      final last = await h.catalog.organizations(
        OrganizationQuery(offset: 2, pageSize: 2),
      );
      expect(last.organizations.single.id, 'org-3');
      final request = h.adapter.requests.first;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/3/action/organization_list');
      expect(jsonDecode(request.data as String), {
        'all_fields': true,
        'limit': 2,
        'offset': 0,
      });
      expect(h.adapter.requests.length, 2);
    },
  );

  test('allOrganizations follows short nonempty pages until empty', () async {
    final organizations = fixture('organizations')['organizations'] as List;
    final h = Harness([
      result(organizations.sublist(0, 2)),
      result(organizations.sublist(2)),
      result([]),
    ]);
    expect(
      (await h.catalog.allOrganizations(OrganizationQuery()).toList()).map(
        (o) => o.id,
      ),
      ['org-1', 'org-2', 'org-3'],
    );
    expect(
      h.adapter.requests.map(
        (r) => (jsonDecode(r.data as String) as Map)['offset'],
      ),
      [0, 2, 3],
    );
  });

  test('organization traversal rejects repeated IDs', () async {
    final h = Harness([
      result([
        {'id': 'a'},
      ]),
      result([
        {'id': 'a'},
      ]),
    ]);
    await expectLater(
      h.catalog.allOrganizations(OrganizationQuery()).toList(),
      throwsA(isA<PaginationException>()),
    );
  });

  test('organization cancellation prevents the next page', () async {
    final h = Harness([
      result([
        {'id': 'a'},
      ]),
    ]);
    final cancellation = CancellationController();
    await expectLater(
      h.catalog
          .allOrganizations(
            OrganizationQuery(),
            cancellation: cancellation.signal,
          )
          .map((o) {
            cancellation.cancel();
            return o;
          })
          .toList(),
      throwsA(isA<CancelledException>()),
    );
    expect(h.adapter.requests.length, 1);
  });

  test(
    'themes uses the audited POST action and caches raw metadata safely',
    () async {
      final h = Harness([
        result(fixture('themes')),
        result({
          'tags': [
            {'name': 'NEW'},
          ],
        }),
      ]);
      final themes = await h.catalog.themes();
      expect(themes.map((t) => t.code), ['AGRI', 'ECON', 'UNKNOWN']);
      expect(themes.first.labelEl, 'Γεωργία');
      expect(themes.first.labelEn, 'Agriculture');
      expect(themes.first.authorityUri, 'https://authority.test/AGRI');
      expect(themes[1].labelEl, isNull);
      expect(themes[1].labelEn, isNull);
      expect(themes.last.labelEl, isNull);
      expect((await h.catalog.themes()).first.raw['custom'], true);
      expect((await h.catalog.themes(refresh: true)).single.code, 'NEW');
      final request = h.adapter.requests.first;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/3/action/vocabularyadmin_vocabulary_show');
      expect(jsonDecode(request.data as String), {'id': 'Data theme'});
      expect(h.adapter.requests.length, 2);
    },
  );

  for (final closed in [false, true]) {
    test(
      '${closed ? 'closed' : 'cancelled'} operations reject cached metadata',
      () async {
        final h = Harness([
          result(entry('a')),
          result({'id': 'r'}),
          result([]),
          result({'tags': []}),
        ]);
        await h.catalog.getEntry('a');
        await h.catalog.getResource('r');
        await h.catalog.organizations(OrganizationQuery());
        await h.catalog.themes();
        final cancellation = CancellationController();
        if (closed) {
          h.transport.close();
        } else {
          cancellation.cancel();
        }
        final failure = closed
            ? isA<ClientClosedException>()
            : isA<CancelledException>();
        await expectLater(
          h.catalog.getEntry('a', cancellation: cancellation.signal),
          throwsA(failure),
        );
        await expectLater(
          h.catalog.getResource('r', cancellation: cancellation.signal),
          throwsA(failure),
        );
        await expectLater(
          h.catalog.organizations(
            OrganizationQuery(),
            cancellation: cancellation.signal,
          ),
          throwsA(failure),
        );
        await expectLater(
          h.catalog.themes(cancellation: cancellation.signal),
          throwsA(failure),
        );
        expect(h.adapter.requests.length, 4);
      },
    );
  }

  for (final bad in [
    null,
    [],
    {'count': 2},
    {'count': '2', 'results': []},
    {
      'count': 1,
      'results': ['bad'],
    },
  ]) {
    test('malformed package search raises DecodeException: $bad', () async {
      final h = Harness([result(bad)]);
      await expectLater(
        h.catalog.search(CatalogQuery()),
        throwsA(isA<DecodeException>()),
      );
    });
  }

  test('malformed metadata is not cached', () async {
    final h = Harness([result([]), result(entry('a'))]);
    await expectLater(h.catalog.getEntry('a'), throwsA(isA<DecodeException>()));
    expect((await h.catalog.getEntry('a')).id, 'a');
    expect(h.adapter.requests.length, 2);
  });

  test('resource refresh and TTL return newly published metadata', () async {
    final h = Harness([
      result({'id': 'r', 'format': 'old'}),
      result({'id': 'r', 'format': 'new'}),
      result({'id': 'r', 'format': 'expired'}),
    ]);
    expect((await h.catalog.getResource('r')).format, 'old');
    expect((await h.catalog.getResource('r', refresh: true)).format, 'new');
    expect((await h.catalog.getResource('r')).format, 'new');
    h.clock.advance(const Duration(minutes: 5));
    expect((await h.catalog.getResource('r')).format, 'expired');
    expect(h.adapter.requests.length, 3);
  });

  test(
    'organization refresh and TTL return newly published metadata',
    () async {
      final h = Harness([
        result([
          {'id': 'old'},
        ]),
        result([
          {'id': 'new'},
        ]),
        result([
          {'id': 'expired'},
        ]),
      ]);
      final query = OrganizationQuery();
      expect(
        (await h.catalog.organizations(query)).organizations.single.id,
        'old',
      );
      expect(
        (await h.catalog.organizations(
          query,
          refresh: true,
        )).organizations.single.id,
        'new',
      );
      expect(
        (await h.catalog.organizations(query)).organizations.single.id,
        'new',
      );
      h.clock.advance(const Duration(minutes: 5));
      expect(
        (await h.catalog.organizations(query)).organizations.single.id,
        'expired',
      );
      expect(h.adapter.requests.length, 3);
    },
  );

  test('theme TTL expires without extending on a cache read', () async {
    final h = Harness([
      result({
        'tags': [
          {'name': 'old'},
        ],
      }),
      result({
        'tags': [
          {'name': 'expired'},
        ],
      }),
    ]);
    expect((await h.catalog.themes()).single.code, 'old');
    h.clock.advance(const Duration(minutes: 4));
    expect((await h.catalog.themes()).single.code, 'old');
    h.clock.advance(const Duration(minutes: 1));
    expect((await h.catalog.themes()).single.code, 'expired');
    expect(h.adapter.requests.length, 2);
  });

  test(
    'refresh failure propagates without stale metadata substitution',
    () async {
      final h = Harness([
        result(entry('a')),
        (_) async => ResponseBody.fromString(
          '{"success":false,"error":{"message":"unavailable"}}',
          200,
        ),
      ]);
      await h.catalog.getEntry('a');
      await expectLater(
        h.catalog.getEntry('a', refresh: true),
        throwsA(isA<CkanActionException>()),
      );
      expect(h.adapter.requests.length, 2);
    },
  );

  test('catalog traversal honors caller offset', () async {
    final h = Harness([
      result(page([entry('a')], 8)),
      result(page([entry('b')], 8)),
    ]);
    expect(await h.catalog.entries(CatalogQuery(offset: 6)).length, 2);
    expect(h.adapter.requests.map((r) => r.uri.queryParameters['start']), [
      '6',
      '7',
    ]);
  });

  test('organization traversal honors caller offset', () async {
    final h = Harness([
      result([
        {'id': 'a'},
      ]),
      result([]),
    ]);
    expect(
      await h.catalog.allOrganizations(OrganizationQuery(offset: 6)).length,
      1,
    );
    expect(
      h.adapter.requests.map(
        (r) => (jsonDecode(r.data as String) as Map)['offset'],
      ),
      [6, 7],
    );
  });

  test('malformed organization response raises DecodeException', () async {
    final h = Harness([
      result(['name-only']),
    ]);
    await expectLater(
      h.catalog.organizations(OrganizationQuery()),
      throwsA(isA<DecodeException>()),
    );
  });

  test(
    'missing vocabulary tags raise DecodeException rather than invented themes',
    () async {
      final h = Harness([
        result({'name': 'Data theme'}),
      ]);
      await expectLater(h.catalog.themes(), throwsA(isA<DecodeException>()));
    },
  );

  test('clearing catalog metadata frees payload capacity', () async {
    final h = Harness([
      result(entry('a')),
    ], policy: MetadataCachePolicy(maxBytes: 100));
    h.cache.put('unrelated', {'id': 'other'}, jsonBytes: 20);
    await h.catalog.getEntry('a');
    h.catalog.clearCache();
    h.cache.put('another', {'id': 'another'}, jsonBytes: 80);
    expect(h.cache.get('unrelated'), {'id': 'other'});
    expect(h.cache.get('another'), {'id': 'another'});
  });
}
