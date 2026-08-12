import 'dart:async';

import 'package:data_gov_gr/src/core/raw_json.dart';
import 'package:data_gov_gr/src/models/catalog/catalog_entry.dart';
import 'package:data_gov_gr/src/models/catalog/catalog_page.dart';
import 'package:data_gov_gr/src/models/catalog/organization.dart';
import 'package:data_gov_gr/src/models/catalog/resource_metadata.dart';
import 'package:data_gov_gr/src/models/catalog/theme.dart';
import 'package:data_gov_gr/src/models/datastore/datastore_page.dart';
import 'package:data_gov_gr/src/models/resources/resource_download.dart';
import 'package:data_gov_gr/src/models/shared/source_date.dart';
import 'package:data_gov_gr/src/models/shared/source_provenance.dart';
import 'package:test/test.dart';

void main() {
  test('retains_all_entry_types_and_unknown_metadata', () {
    for (final kind in ['dataset', 'data-service', 'decision', 'future-kind']) {
      final entry = CatalogEntry.fromJson({
        'id': 'entry-id',
        'name': 'entry-name',
        'type': kind,
        'title_translated': {'el': 'Τίτλος', 'en': 'Title'},
        'notes_translated': {'el': 'Περιγραφή'},
        'publisher': {
          'future': [1, null],
        },
        'tags': [
          {'name': 'tag'},
        ],
        'theme': ['ENVI'],
        'endpoint_url': ['https://example.org/service'],
        'future': {'nested': true},
        'resources': [
          {'id': 'a', 'url': 'dummy-value', 'format': 'future-format'},
          {'id': 'b', 'url': 'https://example.org/file.pdf'},
        ],
      });
      expect(entry.id, 'entry-id');
      expect(entry.name, 'entry-name');
      expect(entry.kind, kind);
      expect(entry.title, isNull);
      expect(entry.description, isNull);
      expect(entry.titleTranslated['el'], 'Τίτλος');
      expect(entry.descriptionTranslated['el'], 'Περιγραφή');
      expect(entry.resources.map((r) => r.id), ['a', 'b']);
      expect(entry.resources.first.format, 'future-format');
      expect(entry.resources.first.name, isNull);
      expect(entry.resources.first.datastoreActive, isNull);
      expect(entry.metadataModified, isNull);
      expect(entry.serviceEndpoints, ['https://example.org/service']);
      expect(entry.themes, ['ENVI']);
      expect(entry.publisher, {
        'future': [1, null],
      });
      expect(entry.raw['future'], {'nested': true});
      expect(() => entry.resources.clear(), throwsUnsupportedError);
    }
  });

  test('preserves_invalid_resource_url', () {
    for (final url in [
      'dummy-value',
      '/relative.csv',
      'ftp://example.org/a',
      'https://',
      'https://exa mple.org/a',
    ]) {
      final resource = ResourceMetadata.fromJson({
        'id': 'r',
        'url': url,
        'download_url': 'https://example.org/catalog/entry',
      });
      expect(resource.url, url);
      expect(resource.raw['url'], url);
      expect(resource.fileUri, isNull);
    }
    final file = ResourceMetadata.fromJson({
      'id': 'r',
      'url': 'https://example.org/document.pdf',
      'download_url': 'https://example.org/catalog/entry',
      'datastore_active': false,
    });
    expect(file.fileUri, Uri.parse('https://example.org/document.pdf'));
    expect(file.downloadUrl, 'https://example.org/catalog/entry');
    expect(file.datastoreActive, isFalse);
    expect(
      ResourceMetadata.fromJson({
        'id': 's',
        'url': 'https://example.org/api',
        'resource_type': 'api',
      }).fileUri,
      isNull,
    );
    expect(
      ResourceMetadata.fromJson({
        'id': 's',
        'download_url': 'https://example.org/catalog/entry',
      }).fileUri,
      isNull,
    );
    expect(
      ResourceMetadata.fromJson({
        'id': 's',
        'download_url': 'https://example.org/file.csv',
        'url_type': 'download',
      }).fileUri,
      Uri.parse('https://example.org/file.csv'),
    );
  });

  test(
    'rejects_encoded_host_whitespace_but_accepts_encoded_path_and_query',
    () {
      for (final encoded in ['%20', '%09', '%0a', '%0B', '%0C', '%0d']) {
        final url = 'https://exa${encoded}mple.org/a';
        final resource = ResourceMetadata.fromJson({'id': 'r', 'url': url});
        expect(resource.url, url);
        expect(resource.raw['url'], url);
        expect(resource.fileUri, isNull, reason: 'Host contains $encoded');
      }
      final url = 'https://example.org/a%20b.csv?label=a%20b&line=%0A';
      final resource = ResourceMetadata.fromJson({'id': 'r', 'url': url});
      expect(resource.fileUri, Uri.parse(url));
      expect(resource.raw['url'], url);
    },
  );

  test('keeps_naive_dates_without_utc_invention', () {
    for (final raw in ['2026-10-11', '2026-10-11T09:00:00']) {
      final date = SourceDate(raw);
      expect(date.raw, raw);
      expect(date.isParseable, isTrue);
      expect(date.utcValue, isNull);
    }
    expect(SourceDate('not-a-date').isParseable, isFalse);
    expect(SourceDate('not-a-date').utcValue, isNull);
    expect(
      SourceDate('2026-10-11T09:00:00+03:00').utcValue,
      DateTime.utc(2026, 10, 11, 6),
    );
    expect(
      SourceDate('2026-10-11T09:00:00Z').utcValue,
      DateTime.utc(2026, 10, 11, 9),
    );
  });

  test('deeply_copies_nested_source_json', () {
    final nested = <String, Object?>{
      'list': <Object?>[
        {'value': 1},
      ],
    };
    final source = <String, Object?>{'nested': nested};
    final frozen = freezeJson(source);
    (nested['list'] as List).clear();
    source.clear();
    expect(frozen, {
      'nested': {
        'list': [
          {'value': 1},
        ],
      },
    });
    final frozenNested = frozen['nested'] as JsonObject;
    final list = frozenNested['list'] as List<Object?>;
    expect(() => frozen.clear(), throwsUnsupportedError);
    expect(() => frozenNested.clear(), throwsUnsupportedError);
    expect(() => list.clear(), throwsUnsupportedError);
    expect(() => (list.single as JsonObject).clear(), throwsUnsupportedError);
  });

  test('page_records_and_facets_are_detached_and_immutable', () {
    final records = <JsonObject>[
      {
        'id': 1,
        'extra': [null, true],
      },
    ];
    final raw = <String, Object?>{'total_was_estimated': true};
    final page = DataStorePage(
      records: records,
      fields: [
        {'id': 'id', 'type': 'int'},
      ],
      offset: 4,
      requestedLimit: 100,
      effectiveLimit: 2,
      total: 10,
      totalEstimated: true,
      raw: raw,
    );
    records.first.clear();
    records.clear();
    raw.clear();
    expect(page.records, [
      {
        'id': 1,
        'extra': [null, true],
      },
    ]);
    expect(page.raw['total_was_estimated'], isTrue);
    expect(page.totalEstimated, isTrue);
    expect(() => page.records.first.clear(), throwsUnsupportedError);
    expect(() => page.fields.first.clear(), throwsUnsupportedError);
    final facets = <String, Object?>{
      'theme': {
        'items': [
          {'name': '["ENVI", "HEAL"]'},
        ],
      },
    };
    final catalog = CatalogPage(
      entries: [],
      offset: 0,
      requestedPageSize: 100,
      total: 0,
      rawFacets: facets,
    );
    facets.clear();
    expect(catalog.rawFacets['theme'], {
      'items': [
        {'name': '["ENVI", "HEAL"]'},
      ],
    });
  });

  test('provenance_round_trips_source_date_and_validates_row_position', () {
    final provenance = SourceProvenance(
      entryId: 'e',
      resourceId: 'r',
      sourceUrl: 'dummy-value',
      publishedModified: SourceDate('2026-10-11'),
      retrievedAt: DateTime.utc(2026, 10, 11, 7),
      sourceRow: 2,
    );
    final json = provenance.toJson();
    expect(json, {
      'entryId': 'e',
      'resourceId': 'r',
      'sourceUrl': 'dummy-value',
      'publishedModified': '2026-10-11',
      'retrievedAt': '2026-10-11T07:00:00.000Z',
      'sourceRow': 2,
    });
    final parsed = SourceProvenance.fromJson(json);
    expect(parsed.publishedModified!.utcValue, isNull);
    expect(parsed.retrievedAt, DateTime.utc(2026, 10, 11, 7));
    expect(parsed.sourceRow, 2);
    expect(
      () => SourceProvenance(
        resourceId: 'r',
        sourceUrl: 'x',
        retrievedAt: DateTime.utc(2026),
        sourceRow: 0,
      ),
      throwsArgumentError,
    );
  });

  test('organization_and_theme_preserve_unknown_and_missing_labels', () {
    final organization = Organization.fromJson({
      'id': 'o',
      'name': 'org',
      'future': [1],
    });
    expect(organization.title, isNull);
    expect(organization.raw['future'], [1]);
    expect(
      OrganizationPage(organizations: [organization], offset: 0).total,
      isNull,
    );
    final theme = Theme.fromJson({
      'name': 'ENVI',
      'label_el': '',
      'label_en': 'Environment',
      'uri': 'http://publications.europa.eu/resource/authority/data-theme/ENVI',
      'future': true,
    });
    expect(theme.code, 'ENVI');
    expect(theme.labelEl, isNull);
    expect(theme.labelEn, 'Environment');
    expect(
      theme.authorityUri,
      'http://publications.europa.eu/resource/authority/data-theme/ENVI',
    );
    expect(theme.raw['future'], isTrue);
  });

  test('resource_download_exposes_single_subscription_bytes', () async {
    final controller = StreamController<List<int>>.broadcast();
    final download = ResourceDownload(
      finalUrl: Uri.parse('https://example.org/a'),
      contentType: 'text/csv',
      contentLength: 2,
      provenance: SourceProvenance(
        resourceId: 'r',
        sourceUrl: 'https://example.org/a',
        retrievedAt: DateTime.utc(2026),
      ),
      bytes: controller.stream,
    );
    expect(download.bytes.isBroadcast, isFalse);
    final received = download.bytes.toList();
    await Future<void>.delayed(Duration.zero);
    controller.add([1, 2]);
    await controller.close();
    expect(await received, [
      [1, 2],
    ]);
    expect(() => download.bytes.listen((_) {}), throwsStateError);
  });
}
