@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/fetch_adapter_web.dart'
    show FetchHttpClientAdapter;
import 'package:data_gov_gr/src/core/http_transport.dart';
import 'package:data_gov_gr/src/core/platform_adapter.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/resources/download_options.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

extension type _Source._(JSObject _) implements JSObject {
  external factory _Source({JSFunction pull, JSFunction cancel});
}

final class _BrowserBody {
  _BrowserBody(List<List<int>> chunks) {
    stream = web.ReadableStream(
      _Source(
        pull: ((web.ReadableStreamDefaultController controller) {
          pulls++;
          if (index == chunks.length) {
            closed = true;
            controller.close();
          } else {
            controller.enqueue(Uint8List.fromList(chunks[index++]).toJS);
          }
        }).toJS,
        cancel: ((JSAny? _) {
          cancellations++;
        }).toJS,
      ),
      web.QueuingStrategy(highWaterMark: 0),
    );
  }

  late final web.ReadableStream stream;
  int index = 0;
  int pulls = 0;
  int cancellations = 0;
  bool closed = false;

  web.Response get response => web.Response(
    stream,
    web.ResponseInit(
      status: 200,
      headers: web.Headers()..set('x-test', 'value'),
    ),
  );
}

Future<void> _turn() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  test('browser default selects the incremental Fetch adapter', () {
    final adapter = createPlatformAdapter();
    expect(adapter, isA<FetchHttpClientAdapter>());
    adapter.close();
  });

  test('does not read until subscribed and emits before browser EOF', () async {
    final source = _BrowserBody([
      [1, 2],
      [3, 4],
    ]);
    final adapter = FetchHttpClientAdapter(
      fetch: (_, _) async => source.response,
    );
    addTearDown(adapter.close);
    final response = await adapter.fetch(
      RequestOptions(path: '/file'),
      null,
      null,
    );
    expect(source.pulls, 0);
    final iterator = StreamIterator(response.stream);
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, [1, 2]);
    expect(response.headers['x-test'], ['value']);
    expect(source.closed, isFalse);
    await iterator.cancel();
  });

  test(
    'pausing the consumer stops ReadableStream reads until resumed',
    () async {
      final source = _BrowserBody([
        [1],
        [2],
        [3],
      ]);
      final adapter = FetchHttpClientAdapter(
        fetch: (_, _) async => source.response,
      );
      addTearDown(adapter.close);
      final response = await adapter.fetch(
        RequestOptions(path: '/file'),
        null,
        null,
      );
      final first = Completer<void>();
      final done = Completer<void>();
      final received = <int>[];
      late StreamSubscription<Uint8List> subscription;
      subscription = response.stream.listen(
        (chunk) {
          received.addAll(chunk);
          if (!first.isCompleted) {
            subscription.pause();
            first.complete();
          }
        },
        onDone: done.complete,
        onError: done.completeError,
      );
      await first.future;
      await _turn();
      expect(source.pulls, 1);
      expect(received, [1]);
      subscription.resume();
      await done.future;
      expect(received, [1, 2, 3]);
    },
  );

  test(
    'subscription cancellation aborts Fetch and cancels its reader',
    () async {
      final source = _BrowserBody([
        [1],
        [2],
      ]);
      late web.AbortSignal signal;
      final adapter = FetchHttpClientAdapter(
        fetch: (_, init) async {
          signal = init.signal!;
          return source.response;
        },
      );
      addTearDown(adapter.close);
      final response = await adapter.fetch(
        RequestOptions(path: '/file'),
        null,
        null,
      );
      final iterator = StreamIterator(response.stream);
      expect(await iterator.moveNext(), isTrue);
      await iterator.cancel();
      expect(signal.aborted, isTrue);
      expect(source.cancellations, 1);
      expect(source.pulls, 1);
    },
  );

  test('crossing a downstream byte cap cancels before another read', () async {
    final source = _BrowserBody([
      [1, 2],
      [3, 4],
      [5, 6],
    ]);
    final adapter = FetchHttpClientAdapter(
      fetch: (_, _) async => source.response,
    );
    addTearDown(adapter.close);
    final response = await adapter.fetch(
      RequestOptions(path: '/file'),
      null,
      null,
    );
    final iterator = StreamIterator(response.stream);
    var count = 0;
    while (await iterator.moveNext()) {
      count += iterator.current.length;
      if (count > 3) {
        await iterator.cancel();
        break;
      }
    }
    expect(count, 4);
    expect(source.pulls, 2);
    expect(source.cancellations, 1);
  });

  test('Dio cancellation aborts a fetch still waiting for headers', () async {
    final response = Completer<web.Response>();
    final cancellation = Completer<void>();
    late web.AbortSignal signal;
    final adapter = FetchHttpClientAdapter(
      fetch: (_, init) {
        signal = init.signal!;
        return response.future;
      },
    );
    addTearDown(adapter.close);
    final pending = adapter.fetch(
      RequestOptions(path: '/file'),
      null,
      cancellation.future,
    );
    final assertion = expectLater(
      pending,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await _turn();
    cancellation.complete();
    await assertion;
    expect(signal.aborted, isTrue);
    response.complete(web.Response());
  });

  test(
    'manual redirects and omitted ambient credentials reach Fetch',
    () async {
      late web.RequestInit request;
      final adapter = FetchHttpClientAdapter(
        fetch: (_, init) async {
          request = init;
          return web.Response();
        },
      );
      addTearDown(adapter.close);
      final response = await adapter.fetch(
        RequestOptions(path: '/portal', followRedirects: false),
        null,
        null,
      );
      expect(request.redirect, 'manual');
      expect(request.credentials, 'omit');
      await response.stream.drain<void>();
    },
  );

  test('cancellation stops collecting a pending request body', () async {
    final cancellation = Completer<void>();
    final bodyCancelled = Completer<void>();
    final body = StreamController<Uint8List>(onCancel: bodyCancelled.complete);
    var fetches = 0;
    final adapter = FetchHttpClientAdapter(
      fetch: (_, _) async {
        fetches++;
        return web.Response();
      },
    );
    addTearDown(adapter.close);
    addTearDown(body.close);
    final pending = adapter.fetch(
      RequestOptions(path: '/portal', method: 'POST'),
      body.stream,
      cancellation.future,
    );
    final assertion = expectLater(
      pending,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await _turn();
    cancellation.complete();
    await bodyCancelled.future.timeout(const Duration(seconds: 1));
    await assertion;
    expect(fetches, 0);
  });

  test('cancellation stops a reader while its next read is pending', () async {
    final cancellation = Completer<void>();
    var cancelled = 0;
    final stream = web.ReadableStream(
      _Source(
        pull: ((web.ReadableStreamDefaultController _) {}).toJS,
        cancel: ((JSAny? _) {
          cancelled++;
        }).toJS,
      ),
      web.QueuingStrategy(highWaterMark: 0),
    );
    late web.AbortSignal signal;
    final adapter = FetchHttpClientAdapter(
      fetch: (_, init) async {
        signal = init.signal!;
        return web.Response(stream);
      },
    );
    addTearDown(adapter.close);
    final response = await adapter.fetch(
      RequestOptions(path: '/file'),
      null,
      cancellation.future,
    );
    final result = expectLater(
      response.stream.toList(),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await _turn();
    cancellation.complete();
    await result;
    expect(signal.aborted, isTrue);
    expect(cancelled, 1);
  });

  test(
    'forced close cancels an unconsumed response and rejects reuse',
    () async {
      final source = _BrowserBody([
        [1],
        [2],
      ]);
      late web.AbortSignal signal;
      final adapter = FetchHttpClientAdapter(
        fetch: (_, init) async {
          signal = init.signal!;
          return source.response;
        },
      );
      final response = await adapter.fetch(
        RequestOptions(path: '/file'),
        null,
        null,
      );
      adapter.close(force: true);
      await expectLater(response.stream.toList(), throwsA(isA<DioException>()));
      expect(signal.aborted, isTrue);
      expect(source.cancellations, 1);
      await expectLater(
        adapter.fetch(RequestOptions(path: '/other'), null, null),
        throwsStateError,
      );
    },
  );

  test(
    'transport byte ceiling aborts Fetch before another browser read',
    () async {
      final source = _BrowserBody([
        [1, 2],
        [3, 4],
        [5, 6],
      ]);
      late web.RequestInit request;
      final adapter = FetchHttpClientAdapter(
        fetch: (_, init) async {
          request = init;
          return source.response;
        },
      );
      final transport = HttpTransport(
        DataGovConfig(apiKey: 'portal-key'),
        adapter: adapter,
      );
      addTearDown(transport.close);
      addTearDown(adapter.close);
      final download = await transport.openDownload(
        Uri.parse('https://data.gov.gr/files/data.csv'),
        options: DownloadOptions(maxBytes: 3),
      );
      final received = <int>[];
      await expectLater(
        download.bytes.forEach(received.addAll),
        throwsA(isA<ByteLimitException>()),
      );
      expect(received, [1, 2]);
      expect(source.pulls, 2);
      expect(source.cancellations, 1);
      expect(request.signal!.aborted, isTrue);
      expect(request.redirect, 'follow');
      expect(web.Headers(request.headers).get('authorization'), isNull);
      expect(
        download.finalUri,
        Uri.parse('https://data.gov.gr/files/data.csv'),
      );
    },
  );

  test('transport propagates consumer pause to the browser reader', () async {
    final source = _BrowserBody([
      [1],
      [2],
      [3],
    ]);
    final adapter = FetchHttpClientAdapter(
      fetch: (_, _) async => source.response,
    );
    final transport = HttpTransport(DataGovConfig(), adapter: adapter);
    addTearDown(transport.close);
    addTearDown(adapter.close);
    final download = await transport.openDownload(
      Uri.parse('https://example.test/file'),
      options: DownloadOptions(),
    );
    expect(source.pulls, 1);
    await _turn();
    expect(source.pulls, 1);
    expect(source.closed, isFalse);
    final first = Completer<void>();
    final done = Completer<void>();
    final received = <int>[];
    late StreamSubscription<Uint8List> subscription;
    subscription = download.bytes.listen(
      (chunk) {
        received.addAll(chunk);
        if (!first.isCompleted) {
          subscription.pause();
          first.complete();
        }
      },
      onDone: done.complete,
      onError: done.completeError,
    );
    await first.future;
    await _turn();
    expect(source.pulls, 1);
    subscription.resume();
    await done.future;
    expect(received, [1, 2, 3]);
  });

  test(
    'forced close from a data callback reports cancellation safely',
    () async {
      final source = _BrowserBody([
        [1],
        [2],
      ]);
      final adapter = FetchHttpClientAdapter(
        fetch: (_, _) async => source.response,
      );
      final response = await adapter.fetch(
        RequestOptions(path: '/file'),
        null,
        null,
      );
      final error = Completer<Object>();
      final done = Completer<void>();
      response.stream.listen(
        (_) {
          adapter.close(force: true);
        },
        onError: error.complete,
        onDone: done.complete,
      );
      expect(
        await error.future.timeout(const Duration(seconds: 1)),
        isA<DioException>(),
      );
      await done.future;
      expect(source.pulls, 1);
      expect(source.cancellations, 1);
    },
  );

  test('exposes final browser URL from a real Fetch response', () async {
    const url = 'data:application/octet-stream,hello';
    final adapter = FetchHttpClientAdapter();
    addTearDown(adapter.close);
    final response = await adapter.fetch(RequestOptions(path: url), null, null);
    expect(response.extra['dataGovFinalUrl'], url);
    expect(await response.stream.expand((chunk) => chunk).toList(), [
      104,
      101,
      108,
      108,
      111,
    ]);
  });
}
