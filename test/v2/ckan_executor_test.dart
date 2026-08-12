import 'dart:convert';
import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/ckan_executor.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  final base = Uri.parse('https://portal.test/api/3/action/');
  for (final result in [
    <String, Object?>{'id': 'real'},
    ['real', 1],
  ]) {
    test('retains result shape $result', () async {
      final adapter = ScriptedAdapter([
        (o) async => ResponseBody.fromString(
          jsonEncode({'success': true, 'result': result}),
          200,
        ),
      ]);
      final transport = HttpTransport(
        DataGovConfig(actionBaseUrl: base),
        adapter: adapter,
      );
      addTearDown(transport.close);
      expect(await CkanExecutor(transport, base).call('package_list'), result);
    });
  }
  test('unsuccessful envelope retains action and safe details', () async {
    final adapter = ScriptedAdapter([
      (o) async => ResponseBody.fromString(
        '{"success":false,"error":{"message":"bad","token":"secret"}}',
        200,
      ),
    ]);
    final transport = HttpTransport(
      DataGovConfig(actionBaseUrl: base),
      adapter: adapter,
    );
    addTearDown(transport.close);
    await expectLater(
      CkanExecutor(transport, base).call('package_search'),
      throwsA(
        isA<CkanActionException>()
            .having((e) => e.action, 'action', 'package_search')
            .having((e) => e.details, 'details', {
              'message': 'bad',
              'token': '[REDACTED]',
            }),
      ),
    );
  });
  test(
    'structured CKAN validation error retains action and safe details',
    () async {
      final transport = HttpTransport(
        DataGovConfig(actionBaseUrl: base),
        adapter: ScriptedAdapter([
          (o) async => ResponseBody.fromString(
            '{"success":false,"error":{"__type":"Validation Error","sort":["Unknown field _id"],"token":"secret"}}',
            200,
          ),
        ]),
      );
      addTearDown(transport.close);
      await expectLater(
        CkanExecutor(transport, base).call('datastore_search'),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.action, 'action', 'datastore_search')
              .having((e) => e.statusCode, 'statusCode', 200)
              .having((e) => e.details, 'details', {
                '__type': 'Validation Error',
                'sort': ['Unknown field _id'],
                'token': '[REDACTED]',
              }),
        ),
      );
    },
  );
  for (final body in [
    'oops',
    '[]',
    '{}',
    '{"success":true}',
    '{"success":"yes","result":1}',
  ]) {
    test('rejects invalid JSON or envelope $body', () async {
      final transport = HttpTransport(
        DataGovConfig(actionBaseUrl: base),
        adapter: ScriptedAdapter([
          (o) async => ResponseBody.fromString(body, 200),
        ]),
      );
      addTearDown(transport.close);
      await expectLater(
        CkanExecutor(transport, base).call('package_list'),
        throwsA(isA<DecodeException>()),
      );
    });
  }
  for (final post in [false, true]) {
    test('unicode_and_reserved_query_round_trip post=$post', () async {
      final adapter = ScriptedAdapter([
        (o) async =>
            ResponseBody.fromString('{"success":true,"result":null}', 200),
      ]);
      final transport = HttpTransport(
        DataGovConfig(actionBaseUrl: base),
        adapter: adapter,
      );
      addTearDown(transport.close);
      await CkanExecutor(transport, base).call(
        'package_search',
        parameters: {'q': 'Αθήνα & + "data"'},
        usePost: post,
      );
      final request = adapter.requests.single;
      expect(
        post
            ? jsonDecode(request.data as String)['q']
            : request.uri.queryParameters['q'],
        'Αθήνα & + "data"',
      );
    });
  }
}
