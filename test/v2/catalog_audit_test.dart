import 'dart:convert';

import 'package:data_gov_gr/src/audit/catalog_audit.dart';
import 'package:data_gov_gr/src/audit/audit_report.dart';
import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/ckan_executor.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/core/metadata_cache.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/catalog/catalog_query.dart';
import 'package:data_gov_gr/src/services/catalog_service.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

Map<String, Object?> entry(
  String id, {
  String kind = 'dataset',
  List<Object?> resources = const [],
}) => {'id': id, 'type': kind, 'resources': resources};
ScriptedStep page(int total, List<Object?> entries) =>
    (_) async => ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'result': {'count': total, 'results': entries},
      }),
      200,
    );

({CatalogAudit audit, ScriptedAdapter adapter}) harness(
  List<ScriptedStep> steps,
) {
  final adapter = ScriptedAdapter(steps);
  final base = Uri.parse('https://selected.test/api/3/action/');
  final transport = HttpTransport(
    DataGovConfig(actionBaseUrl: base, retry: RetryPolicy(maxAttempts: 1)),
    adapter: adapter,
  );
  addTearDown(transport.close);
  return (
    audit: CatalogAudit(
      CatalogService(
        CkanExecutor(transport, base),
        MetadataCache(MetadataCachePolicy.defaults),
      ),
    ),
    adapter: adapter,
  );
}

