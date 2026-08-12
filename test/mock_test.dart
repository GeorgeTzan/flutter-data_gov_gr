import 'dart:convert';
import 'dart:io';

import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:test/test.dart';

void main() {
  late DataGovClient client;
  setUp(() => client = createFixtureClient());
  tearDown(() => client.close());

  test(
    'fixture metadata agrees with the checked-in synthetic envelope',
    () async {
      final envelope =
          jsonDecode(
                await File(
                  'test/fixtures/v2/catalog/traffic.json',
                ).readAsString(),
              )
              as Map<String, dynamic>;
      expect(envelope['success'], isTrue);
      expect(
        (await client.catalog.getEntry('synthetic-traffic')).raw,
        envelope['result'],
      );
    },
  );

  test(
    'fixtures select explicitly synthetic catalog and resource metadata',
    () async {
      final page = await client.catalog.search(CatalogQuery());
      expect(page.entries.single.id, 'synthetic-traffic');
      final entry = await client.catalog.getEntry('synthetic-traffic');
      expect(entry.title, 'Synthetic traffic fixture — not provider data');
      expect(entry.resources.map((resource) => resource.id), [
        'synthetic-traffic-csv',
        'synthetic-traffic-json',
        'synthetic-traffic-file',
      ]);
      expect(
        (await client.catalog.getResource('synthetic-traffic-csv')).id,
        'synthetic-traffic-csv',
      );
    },
  );

  test(
    'fixture DataStore traversal returns deterministic source pages',
    () async {
      final pages = await client.datastore
          .pages('synthetic-traffic-csv', DataStoreQuery(limit: 1))
          .toList();
      expect(pages.map((page) => page.records.single['code']), [
        '00123',
        '00456',
      ]);
      expect(pages.map((page) => page.offset), [0, 1]);
      expect(pages.every((page) => page.total == 2), isTrue);
    },
  );

  test('fixtures read CSV cells, JSON rows and binary downloads', () async {
    final entry = await client.catalog.getEntry('synthetic-traffic');
    final csv = await client.resources.csvRows(entry.resources[0]).toList();
    expect(csv, [
      {'code': '00123', 'value': '10'},
      {'code': '00456', 'value': '20'},
    ]);
    final json = await client.resources.readJson(entry.resources[1]);
    expect(client.resources.jsonObjectRows(json), [
      {'code': '00123', 'value': 10},
      {'code': '00456', 'value': 20},
    ]);
    final file = await client.resources.download(entry.resources[2]);
    expect(await file.bytes.expand((chunk) => chunk).toList(), [0, 1, 2, 255]);
    expect(file.provenance.entryId, 'synthetic-traffic');
  });

  test('an exhausted fixture route is an explicit error', () async {
    final resource = await client.catalog.getResource('synthetic-traffic-file');
    await (await client.resources.download(resource)).bytes.drain<void>();
    await expectLater(
      client.resources.download(resource),
      throwsA(
        isA<NetworkException>().having(
          (error) => error.originalError.toString(),
          'cause',
          contains('Fixture route exhausted'),
        ),
      ),
    );
  });

  test('unknown fixture routes never fabricate catalog or file data', () async {
    await expectLater(
      client.catalog.getEntry('real-provider-id'),
      throwsA(
        isA<NetworkException>().having(
          (error) => error.originalError.toString(),
          'cause',
          contains('No fixture route'),
        ),
      ),
    );
  });

  test('separate fixture clients have independent route lifetimes', () async {
    final other = createFixtureClient();
    addTearDown(other.close);
    expect((await client.catalog.search(CatalogQuery())).total, 1);
    expect((await other.catalog.search(CatalogQuery())).total, 1);
  });
}
