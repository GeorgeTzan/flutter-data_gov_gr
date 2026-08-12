import 'dart:async';
import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/resources/download_options.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  final base = Uri.parse('https://portal.test/api/3/action/');
  test('keys only accompany configured action endpoints', () async {
    final a = ScriptedAdapter(
      List.generate(
        4,
        (_) =>
            (RequestOptions o) async => ResponseBody.fromString('{}', 200),
      ),
    );
    final t = HttpTransport(
      DataGovConfig(actionBaseUrl: base, apiKey: 'secret'),
      adapter: a,
    );
    addTearDown(t.close);
    await t.requestJson(
      base.resolve('package_list'),
      sendPortalCredentials: true,
    );
    await t.requestJson(
      base.resolve('../file.csv'),
      sendPortalCredentials: true,
    );
    await t.requestJson(
      Uri.parse('https://else.test/api/3/action/package_list'),
      sendPortalCredentials: true,
    );
    final d = await t.openDownload(
      base.resolve('file.csv'),
      options: DownloadOptions.defaults,
    );
    await d.bytes.drain<void>();
    expect(a.requests.first.headers['Authorization'], 'secret');
    for (final r in a.requests.skip(1)) {
      expect(
        r.headers.keys.map((s) => s.toLowerCase()),
        isNot(contains('authorization')),
      );
    }
  });
  test('redirects never forward portal credentials', () async {
    final a = ScriptedAdapter([
      (o) async => ResponseBody.fromString(
        '',
        302,
        headers: {
          'location': ['https://else.test/file'],
        },
      ),
      (o) async => ResponseBody.fromString('{}', 200),
    ]);
    final t = HttpTransport(
      DataGovConfig(actionBaseUrl: base, apiKey: 'secret'),
      adapter: a,
    );
    addTearDown(t.close);
    await t.requestJson(
      base.resolve('package_list'),
      sendPortalCredentials: true,
    );
    expect(a.requests.first.followRedirects, isFalse);
    expect(a.requests.last.headers.containsKey('Authorization'), isFalse);
  });
  test('caller adapter remains available; owned injected closes once', () {
    final a = ScriptedAdapter([]);
    final t = HttpTransport(DataGovConfig(), adapter: a);
    t.close();
    t.close();
    expect(a.closeCount, 0);
    final b = ScriptedAdapter([]);
    final u = HttpTransport(
      DataGovConfig(disposeInjectedAdapter: true),
      adapter: b,
    );
    u.close();
    u.close();
    expect(b.closeCount, 1);
  });
  test('close cancels only own requests and rejects later work', () async {
    final never = Completer<ResponseBody>();
    final a = ScriptedAdapter([
      (o) => never.future,
      (o) async => ResponseBody.fromString('{}', 200),
    ]);
    final first = HttpTransport(DataGovConfig(), adapter: a);
    final second = HttpTransport(DataGovConfig(), adapter: a);
    addTearDown(second.close);
    final pending = first.requestJson(base.resolve('package_list'));
    final assertion = expectLater(
      pending,
      throwsA(isA<ClientClosedException>()),
    );
    while (a.requests.isEmpty) {
      await Future<void>.delayed(Duration.zero);
    }
    first.close();
    await assertion;
    expect(await second.requestJson(base.resolve('package_list')), isEmpty);
    await expectLater(
      first.requestJson(base),
      throwsA(isA<ClientClosedException>()),
    );
  });
}
