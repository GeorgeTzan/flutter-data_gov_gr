import 'dart:async';
import 'dart:typed_data';

import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/catalog/resource_metadata.dart';
import 'package:data_gov_gr/src/models/resources/download_options.dart';
import 'package:data_gov_gr/src/services/resource_service.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

ResourceMetadata _resource(Map<String, dynamic> fields) =>
    ResourceMetadata.fromJson({'id': 'resource-7', ...fields});

ResourceService _service(
  ScriptedAdapter adapter, {
  DataGovConfig? config,
  DateTime Function()? now,
}) {
  final transport = HttpTransport(
    config ?? DataGovConfig(),
    adapter: adapter,
    now: now,
    wait: (duration, cancellation) async {},
  );
  addTearDown(transport.close);
  return ResourceService(transport);
}

final _file = _resource({'url': 'https://files.test/source.csv'});

void main() {
  test('selects primary file URL while retaining distinct URL roles', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody.fromString('file', 200),
    ]);
    final resource = _resource({
      'url': 'https://files.test/source.csv',
      'download_url': 'https://portal.test/catalog/resource-7',
      'access_url': 'https://api.test/service',
      'url_type': 'download',
    });
    final download = await _service(adapter).download(resource);
    expect(
      adapter.requests.single.uri.toString(),
      'https://files.test/source.csv',
    );
    expect(resource.downloadUrl, 'https://portal.test/catalog/resource-7');
    expect(resource.accessUrl, 'https://api.test/service');
    expect(await download.bytes.expand((chunk) => chunk).toList(), [
      102,
      105,
      108,
      101,
    ]);
  });

  test('uses explicit download-role URL when primary URL is absent', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody.fromString('x', 200),
    ]);
    final download = await _service(adapter).download(
      _resource({
        'download_url': 'https://files.test/role.zip',
        'url_type': 'download',
      }),
    );
    expect(
      adapter.requests.single.uri.toString(),
      'https://files.test/role.zip',
    );
    expect(download.provenance.sourceUrl, 'https://files.test/role.zip');
    await download.bytes.drain<void>();
  });

  final rejected = <String, Map<String, dynamic>>{
    'missing URL': {},
    'dummy URL': {'url': 'dummy'},
    'empty primary URL with valid fallback': {
      'url': '',
      'download_url': 'https://files.test/fallback.csv',
      'url_type': 'download',
    },
    'invalid primary URL with valid fallback': {
      'url': 'dummy',
      'download_url': 'https://files.test/fallback.csv',
      'resource_type': 'file',
    },
    'download URL without explicit file role': {
      'download_url': 'https://portal.test/catalog/resource-7',
    },
    'access URL alone': {'access_url': 'https://files.test/source.csv'},
    'service URL role': {'url': 'https://api.test/service', 'url_type': 'api'},
    'documentation resource role': {
      'url': 'https://portal.test/documentation',
      'resource_type': 'documentation',
    },
    'FTP URL': {'url': 'ftp://files.test/source.csv'},
    'local file URL': {'url': 'file:///source.csv'},
    'data URI': {'url': 'data:text/csv,a%2Cb'},
    'relative URL': {'url': '/source.csv'},
    'URL with credentials': {'url': 'https://user:pass@files.test/source.csv'},
    'URL with whitespace': {'url': 'https://files.test/source file.csv'},
  };
  for (final entry in rejected.entries) {
    test('rejects ${entry.key} before requesting a source', () async {
      final adapter = ScriptedAdapter([]);
      await expectLater(
        _service(adapter).download(_resource(entry.value)),
        throwsA(isA<UnsupportedResourceException>()),
      );
      expect(adapter.requests, isEmpty);
    });
  }

  for (final scheme in ['http', 'https']) {
    test('supports $scheme file downloads', () async {
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody.fromString('x', 200),
      ]);
      final download = await _service(
        adapter,
      ).download(_resource({'url': '$scheme://files.test/source.csv'}));
      expect(download.finalUrl.toString(), '$scheme://files.test/source.csv');
      await download.bytes.drain<void>();
    });
  }

  for (final format in ['PDF', 'ZIP']) {
    test('downloads $format without requiring a parser', () async {
      final adapter = ScriptedAdapter([
        (options) async =>
            ResponseBody(Stream.value(Uint8List.fromList([0, 255, 13])), 200),
      ]);
      final download = await _service(adapter).download(
        _resource({
          'url': 'https://files.test/source.${format.toLowerCase()}',
          'format': format,
        }),
      );
      expect(await download.bytes.expand((chunk) => chunk).toList(), [
        0,
        255,
        13,
      ]);
    });
  }

  test(
    'retains final response metadata and original source provenance',
    () async {
      final retrievedAt = DateTime.utc(2026, 10, 11, 15);
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody.fromString(
          'abc',
          200,
          headers: {
            'content-type': ['application/pdf'],
            'content-length': ['3'],
          },
        )..extra['dataGovFinalUrl'] = 'https://cdn.test/final.pdf',
      ]);
      final download = await _service(adapter, now: () => retrievedAt).download(
        _resource({
          'url': 'https://files.test/source.pdf',
          'package_id': 'entry-7',
          'last_modified': '2025-03-14T09:26:53',
        }),
      );
      expect(download.finalUrl.toString(), 'https://cdn.test/final.pdf');
      expect(download.contentType, 'application/pdf');
      expect(download.contentLength, 3);
      expect(download.provenance.entryId, 'entry-7');
      expect(download.provenance.resourceId, 'resource-7');
      expect(download.provenance.sourceUrl, 'https://files.test/source.pdf');
      expect(download.provenance.publishedModified?.raw, '2025-03-14T09:26:53');
      expect(download.provenance.publishedModified?.utcValue, isNull);
      expect(download.provenance.retrievedAt, retrievedAt);
      expect(download.provenance.sourceRow, isNull);
      await download.bytes.drain<void>();
    },
  );

  test(
    'missing metadata stays missing and retrieval time comes from transport',
    () async {
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody.fromString('', 200),
      ]);
      final download = await _service(
        adapter,
        now: () => DateTime.utc(2026),
      ).download(_file);
      expect(download.contentType, isNull);
      expect(download.contentLength, isNull);
      expect(download.provenance.entryId, isNull);
      expect(download.provenance.publishedModified, isNull);
      expect(download.provenance.retrievedAt, DateTime.utc(2026));
      expect(await download.bytes.toList(), isEmpty);
    },
  );

  test(
    'default decoded ceiling rejects an oversized first chunk before opening',
    () async {
      expect(DownloadOptions.defaults.maxBytes, 67108864);
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(Stream.value(Uint8List(67108865)), 200),
      ]);
      await expectLater(
        _service(adapter).download(_file),
        throwsA(isA<ByteLimitException>()),
      );
      expect(adapter.requests, hasLength(1));
    },
  );

  for (final length in [null, '1', '999999999']) {
    test(
      'decoded ceiling rejects later chunk with Content-Length $length',
      () async {
        final adapter = ScriptedAdapter([
          (options) async => ResponseBody(
            Stream.fromIterable([
              Uint8List.fromList([1, 2]),
              Uint8List.fromList([3, 4]),
            ]),
            200,
            headers: {
              if (length != null) 'content-length': [length],
            },
          ),
        ]);
        final download = await _service(
          adapter,
        ).download(_file, options: DownloadOptions(maxBytes: 3));
        expect(
          download.contentLength,
          length == null ? null : int.parse(length),
        );
        final emitted = <int>[];
        await expectLater(
          download.bytes.map((chunk) {
            emitted.addAll(chunk);
            return chunk;
          }).drain<void>(),
          throwsA(isA<ByteLimitException>()),
        );
        expect(emitted, [1, 2]);
        expect(adapter.requests, hasLength(1));
      },
    );
  }

  for (final maxBytes in [67108865, null]) {
    test('accepts caller ceiling $maxBytes beyond the default', () async {
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(Stream.value(Uint8List(67108865)), 200),
      ]);
      final download = await _service(
        adapter,
      ).download(_file, options: DownloadOptions(maxBytes: maxBytes));
      expect(
        await download.bytes.fold<int>(0, (size, chunk) => size + chunk.length),
        67108865,
      );
    });
  }

  test('accepts a stream exactly at the decoded ceiling', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody(
        Stream.fromIterable([
          Uint8List.fromList([1, 2]),
          Uint8List.fromList([3]),
        ]),
        200,
      ),
    ]);
    final download = await _service(
      adapter,
    ).download(_file, options: DownloadOptions(maxBytes: 3));
    expect(await download.bytes.expand((chunk) => chunk).toList(), [1, 2, 3]);
  });

  test(
    'does not consume the next source chunk while subscription is paused',
    () async {
      var produced = 0;
      Stream<Uint8List> source() async* {
        produced++;
        yield Uint8List.fromList([1]);
        produced++;
        yield Uint8List.fromList([2]);
      }

      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(source(), 200),
      ]);
      final download = await _service(adapter).download(_file);
      expect(produced, 1);
      final first = Completer<void>();
      final done = Completer<void>();
      final emitted = <int>[];
      late StreamSubscription<List<int>> subscription;
      subscription = download.bytes.listen((chunk) {
        emitted.addAll(chunk);
        if (!first.isCompleted) {
          subscription.pause();
          first.complete();
        }
      }, onDone: done.complete);
      addTearDown(subscription.cancel);
      await first.future;
      await Future<void>.delayed(Duration.zero);
      expect(produced, 1);
      expect(emitted, [1]);
      subscription.resume();
      await done.future;
      expect(produced, 2);
      expect(emitted, [1, 2]);
    },
  );

  test('cancellation after opening aborts the underlying transfer', () async {
    final cancelled = Completer<void>();
    final source = StreamController<Uint8List>(onCancel: cancelled.complete);
    source.add(Uint8List.fromList([1]));
    final cancellation = CancellationController();
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody(source.stream, 200),
    ]);
    final download = await _service(
      adapter,
    ).download(_file, cancellation: cancellation.signal);
    final observed = expectLater(
      download.bytes.drain<void>(),
      throwsA(isA<CancelledException>()),
    );
    cancellation.cancel('stop download');
    await observed;
    await cancelled.future;
    expect(adapter.requests, hasLength(1));
  });

  test(
    'subscription cancellation propagates to the underlying source',
    () async {
      final cancelled = Completer<void>();
      final source = StreamController<Uint8List>(onCancel: cancelled.complete);
      source.add(Uint8List.fromList([1]));
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(source.stream, 200),
      ]);
      final download = await _service(adapter).download(_file);
      final subscription = download.bytes.listen((chunk) {});
      await subscription.cancel();
      await cancelled.future;
    },
  );

  test('pre-cancelled signal rejects opening without any request', () async {
    final cancellation = CancellationController()..cancel('already stopped');
    final adapter = ScriptedAdapter([]);
    await expectLater(
      _service(adapter).download(_file, cancellation: cancellation.signal),
      throwsA(isA<CancelledException>()),
    );
    expect(adapter.requests, isEmpty);
  });

  test(
    'cancellation before first chunk rejects opening and aborts source',
    () async {
      final listening = Completer<void>();
      final cancelled = Completer<void>();
      final source = StreamController<Uint8List>(
        onListen: listening.complete,
        onCancel: cancelled.complete,
      );
      final cancellation = CancellationController();
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(source.stream, 200),
      ]);
      final observed = expectLater(
        _service(adapter).download(_file, cancellation: cancellation.signal),
        throwsA(isA<CancelledException>()),
      );
      await listening.future;
      cancellation.cancel();
      await observed;
      await cancelled.future;
      expect(adapter.requests, hasLength(1));
    },
  );

  test('idle timeout before first chunk rejects opening', () async {
    final cancelled = Completer<void>();
    final source = StreamController<Uint8List>(onCancel: cancelled.complete);
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody(source.stream, 200),
    ]);
    await expectLater(
      _service(
        adapter,
        config: DataGovConfig(
          requestTimeout: const Duration(milliseconds: 20),
          retry: RetryPolicy(maxAttempts: 1),
        ),
      ).download(_file),
      throwsA(isA<RequestTimeoutException>()),
    );
    await cancelled.future;
  });

  test('caller deadline overrides configured operation deadline', () async {
    final adapter = ScriptedAdapter([
      (options) => Completer<ResponseBody>().future,
    ]);
    await expectLater(
      _service(adapter).download(
        _file,
        options: DownloadOptions(deadline: const Duration(milliseconds: 20)),
      ),
      throwsA(isA<RequestTimeoutException>()),
    );
    expect(adapter.requests, hasLength(1));
  });

  test(
    'pre-byte retry publishes metadata only from the successful response',
    () async {
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(
          Stream<Uint8List>.error(StateError('dropped before first byte')),
          200,
          headers: {
            'content-type': ['application/pdf'],
            'content-length': ['99'],
          },
        )..extra['dataGovFinalUrl'] = 'https://cdn.test/failed.pdf',
        (options) async => ResponseBody.fromString(
          'ok',
          200,
          headers: {
            'content-type': ['text/csv'],
            'content-length': ['2'],
          },
        )..extra['dataGovFinalUrl'] = 'https://cdn.test/success.csv',
      ]);
      final download = await _service(adapter).download(_file);
      expect(download.finalUrl.toString(), 'https://cdn.test/success.csv');
      expect(download.contentType, 'text/csv');
      expect(download.contentLength, 2);
      expect(await download.bytes.expand((chunk) => chunk).toList(), [
        111,
        107,
      ]);
      expect(adapter.requests, hasLength(2));
    },
  );

  test(
    'failure after an emitted chunk is an SDK error without retry',
    () async {
      final source = StreamController<Uint8List>();
      source.add(Uint8List.fromList([1]));
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody(source.stream, 200),
        (options) async => ResponseBody.fromString('must not retry', 200),
      ]);
      final download = await _service(adapter).download(_file);
      final emitted = <int>[];
      final observed = expectLater(
        download.bytes.map((chunk) {
          emitted.addAll(chunk);
          source.addError(StateError('dropped after first byte'));
          return chunk;
        }).drain<void>(),
        throwsA(
          isA<NetworkException>().having(
            (error) => error.originalError,
            'original error',
            isA<StateError>(),
          ),
        ),
      );
      await observed;
      expect(emitted, [1]);
      expect(adapter.requests, hasLength(1));
    },
  );

  test('download stream permits only one subscription', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody.fromString('x', 200),
    ]);
    final download = await _service(adapter).download(_file);
    await download.bytes.drain<void>();
    expect(() => download.bytes.listen((chunk) {}), throwsStateError);
  });

  test('download events and failure stack reach the listener zone', () async {
    final source = StreamController<Uint8List>();
    source.add(Uint8List.fromList([1]));
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody(source.stream, 200),
    ]);
    final download = await _service(adapter).download(_file);
    final original = StateError('source failure');
    final stack = StackTrace.fromString('resource source stack');
    final marker = Object();
    final events = <String>[];
    final done = Completer<void>();
    runZoned(
      () => download.bytes.listen(
        (chunk) {
          events.add('bytes:${Zone.current[marker]}');
          source.addError(original, stack);
        },
        onError: (Object error, StackTrace observedStack) {
          events.add('error:${Zone.current[marker]}');
          expect(
            error,
            isA<NetworkException>().having(
              (failure) => failure.originalError,
              'original error',
              same(original),
            ),
          );
          expect(observedStack.toString(), 'resource source stack');
        },
        onDone: () {
          events.add('done:${Zone.current[marker]}');
          done.complete();
        },
      ),
      zoneValues: {marker: 'listener'},
    );
    await done.future;
    expect(events, ['bytes:listener', 'error:listener', 'done:listener']);
  });

  test(
    'redirected download keeps credentials out of every file request',
    () async {
      final adapter = ScriptedAdapter([
        (options) async => ResponseBody.fromString(
          '',
          302,
          headers: {
            'location': ['https://cdn.test/redirected.csv'],
          },
        ),
        (options) async => ResponseBody.fromString('x', 200),
      ]);
      final download = await _service(
        adapter,
        config: DataGovConfig(
          actionBaseUrl: Uri.parse('https://portal.test/api/3/action/'),
          apiKey: 'portal-secret',
        ),
      ).download(_resource({'url': 'https://portal.test/files/source.csv'}));
      expect(download.finalUrl.toString(), 'https://cdn.test/redirected.csv');
      expect(
        download.provenance.sourceUrl,
        'https://portal.test/files/source.csv',
      );
      expect(adapter.requests, hasLength(2));
      for (final request in adapter.requests) {
        expect(
          request.headers.keys.map((key) => key.toLowerCase()),
          isNot(contains('authorization')),
        );
        expect(request.headers.values, isNot(contains('portal-secret')));
        expect(
          request.uri.queryParameters.values,
          isNot(contains('portal-secret')),
        );
      }
      await download.bytes.drain<void>();
    },
  );

  test('rejects redirect to an unsupported scheme', () async {
    final adapter = ScriptedAdapter([
      (options) async => ResponseBody.fromString(
        '',
        302,
        headers: {
          'location': ['ftp://files.test/source.csv'],
        },
      ),
    ]);
    await expectLater(
      _service(adapter).download(_file),
      throwsA(isA<ValidationException>()),
    );
    expect(adapter.requests, hasLength(1));
  });

  test(
    'closed client rejection takes precedence over resource validation',
    () async {
      final adapter = ScriptedAdapter([]);
      final transport = HttpTransport(DataGovConfig(), adapter: adapter);
      transport.close();
      await expectLater(
        ResourceService(transport).download(_resource({})),
        throwsA(isA<ClientClosedException>()),
      );
      expect(adapter.requests, isEmpty);
    },
  );
}
