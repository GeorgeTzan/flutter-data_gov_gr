import 'dart:io';

import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:test/test.dart';

const _trafficResourceId = '14560622-570b-479a-a05f-659afc3d92d8';
const _fireResourceId = '3676d1d4-14e4-4758-a5c1-ac6279afe7d3';

void main() {
  final enabled = Platform.environment['DATA_GOV_GR_LIVE'] == '1';
  final Object skip = enabled
      ? false
      : 'Set DATA_GOV_GR_LIVE=1 to contact the real portal.';
  late DataGovClient client;
  setUp(() {
    client = DataGovClient();
  });
  tearDown(() => client.close());

  group('Anonymous selected-portal live checks', () {
    test('search returns published catalog entries', () async {
      final page = await client.catalog.search(CatalogQuery(pageSize: 2));
      expect(page.total, greaterThan(0));
      expect(page.entries, isNotEmpty);
      expect(page.entries.length, lessThanOrEqualTo(2));
      for (final entry in page.entries) {
        expect(entry.id, isNotEmpty);
        expect(entry.name, isNotEmpty);
        expect(entry.kind, isNotEmpty);
      }
    }, skip: skip);

    test(
      'traffic entry and resource metadata identify the selected source',
      () async {
        final entry = await client.catalog.getEntry('internet_traffic');
        expect(entry.name, 'internet_traffic');
        expect(entry.kind, 'dataset');
        expect(
          entry.resources.map((resource) => resource.id),
          contains(_trafficResourceId),
        );
        final resource = await client.catalog.getResource(_trafficResourceId);
        expect(resource.id, _trafficResourceId);
        expect(resource.raw['package_id'], entry.id);
        expect(resource.format?.toUpperCase(), 'CSV');
        expect(resource.datastoreActive, isTrue);
        expect(resource.fileUri, isNotNull);
      },
      skip: skip,
    );

    test(
      'one bounded traffic DataStore page contains source metrics',
      () async {
        final page = await client.datastore.search(
          _trafficResourceId,
          DataStoreQuery(limit: 2),
        );
        expect(page.records, isNotEmpty);
        expect(page.records.length, lessThanOrEqualTo(2));
        expect(page.raw['resource_id'], _trafficResourceId);
        expect(
          page.fields.map((field) => field['id']),
          containsAll(['date', 'avg_in', 'avg_out', 'max_in', 'max_out']),
        );
        for (final row in page.records) {
          expect(row['_id'], isNotNull);
          expect(DateTime.tryParse(row['date']! as String), isNotNull);
          for (final field in ['avg_in', 'avg_out', 'max_in', 'max_out']) {
            expect(
              num.tryParse(row[field].toString()),
              isNotNull,
              reason: field,
            );
          }
        }
      },
      skip: skip,
    );

    test(
      'forest-fire CSV cancels after one source row with byte and time bounds',
      () async {
        final entry = await client.catalog.getEntry('mcp_forest_fires');
        expect(entry.name, 'mcp_forest_fires');
        final resource = entry.resources.singleWhere(
          (resource) => resource.id == _fireResourceId,
        );
        final cancellation = CancellationController();
        try {
          final rows = await client.resources
              .csvRows(
                resource,
                options: CsvOptions(
                  download: DownloadOptions(
                    maxBytes: 1024 * 1024,
                    deadline: const Duration(seconds: 30),
                  ),
                ),
                cancellation: cancellation.signal,
              )
              .take(1)
              .toList();
          expect(rows, hasLength(1));
          expect(
            rows.single.keys,
            containsAll([
              'start_time',
              'end_time',
              'fire_station',
              'prefecture',
              'forest_area_burned',
              'firefighters',
            ]),
          );
          expect(DateTime.tryParse(rows.single['start_time']!), isNotNull);
          expect(rows.single['fire_station'], isNotEmpty);
          expect(rows.single['prefecture'], isNotEmpty);
        } finally {
          cancellation.cancel('Bounded live CSV sample finished.');
        }
        expect(cancellation.signal.isCancelled, isTrue);
      },
      skip: skip,
    );

    test('published data themes expose source vocabulary codes', () async {
      final themes = await client.catalog.themes();
      expect(themes, isNotEmpty);
      expect(themes.map((theme) => theme.code), containsAll(['AGRI', 'TECH']));
      expect(themes.every((theme) => theme.raw.containsKey('name')), isTrue);
    }, skip: skip);

    test(
      'one bounded organization page retains full publisher metadata',
      () async {
        final page = await client.catalog.organizations(
          OrganizationQuery(pageSize: 2),
        );
        expect(page.organizations, isNotEmpty);
        expect(page.organizations.length, lessThanOrEqualTo(2));
        for (final organization in page.organizations) {
          expect(organization.id, isNotEmpty);
          expect(organization.name, isNotEmpty);
          expect(organization.raw['type'], 'organization');
          expect(organization.raw['is_organization'], isTrue);
        }
      },
      skip: skip,
    );
  }, tags: ['live']);
}
