import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/catalog/resource_metadata.dart';
import 'package:data_gov_gr/src/models/resources/json_options.dart';
import 'package:data_gov_gr/src/parsers/json_reader.dart';
import 'package:data_gov_gr/src/services/resource_service.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

ResourceService _service(ScriptedAdapter adapter) {
  final transport = HttpTransport(DataGovConfig(), adapter: adapter);
  addTearDown(transport.close);
  return ResourceService(transport);
}

final _resource = ResourceMetadata.fromJson({
  'id': 'json-source',
  'url': 'https://files.test/source.json',
  'format': 'JSON',
});

void main() {
  const reader = JsonReader();
  final documents = <String, Object?>{
    'null': null,
    'true': true,
    '42': 42,
    '1.25': 1.25,
    '"Αθήνα"': 'Αθήνα',
    '{"id":"00123","missing":null}': {'id': '00123', 'missing': null},
    '[1,"x",false,null]': [1, 'x', false, null],
  };
  for (final entry in documents.entries) {
    test('retains JSON root shape ${entry.key}', () async {
      expect(
        await reader.read(
          Stream.value(utf8.encode(entry.key)),
          JsonOptions.defaults,
        ),
        entry.value,
      );
    });
  }
  test('recursively freezes maps and lists', () async {
    final document =
        await reader.read(
              Stream.value(utf8.encode('{"nested":[{"id":1}]}')),
              JsonOptions.defaults,
            )
            as Map;
    expect(() => document['x'] = 1, throwsUnsupportedError);
    expect(() => (document['nested'] as List).add(1), throwsUnsupportedError);
    expect(
      () => ((document['nested'] as List).single as Map)['id'] = 2,
      throwsUnsupportedError,
    );
  });
  test('strict decoding survives UTF-8 chunk splits', () async {
    final bytes = utf8.encode('"Αθήνα"');
    expect(
      await reader.read(
        Stream.fromIterable(bytes.map((byte) => [byte])),
        JsonOptions.defaults,
      ),
      'Αθήνα',
    );
  });
  for (final invalid in <List<int>>[
    utf8.encode('{broken'),
    [0x22, 0xff, 0x22],
  ]) {
    test('malformed JSON or UTF-8 is an SDK decode error $invalid', () async {
      await expectLater(
        reader.read(Stream.value(invalid), JsonOptions.defaults),
        throwsA(isA<DecodeException>()),
      );
    });
  }
  test(
    'internal JSON reader rejects a chunk before exceeding its byte ceiling',
    () async {
      await expectLater(
        reader.read(
          Stream.fromIterable([
            [91, 32],
            [32, 93],
          ]),
          JsonOptions(maxBytes: 3),
        ),
        throwsA(isA<ByteLimitException>()),
      );
    },
  );
  test(
    'default JSON ceiling works through service without Content-Length',
    () async {
      expect(JsonOptions.defaults.maxBytes, 8388608);
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(Stream.value(Uint8List(8388609)), 200),
      ]);
      await expectLater(
        _service(adapter).readJson(_resource),
        throwsA(isA<ByteLimitException>()),
      );
      expect(adapter.requests, hasLength(1));
    },
  );
  test('JSON caller can increase or disable the decoded ceiling', () async {
    final bytes = utf8.encode('"${'x' * 8388607}"');
    for (final maxBytes in [8388609, null]) {
      final adapter = ScriptedAdapter([
        (options) async =>
            ResponseBody(Stream.value(Uint8List.fromList(bytes)), 200),
      ]);
      final document = await _service(
        adapter,
      ).readJson(_resource, options: JsonOptions(maxBytes: maxBytes));
      expect((document as String).length, 8388607);
    }
  });
  test('JSON service retains arbitrary root shape', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody.fromString('[1,"x"]', 200),
    ]);
    expect(await _service(adapter).readJson(_resource), [1, 'x']);
  });
  test('array-of-objects selection copies and freezes rows', () {
    final service = _service(ScriptedAdapter([]));
    final document = [
      {
        'id': '00123',
        'nested': [1],
      },
    ];
    final rows = service.jsonObjectRows(document);
    expect(rows, document);
    expect(() => rows.add({}), throwsUnsupportedError);
    expect(() => rows.single['id'] = 'x', throwsUnsupportedError);
    document.single['id'] = 'changed';
    expect(rows.single['id'], '00123');
    expect(service.jsonObjectRows([]), isEmpty);
  });
  test('GeoJSON needs explicit features selection', () async {
    final document = await reader.read(
      File('test/fixtures/v2/resources/geojson.json').openRead(),
      JsonOptions.defaults,
    );
    final service = _service(ScriptedAdapter([]));
    expect(
      () => service.jsonObjectRows(document),
      throwsA(isA<DecodeException>()),
    );
    final rows = service.jsonObjectRows(
      document,
      select: (value) => (value as Map)['features'],
    );
    expect(rows.single['type'], 'Feature');
    expect((rows.single['properties'] as Map)['id'], '00123');
  });
  test('nested non-string object keys become SDK decode errors', () {
    final service = _service(ScriptedAdapter([]));
    expect(
      () => service.jsonObjectRows([
        {
          'nested': [
            {1: 'invalid JSON key'},
          ],
        },
      ]),
      throwsA(isA<DecodeException>()),
    );
  });
  test('caller selector errors retain their identity', () {
    final service = _service(ScriptedAdapter([]));
    final error = ArgumentError('caller selector');
    expect(
      () => service.jsonObjectRows([], select: (_) => throw error),
      throwsA(same(error)),
    );
  });
  for (final invalid in <Object?>[
    null,
    1,
    {},
    [1],
    [
      {'ok': true},
      null,
    ],
    [
      {1: 'bad key'},
    ],
  ]) {
    test('invalid selected object rows fail $invalid', () {
      final service = _service(ScriptedAdapter([]));
      expect(
        () => service.jsonObjectRows({
          'selected': invalid,
        }, select: (value) => (value as Map)['selected']),
        throwsA(isA<DecodeException>()),
      );
    });
  }
  test(
    'incompatible labeled JSON resource format rejects before a request',
    () async {
      final adapter = ScriptedAdapter([]);
      await expectLater(
        _service(adapter).readJson(
          ResourceMetadata.fromJson({
            'id': 'zip',
            'url': 'https://files.test/source.zip',
            'format': 'ZIP',
          }),
        ),
        throwsA(isA<UnsupportedFormatException>()),
      );
      expect(adapter.requests, isEmpty);
    },
  );
  test('JSON caller cancellation propagates as SDK cancellation', () async {
    final cancellation = CancellationController()..cancel();
    await expectLater(
      _service(
        ScriptedAdapter([]),
      ).readJson(_resource, cancellation: cancellation.signal),
      throwsA(isA<CancelledException>()),
    );
  });
  test('JSON deadline override aborts pending opening', () async {
    final adapter = ScriptedAdapter([
      (options) => Completer<ResponseBody>().future,
    ]);
    await expectLater(
      _service(adapter).readJson(
        _resource,
        options: JsonOptions(deadline: const Duration(milliseconds: 20)),
      ),
      throwsA(isA<RequestTimeoutException>()),
    );
    expect(adapter.requests, hasLength(1));
  });
}
