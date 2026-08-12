import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/catalog/resource_metadata.dart';
import 'package:data_gov_gr/src/models/resources/csv_options.dart';
import 'package:data_gov_gr/src/models/resources/download_options.dart';
import 'package:data_gov_gr/src/parsers/csv_reader.dart';
import 'package:data_gov_gr/src/services/resource_service.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

Stream<List<int>> _bytes(String text) => Stream.value(utf8.encode(text));

final _resource = ResourceMetadata.fromJson({
  'id': 'csv-source',
  'url': 'https://files.test/source.csv',
  'format': 'CSV',
});

ResourceService _service(ScriptedAdapter adapter) {
  final transport = HttpTransport(DataGovConfig(), adapter: adapter);
  addTearDown(transport.close);
  return ResourceService(transport);
}

void main() {
  const reader = CsvReader();
  test(
    'fixture preserves numeric strings, multiline quotes and empty cells',
    () async {
      final rows = await reader
          .rows(
            File('test/fixtures/v2/resources/quoted.csv').openRead(),
            CsvOptions.defaults,
          )
          .toList();
      expect(rows, [
        {
          'id': '00123',
          'note': 'line one\nline two',
          'city': 'Αθήνα, "Ελλάδα"',
          'empty': '',
        },
      ]);
      expect(() => rows.single['id'] = 'changed', throwsUnsupportedError);
    },
  );

  for (final eol in ['\n', '\r\n', '\r']) {
    test('handles BOM and ${eol.codeUnits} record terminators', () async {
      expect(
        await reader
            .rows(
              _bytes('\ufeffid,note${eol}00123,"x${eol}y"$eol'),
              CsvOptions.defaults,
            )
            .toList(),
        [
          {'id': '00123', 'note': 'x${eol}y'},
        ],
      );
    });
    test('header only with ${eol.codeUnits} yields no data rows', () async {
      expect(
        await reader.rows(_bytes('id,note$eol'), CsvOptions.defaults).toList(),
        isEmpty,
      );
    });
  }
  test('header without final newline yields no rows', () async {
    expect(
      await reader.rows(_bytes('id,note'), CsvOptions.defaults).toList(),
      isEmpty,
    );
  });
  test('first record terminator excludes quoted header newlines', () async {
    expect(
      await reader
          .rows(
            _bytes('"first\nname",id\r\nAlice,00123\r\n'),
            CsvOptions.defaults,
          )
          .toList(),
      [
        {'first\nname': 'Alice', 'id': '00123'},
      ],
    );
  });

  final invalid = <String, (String, int)>{
    'duplicate header': ('id,id\n1,2\n', 1),
    'empty header': ('id,\n1,2\n', 1),
    'whitespace header': ('id, \n1,2\n', 1),
    'extra cells': ('id,note\n1,2,3\n', 2),
    'short row': ('id,note\n1\n', 2),
    'unterminated quote': ('id,note\n1,"never closed', 2),
    'quote inside unquoted cell': ('id,note\n1,a"b\n', 2),
    'text after closing quote': ('id,note\n1,"a"b\n', 2),
  };
  for (final entry in invalid.entries) {
    test('rejects ${entry.key} with logical source row context', () async {
      await expectLater(
        reader.rows(_bytes(entry.value.$1), CsvOptions.defaults).toList(),
        throwsA(
          isA<DecodeException>().having(
            (error) => error.details,
            'row context',
            containsPair('sourceRow', entry.value.$2),
          ),
        ),
      );
    });
  }
  test('pads short rows only when explicitly enabled', () async {
    expect(
      await reader
          .rows(
            _bytes('id,note,empty\n00123\n'),
            CsvOptions(padShortRows: true),
          )
          .toList(),
      [
        {'id': '00123', 'note': '', 'empty': ''},
      ],
    );
  });
  test('explicit semicolon and latin1 preserve source strings', () async {
    expect(
      await reader
          .rows(
            Stream.value(latin1.encode('id;city\r\n00123;Montréal\r\n')),
            CsvOptions(delimiter: ';', encoding: latin1),
          )
          .toList(),
      [
        {'id': '00123', 'city': 'Montréal'},
      ],
    );
  });
  test('required headers validated even on a header-only file', () async {
    await expectLater(
      reader
          .rows(
            _bytes('id,note\n'),
            CsvOptions.defaults,
            requiredHeaders: ['missing'],
          )
          .toList(),
      throwsA(
        isA<DecodeException>().having(
          (error) => error.details,
          'row context',
          containsPair('sourceRow', 1),
        ),
      ),
    );
    expect(
      await reader
          .rows(_bytes('id,note'), CsvOptions.defaults, requiredHeaders: ['id'])
          .toList(),
      isEmpty,
    );
  });
  test('empty file cannot satisfy requested headers', () async {
    await expectLater(
      reader
          .rows(_bytes(''), CsvOptions.defaults, requiredHeaders: ['id'])
          .toList(),
      throwsA(isA<DecodeException>()),
    );
  });
  test('invalid UTF-8 is a decode error', () async {
    await expectLater(
      reader.rows(Stream.value([0xff]), CsvOptions.defaults).toList(),
      throwsA(isA<DecodeException>()),
    );
  });
  test('arbitrary_chunk_boundaries_preserve_csv', () async {
    final bytes = utf8.encode(
      '\ufeff"na\nme",id,note\r\nΑθήνα,00123,"one\r\ntwo ""quoted"""\r\n',
    );
    final expected = [
      {'na\nme': 'Αθήνα', 'id': '00123', 'note': 'one\r\ntwo "quoted"'},
    ];
    expect(
      await reader.rows(Stream.value(bytes), CsvOptions.defaults).toList(),
      expected,
    );
    for (var split = 1; split < bytes.length; split++) {
      expect(
        await reader
            .rows(
              Stream.fromIterable([
                bytes.sublist(0, split),
                bytes.sublist(split),
              ]),
              CsvOptions.defaults,
            )
            .toList(),
        expected,
        reason: 'byte split $split',
      );
    }
    expect(
      await reader
          .rows(
            Stream.fromIterable(bytes.map((byte) => [byte])),
            CsvOptions.defaults,
          )
          .toList(),
      expected,
    );
  });
  test(
    'reader transfer ceiling bounds an unterminated header prefix',
    () async {
      await expectLater(
        reader
            .rows(
              _bytes('"long quoted header without newline'),
              CsvOptions(download: DownloadOptions(maxBytes: 8)),
            )
            .toList(),
        throwsA(isA<ByteLimitException>()),
      );
    },
  );
  test('service composes download bounds and explicit CSV options', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody(
        Stream.value(
          Uint8List.fromList(latin1.encode('id;name\n00123;Montréal\n')),
        ),
        200,
      ),
    ]);
    expect(
      await _service(adapter)
          .csvRows(
            _resource,
            options: CsvOptions(delimiter: ';', encoding: latin1),
          )
          .toList(),
      [
        {'id': '00123', 'name': 'Montréal'},
      ],
    );
    expect(adapter.requests, hasLength(1));
  });
  test('cancelling after the first row stops network consumption', () async {
    var produced = 0;
    var cancelled = false;
    Stream<Uint8List> source() async* {
      try {
        produced++;
        yield Uint8List.fromList(utf8.encode('id\n00123\n'));
        produced++;
        yield Uint8List.fromList(utf8.encode('00456\n'));
      } finally {
        cancelled = true;
      }
    }

    final adapter = ScriptedAdapter([
      (options) async => ResponseBody(source(), 200),
    ]);
    expect(await _service(adapter).csvRows(_resource).first, {'id': '00123'});
    expect(produced, 1);
    expect(cancelled, isTrue);
  });
  test(
    'CSV subscription cancellation aborts opening before first byte',
    () async {
      final listening = Completer<void>();
      final cancelled = Completer<void>();
      final source = StreamController<Uint8List>(
        onListen: listening.complete,
        onCancel: cancelled.complete,
      );
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(source.stream, 200),
      ]);
      final subscription = _service(
        adapter,
      ).csvRows(_resource).listen((row) {});
      await listening.future;
      await subscription.cancel();
      await cancelled.future;
    },
  );
  test('CSV caller cancellation propagates as SDK cancellation', () async {
    final cancellation = CancellationController()..cancel();
    await expectLater(
      _service(
        ScriptedAdapter([]),
      ).csvRows(_resource, cancellation: cancellation.signal).toList(),
      throwsA(isA<CancelledException>()),
    );
  });
  test(
    'CSV cancellation aborts an active request awaiting response headers',
    () async {
      final requested = Completer<RequestOptions>();
      final adapter = ScriptedAdapter([
        (options) {
          requested.complete(options);
          return Completer<ResponseBody>().future;
        },
      ]);
      final subscription = _service(
        adapter,
      ).csvRows(_resource).listen((row) {});
      final request = await requested.future;
      await subscription.cancel();
      expect(request.cancelToken?.isCancelled, isTrue);
    },
  );
  test('CSV service enforces the caller transfer ceiling', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody.fromString('id\n00123\n', 200),
    ]);
    await expectLater(
      _service(adapter)
          .csvRows(
            _resource,
            options: CsvOptions(download: DownloadOptions(maxBytes: 3)),
          )
          .toList(),
      throwsA(isA<ByteLimitException>()),
    );
  });
  test('CSV service forwards the caller deadline', () async {
    final adapter = ScriptedAdapter([
      (options) => Completer<ResponseBody>().future,
    ]);
    await expectLater(
      _service(adapter)
          .csvRows(
            _resource,
            options: CsvOptions(
              download: DownloadOptions(
                deadline: const Duration(milliseconds: 20),
              ),
            ),
          )
          .toList(),
      throwsA(isA<RequestTimeoutException>()),
    );
  });
  test(
    'CSV parser rejects incompatible labeled formats before a request',
    () async {
      final adapter = ScriptedAdapter([]);
      final resource = ResourceMetadata.fromJson({
        'id': 'pdf',
        'url': 'https://files.test/source.pdf',
        'format': 'PDF',
      });
      await expectLater(
        _service(adapter).csvRows(resource).toList(),
        throwsA(isA<UnsupportedFormatException>()),
      );
      expect(adapter.requests, isEmpty);
    },
  );
}
