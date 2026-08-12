import 'dart:async';
import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/core/retry_scheduler.dart';
import 'dart:typed_data';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import '../support/fake_clock.dart';

void main() {
  final uri = Uri.parse('https://portal.test/api/3/action/package_list');
  HttpTransport create(
    ScriptedAdapter adapter, {
    Future<void> Function(Duration, CancellationSignal?)? wait,
    DateTime Function()? now,
  }) => HttpTransport(
    DataGovConfig(),
    adapter: adapter,
    wait: wait ?? (d, c) async {},
    now: now,
    jitter: () => 0.5,
  );
  test('transient success retries once', () async {
    final a = ScriptedAdapter([
      (o) async => ResponseBody.fromString('', 503),
      (o) async => ResponseBody.fromString('{}', 200),
    ]);
    final t = create(a);
    addTearDown(t.close);
    expect(await t.requestJson(uri), isEmpty);
    expect(a.requests, hasLength(2));
  });
  test('exhaustion uses exactly three attempts', () async {
    final a = ScriptedAdapter(
      List.generate(
        3,
        (_) =>
            (RequestOptions o) async => ResponseBody.fromString('', 503),
      ),
    );
    final t = create(a);
    addTearDown(t.close);
    await expectLater(t.requestJson(uri), throwsA(isA<NetworkException>()));
    expect(a.requests, hasLength(3));
  });
  for (final status in [400, 401, 403, 404, 200]) {
    test('validation auth and decode do not retry $status', () async {
      final a = ScriptedAdapter([
        (o) async => ResponseBody.fromString('bad', status),
      ]);
      final t = create(a);
      addTearDown(t.close);
      await expectLater(t.requestJson(uri), throwsA(isA<DataGovException>()));
      expect(a.requests, hasLength(1));
    });
  }
  for (final header in ['2', 'Sun, 11 Oct 2026 12:00:02 GMT']) {
    test('Retry-After delay $header', () async {
      final delays = <Duration>[];
      final a = ScriptedAdapter([
        (o) async => ResponseBody.fromString(
          '',
          429,
          headers: {
            'retry-after': [header],
          },
        ),
        (o) async => ResponseBody.fromString('{}', 200),
      ]);
      final t = create(
        a,
        now: () => DateTime.utc(2026, 10, 11, 12),
        wait: (d, c) async {
          delays.add(d);
        },
      );
      addTearDown(t.close);
      await t.requestJson(uri);
      expect(delays, [const Duration(seconds: 2)]);
    });
  }
  test('transient service failure respects Retry-After', () async {
    final delays = <Duration>[];
    final a = ScriptedAdapter([
      (o) async => ResponseBody.fromString(
        '',
        503,
        headers: {
          'retry-after': ['3'],
        },
      ),
      (o) async => ResponseBody.fromString('{}', 200),
    ]);
    final t = create(
      a,
      now: () => DateTime.utc(2026),
      wait: (d, c) async {
        delays.add(d);
      },
    );
    addTearDown(t.close);
    await t.requestJson(uri);
    expect(delays, [const Duration(seconds: 3)]);
  });
  test('retry beyond deadline retains retry timing', () async {
    final now = DateTime.utc(2026, 10, 11);
    final a = ScriptedAdapter([
      (o) async => ResponseBody.fromString(
        '',
        429,
        headers: {
          'retry-after': ['61'],
        },
      ),
    ]);
    final t = create(a, now: () => now);
    addTearDown(t.close);
    await expectLater(
      t.requestJson(uri),
      throwsA(
        isA<RateLimitException>().having(
          (e) => e.retryAt,
          'retryAt',
          now.add(const Duration(seconds: 61)),
        ),
      ),
    );
    expect(a.requests, hasLength(1));
  });
  test('cancel during backoff prevents another attempt', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final c = CancellationController();
    final a = ScriptedAdapter([(o) async => ResponseBody.fromString('', 503)]);
    final t = create(a, now: clock.now, wait: clock.wait);
    addTearDown(t.close);
    final future = t.requestJson(uri, cancellation: c.signal);
    final assertion = expectLater(future, throwsA(isA<CancelledException>()));
    while (clock.pendingWaitCount == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    c.cancel();
    await assertion;
    expect(a.requests, hasLength(1));
  });
  for (final status in [429, 503]) {
    test(
      'oversized Retry-After $status falls back and cancels failed body',
      () async {
        var cancelled = false;
        final delays = <Duration>[];
        final source = StreamController<Uint8List>(
          onCancel: () {
            cancelled = true;
          },
        );
        final a = ScriptedAdapter([
          (o) async => ResponseBody(
            source.stream,
            status,
            headers: {
              'retry-after': ['9999999999999'],
            },
          ),
          (o) async => ResponseBody.fromString('{}', 200),
        ]);
        final t = create(
          a,
          now: () => DateTime.utc(2026),
          wait: (d, c) async {
            delays.add(d);
          },
        );
        addTearDown(t.close);
        expect(await t.requestJson(uri), isEmpty);
        expect(cancelled, isTrue);
        expect(delays, [const Duration(milliseconds: 250)]);
        expect(a.requests, hasLength(2));
      },
    );
  }
  test('oversized Retry-After retains exhausted quota status', () async {
    var cancelled = false;
    final source = StreamController<Uint8List>(
      onCancel: () {
        cancelled = true;
      },
    );
    final a = ScriptedAdapter([
      (o) async => ResponseBody(
        source.stream,
        429,
        headers: {
          'retry-after': ['9223372036854775807'],
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
        isA<RateLimitException>()
            .having((e) => e.statusCode, 'status', 429)
            .having((e) => e.retryAt, 'retryAt', isNull),
      ),
    );
    expect(cancelled, isTrue);
  });
  for (final initial in [Duration.zero, const Duration(milliseconds: 250)]) {
    test('large attempt keeps $initial backoff bounded', () {
      final scheduler = RetryScheduler(
        RetryPolicy(maxAttempts: 1000000, initialBackoff: initial),
        now: () => DateTime.utc(2026),
        jitter: () => 0.5,
      );
      expect(
        scheduler.delay(1000000),
        initial == Duration.zero ? Duration.zero : const Duration(seconds: 2),
      );
    });
  }
  test('each page receives a fresh deadline', () async {
    var now = DateTime.utc(2026);
    final delays = <Duration>[];
    final a = ScriptedAdapter(
      List.generate(
        4,
        (i) =>
            (RequestOptions o) async => ResponseBody.fromString(
              i.isEven ? '' : '{}',
              i.isEven ? 503 : 200,
            ),
      ),
    );
    final t = create(
      a,
      now: () => now,
      wait: (d, c) async {
        delays.add(d);
        now = now.add(d);
      },
    );
    addTearDown(t.close);
    await t.requestJson(uri);
    now = now.add(const Duration(minutes: 2));
    await t.requestJson(uri);
    expect(delays, hasLength(2));
  });
}
