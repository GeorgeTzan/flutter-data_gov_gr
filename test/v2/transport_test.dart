import 'dart:async';
import 'dart:typed_data';
import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/diagnostics.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/resources/download_options.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  final uri = Uri.parse('https://portal.test/file');
  test('HTTP 409 rejects validation with one attempt', () async {
    final adapter = ScriptedAdapter([
      (o) async => ResponseBody.fromString(
        '{"success":false,"error":{"__type":"Validation Error","sort":["invalid field"]}}',
        409,
      ),
    ]);
    final transport = HttpTransport(DataGovConfig(), adapter: adapter);
    addTearDown(transport.close);
    await expectLater(
      transport.requestJson(uri),
      throwsA(
        isA<ValidationException>().having((e) => e.statusCode, 'status', 409),
      ),
    );
    expect(adapter.requests, hasLength(1));
  });
  for (final entry in <int, Type>{
    401: AuthenticationException,
    403: PermissionException,
    404: NotFoundException,
  }.entries) {
    test('HTTP status ${entry.key} maps directly', () async {
      final t = HttpTransport(
        DataGovConfig(),
        adapter: ScriptedAdapter([
          (o) async => ResponseBody.fromString('', entry.key),
        ]),
      );
      addTearDown(t.close);
      try {
        await t.requestJson(uri);
        fail('must throw');
      } catch (e) {
        expect(e.runtimeType, entry.value);
        expect((e as DataGovException).statusCode, entry.key);
      }
    });
  }
  test('rate current and replay expose headers from failures', () async {
    final t = HttpTransport(
      DataGovConfig(),
      adapter: ScriptedAdapter([
        (o) async => ResponseBody.fromString(
          '',
          401,
          headers: {
            'X-RateLimit-Limit': ['100'],
            'X-RateLimit-Remaining': ['7'],
            'X-RateLimit-Reset': ['1791720000'],
          },
        ),
      ]),
    );
    addTearDown(t.close);
    expect((await t.rateLimitStatus.first).available, isFalse);
    await expectLater(
      t.requestJson(uri),
      throwsA(isA<AuthenticationException>()),
    );
    expect(t.currentRateLimitStatus.remaining, 7);
    expect((await t.rateLimitStatus.first).limit, 100);
  });
  test('unknown quota headers remain unavailable', () async {
    final t = HttpTransport(
      DataGovConfig(),
      adapter: ScriptedAdapter([
        (o) async => ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'other': ['100'],
          },
        ),
      ]),
    );
    addTearDown(t.close);
    await t.requestJson(uri);
    expect(t.currentRateLimitStatus.available, isFalse);
  });
  test(
    'download metadata uses final response URI and source headers',
    () async {
      final t = HttpTransport(
        DataGovConfig(),
        adapter: ScriptedAdapter([
          (o) async => ResponseBody.fromString(
            'abc',
            200,
            headers: {
              'content-type': ['text/csv'],
              'content-length': ['3'],
            },
          )..extra['dataGovFinalUrl'] = 'https://files.test/final.csv',
        ]),
        now: () => DateTime.utc(2026),
      );
      addTearDown(t.close);
      final d = await t.openDownload(uri, options: DownloadOptions.defaults);
      expect(d.finalUri.toString(), 'https://files.test/final.csv');
      expect(d.contentType, 'text/csv');
      expect(d.contentLength, 3);
      expect(d.retrievedAt, DateTime.utc(2026));
      expect(await d.bytes.expand((c) => c).toList(), [97, 98, 99]);
    },
  );
  test('stream ceiling aborts before oversized bytes are emitted', () async {
    var cancelled = false;
    final source = StreamController<Uint8List>(
      onCancel: () {
        cancelled = true;
      },
    );
    final t = HttpTransport(
      DataGovConfig(),
      adapter: ScriptedAdapter([(o) async => ResponseBody(source.stream, 200)]),
    );
    addTearDown(t.close);
    source.add(Uint8List.fromList([1, 2, 3]));
    await expectLater(
      t.openDownload(uri, options: DownloadOptions(maxBytes: 2)),
      throwsA(isA<ByteLimitException>()),
    );
    expect(cancelled, isTrue);
  });
  test('cancellation while paused cancels underlying stream', () async {
    var cancelled = false;
    final source = StreamController<Uint8List>(
      onCancel: () {
        cancelled = true;
      },
    );
    final c = CancellationController();
    final t = HttpTransport(
      DataGovConfig(),
      adapter: ScriptedAdapter([(o) async => ResponseBody(source.stream, 200)]),
    );
    addTearDown(t.close);
    source.add(Uint8List.fromList([1]));
    final d = await t.openDownload(
      uri,
      options: DownloadOptions.defaults,
      cancellation: c.signal,
    );
    final sub = d.bytes.listen((_) {}, onError: (_) {});
    sub.pause();
    c.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(cancelled, isTrue);
    await sub.cancel();
  });
  test('deadline aborts headers and body operations', () async {
    final never = Completer<ResponseBody>();
    final t = HttpTransport(
      DataGovConfig(
        retry: RetryPolicy(deadline: const Duration(milliseconds: 20)),
      ),
      adapter: ScriptedAdapter([(o) => never.future]),
    );
    addTearDown(t.close);
    await expectLater(
      t.requestJson(uri),
      throwsA(isA<RequestTimeoutException>()),
    );
  });
  test('idle body timeout is separate from operation deadline', () async {
    var cancelled = false;
    final source = StreamController<Uint8List>(
      onCancel: () {
        cancelled = true;
      },
    );
    final t = HttpTransport(
      DataGovConfig(
        requestTimeout: const Duration(milliseconds: 20),
        retry: RetryPolicy(maxAttempts: 1),
      ),
      adapter: ScriptedAdapter([(o) async => ResponseBody(source.stream, 200)]),
    );
    addTearDown(t.close);
    await expectLater(
      t.openDownload(uri, options: DownloadOptions.defaults),
      throwsA(isA<RequestTimeoutException>()),
    );
    expect(cancelled, isTrue);
  });
  test('download retries a body failure only before emitting bytes', () async {
    final a = ScriptedAdapter([
      (o) async => ResponseBody(
        Stream<Uint8List>.error(StateError('connection dropped')),
        200,
      ),
      (o) async => ResponseBody.fromString(
        'ok',
        200,
        headers: {
          'content-type': ['text/csv'],
          'content-length': ['2'],
        },
      )..extra['dataGovFinalUrl'] = 'https://files.test/retry.csv',
    ]);
    final t = HttpTransport(DataGovConfig(), adapter: a, wait: (d, c) async {});
    addTearDown(t.close);
    final d = await t.openDownload(uri, options: DownloadOptions.defaults);
    expect(await d.bytes.expand((c) => c).toList(), [111, 107]);
    expect(a.requests, hasLength(2));
    expect(d.finalUri.toString(), 'https://files.test/retry.csv');
    expect(d.contentType, 'text/csv');
    expect(d.contentLength, 2);
  });
  test('download cannot retry once bytes reach caller', () async {
    final source = StreamController<Uint8List>();
    final a = ScriptedAdapter([(o) async => ResponseBody(source.stream, 200)]);
    final t = HttpTransport(DataGovConfig(), adapter: a, wait: (d, c) async {});
    addTearDown(t.close);
    source.add(Uint8List.fromList([1]));
    final d = await t.openDownload(uri, options: DownloadOptions.defaults);
    final received = <int>[];
    final done = Completer<Object>();
    d.bytes.listen(
      (chunk) => received.addAll(chunk),
      onError: (Object e) {
        done.complete(e);
      },
    );
    source.addError(StateError('connection dropped'));
    expect(await done.future, isA<NetworkException>());
    expect(received, [1]);
    expect(a.requests, hasLength(1));
  });
  test(
    'external pause suspends idle timeout during a pending body read',
    () async {
      final resumed = Completer<void>();
      var cancelled = false;
      final source = StreamController<Uint8List>(
        onResume: () {
          if (!resumed.isCompleted) resumed.complete();
        },
        onCancel: () {
          cancelled = true;
        },
      );
      source.add(Uint8List.fromList([1]));
      final t = HttpTransport(
        DataGovConfig(
          requestTimeout: const Duration(milliseconds: 20),
          retry: RetryPolicy(maxAttempts: 1),
        ),
        adapter: ScriptedAdapter([
          (o) async => ResponseBody(source.stream, 200),
        ]),
      );
      addTearDown(t.close);
      final d = await t.openDownload(uri, options: DownloadOptions.defaults);
      final chunks = <int>[];
      final done = Completer<void>();
      Object? failure;
      final sub = d.bytes.listen(
        (chunk) => chunks.addAll(chunk),
        onError: (Object error) {
          failure = error;
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );
      addTearDown(sub.cancel);
      await resumed.future;
      sub.pause();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cancelled, isFalse);
      source.add(Uint8List.fromList([2]));
      final closed = source.close();
      sub.resume();
      await closed;
      await done.future;
      expect(failure, isNull);
      expect(chunks, [1, 2]);
    },
  );
  test(
    'completed empty download does not retain an operation deadline',
    () async {
      final t = HttpTransport(
        DataGovConfig(
          retry: RetryPolicy(deadline: const Duration(milliseconds: 20)),
        ),
        adapter: ScriptedAdapter([
          (o) async => ResponseBody.fromString('', 200),
        ]),
      );
      addTearDown(t.close);
      final d = await t.openDownload(uri, options: DownloadOptions.defaults);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await d.bytes.toList(), isEmpty);
    },
  );
  for (final name in ['x-ratelimit-reset', 'ratelimit-reset']) {
    test('oversized $name leaves successful JSON usable', () async {
      var cancelled = false;
      final source = StreamController<Uint8List>(
        onCancel: () {
          cancelled = true;
        },
      );
      source.add(Uint8List.fromList([123, 125]));
      unawaited(source.close());
      final a = ScriptedAdapter([
        (o) async => ResponseBody(
          source.stream,
          200,
          headers: {
            name: ['9999999999999'],
            'x-ratelimit-limit': ['100'],
          },
        ),
      ]);
      final t = HttpTransport(
        DataGovConfig(retry: RetryPolicy(maxAttempts: 1)),
        adapter: a,
      );
      addTearDown(t.close);
      expect(await t.requestJson(uri), isEmpty);
      expect(t.currentRateLimitStatus.limit, 100);
      expect(t.currentRateLimitStatus.resetAt, isNull);
      expect(cancelled, isTrue);
      expect(a.requests, hasLength(1));
    });
    test(
      'oversized $name preserves auth status and cancels discarded body',
      () async {
        var cancelled = false;
        final source = StreamController<Uint8List>(
          onCancel: () {
            cancelled = true;
          },
        );
        final a = ScriptedAdapter([
          (o) async => ResponseBody(
            source.stream,
            401,
            headers: {
              name: ['9999999999999'],
            },
          ),
        ]);
        final t = HttpTransport(
          DataGovConfig(retry: RetryPolicy(maxAttempts: 1)),
          adapter: a,
        );
        addTearDown(t.close);
        await expectLater(
          t.requestJson(uri),
          throwsA(
            isA<AuthenticationException>().having(
              (e) => e.statusCode,
              'status',
              401,
            ),
          ),
        );
        expect(cancelled, isTrue);
        expect(a.requests, hasLength(1));
      },
    );
  }
  test(
    'failed response metadata processing cancels the original body',
    () async {
      var cancelled = false;
      final source = StreamController<Uint8List>(
        onCancel: () {
          cancelled = true;
        },
      );
      final t = HttpTransport(
        DataGovConfig(retry: RetryPolicy(maxAttempts: 1)),
        adapter: ScriptedAdapter([
          (o) async =>
              ResponseBody(source.stream, 200)
                ..extra['dataGovFinalUrl'] = 'https://[invalid',
        ]),
      );
      addTearDown(t.close);
      await expectLater(t.requestJson(uri), throwsA(isA<NetworkException>()));
      expect(cancelled, isTrue);
    },
  );
  test('diagnostics redact secret headers and URL fields', () {
    expect(
      sanitizeDiagnostic('Authorization: secret'),
      isNot(contains('secret')),
    );
    expect(
      sanitizeDiagnostic('https://user:pass@x.test/?token=secret'),
      isNot(contains('secret')),
    );
  });
}
