import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  test(
    'anonymous reads select the configured source and default timeout',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => ResponseBody.fromString(
          '{"success":true,"result":{"count":0,"results":[]}}',
          200,
        ),
      ]);
      final client = DataGovClient(
        config: DataGovConfig(
          actionBaseUrl: Uri.parse('https://selected.test/actions/'),
        ),
        adapter: adapter,
      );
      addTearDown(client.close);
      expect((await client.catalog.search(CatalogQuery())).total, 0);
      final request = adapter.requests.single;
      expect(request.uri.host, 'selected.test');
      expect(request.uri.path, '/actions/package_search');
      expect(request.connectTimeout, const Duration(seconds: 30));
      expect(request.receiveTimeout, const Duration(seconds: 30));
      expect(
        request.headers.keys.map((key) => key.toLowerCase()),
        isNot(contains('authorization')),
      );
    },
  );

  test(
    'disabling metadata retention reaches the source on every read',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => ResponseBody.fromString(
          '{"success":true,"result":{"id":"entry","title":"old"}}',
          200,
        ),
        (request) async => ResponseBody.fromString(
          '{"success":true,"result":{"id":"entry","title":"new"}}',
          200,
        ),
      ]);
      final client = DataGovClient(
        config: DataGovConfig(
          metadataCache: MetadataCachePolicy(ttl: Duration.zero),
        ),
        adapter: adapter,
      );
      addTearDown(client.close);
      expect((await client.catalog.getEntry('entry')).title, 'old');
      expect((await client.catalog.getEntry('entry')).title, 'new');
      expect(adapter.requests, hasLength(2));
    },
  );

  test(
    'resource byte ceilings remain active through the public client',
    () async {
      final adapter = ScriptedAdapter([
        (request) async => ResponseBody.fromString('too large', 200),
      ]);
      final client = DataGovClient(
        config: DataGovConfig(retry: RetryPolicy(maxAttempts: 1)),
        adapter: adapter,
      );
      addTearDown(client.close);
      await expectLater(
        client.resources.download(
          ResourceMetadata.fromJson({
            'id': 'file',
            'url': 'https://files.test/file.csv',
          }),
          options: DownloadOptions(maxBytes: 3),
        ),
        throwsA(isA<ByteLimitException>()),
      );
    },
  );
}