void main() {
  test(
    'mixed pages retain every resource including unusable URLs and formats',
    () async {
      final h = harness([
        page(3, [
          entry(
            'a',
            resources: [
              {'id': 'r1', 'url': 'https://files.test/a.csv', 'format': 'CSV'},
              {'id': 'r2', 'url': 'http://bad host/a', 'format': 'XLSX'},
              {'id': 'r3', 'format': 'future'},
            ],
          ),
          entry(
            'b',
            kind: 'service',
            resources: [
              {'id': 'r4', 'url': 'ftp://files.test/a', 'format': 'CSV'},
            ],
          ),
        ]),
        page(3, [
          entry(
            'c',
            kind: 'future-kind',
            resources: [
              {
                'id': 'r5',
                'url': 'https://files.test/a.json',
                'format': 'JSON',
              },
            ],
          ),
        ]),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(pageSize: 2),
        pageDelay: Duration.zero,
      );
      final json = report.toJson();
      expect(report.complete, isTrue);
      expect(json['portal'], 'https://selected.test/api/3/action/');
      expect(json['countsByKind'], {
        'dataset': 1,
        'service': 1,
        'future-kind': 1,
      });
      expect(json['resourceCount'], 5);
      expect(json['resourceIds'], ['r1', 'r2', 'r3', 'r4', 'r5']);
      final resources = (json['observations'] as List)
          .expand((e) => (e as Map)['resources'] as List)
          .cast<Map>()
          .toList();
      expect(resources.map((r) => r['urlStatus']), [
        'usableFileUrl',
        'unusableFileUrl',
        'missingUrl',
        'unusableFileUrl',
        'usableFileUrl',
      ]);
      expect(resources[1]['format'], 'XLSX');
      expect(resources[1]['formatStatus'], 'unsupportedParser');
      expect(json['sourceChecks'], {
        'performed': false,
        'parsedResourceCount': 0,
        'downloadedResourceCount': 0,
      });
      expect(h.adapter.requests.map((r) => r.uri.queryParameters['start']), [
        '0',
        '2',
      ]);
    },
  );

  test(
    'stable completed scan counts observed IDs rather than a declared constant',
    () async {
      final h = harness([
        page(1203, List.generate(1000, (i) => entry('e$i'))),
        page(1203, List.generate(203, (i) => entry('e${i + 1000}'))),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(pageSize: 1000),
        pageDelay: Duration.zero,
      );
      expect(report.complete, isTrue);
      expect(report.toJson()['uniqueEntryCount'], 1203);
      expect(report.toJson()['pageTotals'], [1203, 1203]);
    },
  );

  test('changed totals preserve each observation and are incomplete', () async {
    final h = harness([
      page(2, [entry('a')]),
      page(3, [entry('b')]),
      page(3, [entry('c')]),
    ]);
    final report = await h.audit.run(
      query: CatalogQuery(pageSize: 1),
      pageDelay: Duration.zero,
    );
    expect(report.complete, isFalse);
    expect(report.toJson()['pageTotals'], [2, 3, 3]);
    expect(report.toJson()['totalChanged'], isTrue);
    expect(report.toJson()['uniqueEntryCount'], 3);
  });

  test(
    'duplicate IDs preserve conflicting resources and cannot prove completeness',
    () async {
      final h = harness([
        page(3, [
          entry(
            'a',
            resources: [
              {'id': 'old'},
            ],
          ),
          entry('b'),
        ]),
        page(3, [
          entry(
            'a',
            kind: 'service',
            resources: [
              {'id': 'new'},
            ],
          ),
        ]),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(pageSize: 2),
        pageDelay: Duration.zero,
      );
      expect(report.complete, isFalse);
      expect(report.toJson()['duplicateEntryIds'], ['a']);
      expect(report.toJson()['observedEntryCount'], 3);
      expect(report.toJson()['uniqueEntryCount'], 2);
      expect(report.toJson()['resourceIds'], ['old', 'new']);
      expect((report.toJson()['observations'] as List).length, 3);
    },
  );

  test(
    'page failure retains earlier entries and sanitized error details',
    () async {
      final h = harness([
        page(2, [entry('a')]),
        (_) async => ResponseBody.fromString(
          '{"success":false,"error":{"message":"failure","token":"private"}}',
          200,
        ),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(pageSize: 1),
        pageDelay: Duration.zero,
      );
      expect(report.complete, isFalse);
      expect(report.toJson()['uniqueEntryCount'], 1);
      expect(report.toJson()['pageErrors'], isNotEmpty);
      expect((report.toJson()['pageErrors'] as List).single['offset'], 1);
      expect(jsonEncode(report.toJson()), isNot(contains('private')));
    },
  );

  test('failed page strips signed URLs throughout nested diagnostics', () async {
    const signedUrl =
        'https://private-user:private-password@files.test/data?sig=private-signature&custom_auth=private-key#private-fragment';
    final h = harness([
      page(2, [entry('a')]),
      (_) async => ResponseBody.fromString(
        jsonEncode({
          'success': false,
          'error': {
            'message': 'Publisher could not fetch $signedUrl while refreshing',
            'diagnostics': [
              {'source': signedUrl, 'attempt': 3},
              {
                'nested': {
                  'context': 'See $signedUrl for source details',
                  signedUrl: 'failed',
                },
              },
            ],
            'code': 'publisher_unavailable',
          },
        }),
        200,
      ),
    ]);
    final report = await h.audit.run(
      query: CatalogQuery(pageSize: 1),
      pageDelay: Duration.zero,
    );
    final json = report.toJson();
    final encoded = jsonEncode(json);
    for (final secret in [
      'private-user',
      'private-password',
      'private-signature',
      'private-key',
      'private-fragment',
    ]) {
      expect(encoded, isNot(contains(secret)), reason: secret);
    }
    expect(report.complete, isFalse);
    expect(json['uniqueEntryCount'], 1);
    final error = (json['pageErrors'] as List).single as Map;
    expect(error['offset'], 1);
    expect(error['action'], 'package_search');
    expect(error['statusCode'], 200);
    expect(error['type'], 'CkanActionException');
    final details = error['details'] as Map;
    expect(
      details['message'],
      'Publisher could not fetch https://files.test/data while refreshing',
    );
    expect(details['code'], 'publisher_unavailable');
    final diagnostics = details['diagnostics'] as List;
    expect(diagnostics.first, {
      'source': 'https://files.test/data',
      'attempt': 3,
    });
    expect(diagnostics.last['nested'], {
      'context': 'See https://files.test/data for source details',
      'https://files.test/data': 'failed',
    });
  });

  test(
    'apostrophes in signed queries are stripped from nested error evidence',
    () {
      const signedUrl =
          "https://files.test/data?sig=prefix'private-signature&custom_auth=private-key#private-fragment";
      final error = CkanActionException(
        'Fetch $signedUrl failed',
        action: 'package_search',
        statusCode: 200,
        details: {
          'diagnostics': [
            {'source': signedUrl, 'attempt': 3},
            {
              'nested': {signedUrl: 'publisher_unavailable'},
            },
          ],
        },
      );
      final report = AuditReport({
        'complete': false,
        'pageErrors': [
          {
            'message': error.toString(),
            'action': error.action,
            'statusCode': error.statusCode,
            'details': error.details,
          },
        ],
      });
      final encoded = jsonEncode(report.toJson());
      for (final secret in [
        'private-signature',
        'private-key',
        'private-fragment',
      ]) {
        expect(encoded, isNot(contains(secret)), reason: secret);
      }
      final observed = (report.toJson()['pageErrors'] as List).single as Map;
      expect(
        observed['message'],
        'CkanActionException: Fetch https://files.test/data failed',
      );
      expect(observed['action'], 'package_search');
      expect(observed['statusCode'], 200);
      final diagnostics = observed['details']['diagnostics'] as List;
      expect(diagnostics.first, {
        'source': 'https://files.test/data',
        'attempt': 3,
      });
      expect(diagnostics.last['nested'], {
        'https://files.test/data': 'publisher_unavailable',
      });
    },
  );

  test('quoted and parenthesized signed URLs preserve surrounding context', () {
    const signedUrl =
        "https://files.test/data?sig=prefix'private-signature!\$&()+,;=:@&custom_auth=private-key#private-fragment";
    final cases = <(String, String)>[
      ('Fetch $signedUrl failed', 'Fetch https://files.test/data failed'),
      (
        "Fetch '$signedUrl', retry later",
        "Fetch 'https://files.test/data', retry later",
      ),
      (
        'Fetch "$signedUrl", retry later',
        'Fetch "https://files.test/data", retry later',
      ),
      (
        'Fetch <$signedUrl>, retry later',
        'Fetch <https://files.test/data>, retry later',
      ),
      (
        'Fetch ($signedUrl), retry later',
        'Fetch (https://files.test/data), retry later',
      ),
      (
        "Fetch ('$signedUrl'), retry later",
        "Fetch ('https://files.test/data'), retry later",
      ),
    ];
    for (final (message, expected) in cases) {
      final error = CkanActionException(
        message,
        details: {
          'nested': [message],
        },
      );
      final report = AuditReport({
        'complete': false,
        'pageErrors': [
          {'message': error.toString(), 'details': error.details},
        ],
      });
      final encoded = jsonEncode(report.toJson());
      for (final secret in [
        'private-signature',
        'private-key',
        'private-fragment',
      ]) {
        expect(encoded, isNot(contains(secret)), reason: message);
      }
      final observed = (report.toJson()['pageErrors'] as List).single as Map;
      expect(observed['message'], 'CkanActionException: $expected');
      expect(observed['details']['nested'], [expected]);
    }
    final harmless = AuditReport({
      'message': "Fetch 'https://files.test/it's.csv' failed",
    });
    expect(
      harmless.toJson()['message'],
      "Fetch 'https://files.test/it's.csv' failed",
    );
  });

  test('page error message strips arbitrary signed URL credentials', () async {
    const signedUrl =
        'https://files.test/data?sig=private-signature&custom_auth=private-key#private-fragment';
    final h = harness([]);
    final cancellation = CancellationController()
      ..cancel('Stopped while reading $signedUrl before retry');
    final report = await h.audit.run(
      query: CatalogQuery(),
      cancellation: cancellation.signal,
    );
    final encoded = jsonEncode(report.toJson());
    for (final secret in [
      'private-signature',
      'private-key',
      'private-fragment',
    ]) {
      expect(encoded, isNot(contains(secret)), reason: secret);
    }
    expect(
      (report.toJson()['pageErrors'] as List).single['message'],
      contains('Stopped while reading https://files.test/data before retry'),
    );
    expect(report.complete, isFalse);
  });

  test(
    'entry cap shrinks the requested page and is always incomplete',
    () async {
      final h = harness([
        page(10, [entry('a'), entry('b')]),
        page(10, [entry('c')]),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(pageSize: 2),
        maxEntries: 3,
        pageDelay: Duration.zero,
      );
      expect(report.complete, isFalse);
      expect(report.toJson()['stopReason'], 'entryCap');
      expect(report.toJson()['uniqueEntryCount'], 3);
      expect(h.adapter.requests.map((r) => r.uri.queryParameters['rows']), [
        '2',
        '1',
      ]);
    },
  );

  test(
    'premature empty page and nonzero starting offset are incomplete',
    () async {
      final h = harness([
        page(3, [entry('a')]),
        page(3, []),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(pageSize: 1),
        pageDelay: Duration.zero,
      );
      expect(report.complete, isFalse);
      expect(report.toJson()['stopReason'], 'emptyPageBeforeTotal');
      final suffix = harness([
        page(3, [entry('c')]),
      ]);
      expect(
        (await suffix.audit.run(
          query: CatalogQuery(offset: 2),
          pageDelay: Duration.zero,
        )).complete,
        isFalse,
      );
    },
  );

  test('missing IDs and oversized pages cannot prove completeness', () async {
    final h = harness([
      page(2, [entry(''), entry('b')]),
    ]);
    final report = await h.audit.run(
      query: CatalogQuery(pageSize: 1),
      pageDelay: Duration.zero,
    );
    expect(report.complete, isFalse);
    expect(report.toJson()['missingEntryIdCount'], 1);
    expect(report.toJson()['resourceCount'], 0);
  });

  test(
    'cancellation produces an incomplete report without requesting a page',
    () async {
      final h = harness([]);
      final cancellation = CancellationController()..cancel('user stopped');
      final report = await h.audit.run(
        query: CatalogQuery(),
        cancellation: cancellation.signal,
      );
      expect(report.complete, isFalse);
      expect(report.toJson()['stopReason'], 'cancelled');
      expect(h.adapter.requests, isEmpty);
    },
  );

  test('resource credential URLs are redacted in serialized reports', () async {
    final h = harness([
      page(1, [
        entry(
          'a',
          resources: [
            {
              'id': 'r',
              'url': 'https://user:private@files.test/data?token=private',
              'format': 'CSV',
            },
          ],
        ),
      ]),
    ]);
    final report = await h.audit.run(
      query: CatalogQuery(),
      pageDelay: Duration.zero,
    );
    expect(jsonEncode(report.toJson()), isNot(contains('private')));
    expect(
      (report.toJson()['observations'] as List)
          .single['resources']
          .single['urlStatus'],
      'unusableFileUrl',
    );
  });

  test('signed file URLs never serialize bearer query credentials', () async {
    final h = harness([
      page(1, [
        entry(
          'a',
          resources: [
            {
              'id': 'r',
              'url':
                  'https://files.test/data?sig=private-signature&custom_auth=private-key',
              'format': 'CSV',
            },
          ],
        ),
      ]),
    ]);
    final report = await h.audit.run(
      query: CatalogQuery(),
      pageDelay: Duration.zero,
    );
    expect(jsonEncode(report.toJson()), isNot(contains('private-signature')));
    expect(jsonEncode(report.toJson()), isNot(contains('private-key')));
    expect(
      (report.toJson()['observations'] as List)
          .single['resources']
          .single['urlStatus'],
      'usableFileUrl',
    );
  });

  test('repeated pages stop rather than looping indefinitely', () async {
    final h = harness([
      page(5, [entry('a')]),
      page(5, [entry('a')]),
    ]);
    final report = await h.audit.run(
      query: CatalogQuery(pageSize: 1),
      pageDelay: Duration.zero,
    );
    expect(report.complete, isFalse);
    expect(report.toJson()['stopReason'], 'noUniqueProgress');
    expect(report.toJson()['observedEntryCount'], 2);
    expect(h.adapter.requests.length, 2);
  });

  test(
    'parser support status recognizes published MIME format labels',
    () async {
      final h = harness([
        page(1, [
          entry(
            'a',
            resources: [
              {'id': 'csv', 'format': 'text/csv'},
              {'id': 'json', 'format': 'application/json'},
              {'id': 'geo', 'format': 'application/geo+json'},
            ],
          ),
        ]),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(),
        pageDelay: Duration.zero,
      );
      expect(report.toJson()['resourceFormatStatuses'], {'supportedParser': 3});
    },
  );

  test('a stable empty source completes without inventing entries', () async {
    final h = harness([page(0, [])]);
    final report = await h.audit.run(
      query: CatalogQuery(),
      pageDelay: Duration.zero,
    );
    expect(report.complete, isTrue);
    expect(report.toJson()['uniqueEntryCount'], 0);
  });

  test(
    'an explicit cap is incomplete even when it equals the reported total',
    () async {
      final h = harness([
        page(1, [entry('a')]),
      ]);
      final report = await h.audit.run(
        query: CatalogQuery(),
        maxEntries: 1,
        pageDelay: Duration.zero,
      );
      expect(report.complete, isFalse);
      expect(report.toJson()['stopReason'], 'entryCap');
    },
  );

  test('invalid audit bounds fail before network access', () async {
    final h = harness([]);
    await expectLater(
      h.audit.run(query: CatalogQuery(), maxEntries: 0),
      throwsArgumentError,
    );
    await expectLater(
      h.audit.run(
        query: CatalogQuery(),
        pageDelay: const Duration(milliseconds: -1),
      ),
      throwsArgumentError,
    );
    expect(h.adapter.requests, isEmpty);
  });
}
