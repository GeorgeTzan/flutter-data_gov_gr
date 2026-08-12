import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

/// The browser Fetch boundary, injectable with real browser responses in tests.
typedef BrowserFetch =
    Future<web.Response> Function(String url, web.RequestInit init);

extension type _IterableHeaders(JSObject _) implements JSObject {
  external void forEach(JSFunction callback);
}

/// Creates the browser transport adapter.
HttpClientAdapter createPlatformAdapter() => FetchHttpClientAdapter();

/// A browser Fetch adapter exposing incremental response bytes.
///
/// The reader is acquired on subscription and stops reading while paused.
/// Cancelling the response aborts Fetch and cancels the reader. Ambient browser
/// credentials are omitted, and [RequestOptions.followRedirects] selects Fetch's
/// `follow` or `manual` redirect mode. The final browser response URL is carried
/// in `ResponseBody.extra['dataGovFinalUrl']` for transport metadata.
final class FetchHttpClientAdapter implements HttpClientAdapter {
  /// Uses the browser Fetch function unless [fetch] is supplied.
  FetchHttpClientAdapter({BrowserFetch? fetch})
    : _fetch = fetch ?? _browserFetch;

  final BrowserFetch _fetch;
  final Set<_FetchOperation> _active = {};
  bool _closed = false;

  static Future<web.Response> _browserFetch(String url, web.RequestInit init) =>
      web.window.fetch(url.toJS, init).toDart;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_closed) throw StateError('FetchHttpClientAdapter is closed.');
    final operation = _FetchOperation(options);
    operation.onFinished = () => _active.remove(operation);
    _active.add(operation);
    final cancelled = operation.cancelled.future.then<web.Response>((_) {
      throw operation.error!;
    });
    // Attach the rejection handler before awaiting any request body work.
    unawaited(cancelled.then<void>((_) {}, onError: (Object _) {}));
    if (cancelFuture != null) {
      unawaited(cancelFuture.then((_) => operation.cancel()));
    }
    if (options.cancelToken?.isCancelled ?? false) {
      await operation.cancel();
      throw operation.error!;
    }
    try {
      final headers = web.Headers();
      options.headers.forEach((name, value) {
        if (value is Iterable) {
          for (final part in value) {
            headers.append(name, part.toString());
          }
        } else if (value != null) {
          headers.set(name, value.toString());
        }
      });
      JSAny? body;
      if (requestStream != null) {
        final bytes = BytesBuilder();
        final upload = StreamIterator(requestStream);
        operation.upload = upload;
        while (await upload.moveNext()) {
          bytes.add(upload.current);
        }
        operation.upload = null;
        body = bytes.takeBytes().toJS;
      }
      if (operation.stopped) throw operation.error!;
      final request = web.RequestInit(
        method: options.method,
        headers: headers,
        body: body,
        credentials: 'omit',
        redirect: options.followRedirects ? 'follow' : 'manual',
        signal: operation.abort.signal,
      );
      final fetched = _fetch(options.uri.toString(), request).then((response) {
        operation.body = response.body;
        if (operation.stopped && response.body != null) {
          unawaited(
            response.body!.cancel().toDart.then<void>(
              (_) {},
              onError: (Object _) {},
            ),
          );
        }
        return response;
      });
      final response = await Future.any([fetched, cancelled]);
      final responseHeaders = <String, List<String>>{};
      _IterableHeaders(response.headers).forEach(
        ((JSString value, JSString name, JSAny? _) {
          responseHeaders[name.toDart] = [value.toDart];
        }).toJS,
      );
      final result = ResponseBody(
        operation.stream(),
        response.status,
        statusMessage: response.statusText,
        isRedirect:
            response.type == 'opaqueredirect' ||
            (response.status >= 300 && response.status < 400),
        headers: responseHeaders,
        onClose: () => unawaited(operation.cancel(notify: false)),
      );
      result.extra['dataGovFinalUrl'] = response.url.isEmpty
          ? options.uri.toString()
          : response.url;
      return result;
    } catch (error) {
      await operation.cancel(notify: false);
      if (error is DioException) rethrow;
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: error,
      );
    }
  }

  @override
  void close({bool force = false}) {
    _closed = true;
    if (force) {
      for (final operation in _active.toList()) {
        unawaited(operation.cancel());
      }
    }
  }
}

final class _FetchOperation {
  _FetchOperation(this.options);

  final RequestOptions options;
  late final void Function() onFinished;
  final web.AbortController abort = web.AbortController();
  final Completer<void> cancelled = Completer<void>();
  web.ReadableStream? body;
  web.ReadableStreamDefaultReader? reader;
  StreamController<Uint8List>? controller;
  StreamIterator<Uint8List>? upload;
  DioException? error;
  bool stopped = false;
  bool reading = false;

  Stream<Uint8List> stream() {
    controller = StreamController<Uint8List>(
      sync: true,
      onListen: () {
        if (!stopped && body != null) {
          reader = web.ReadableStreamDefaultReader(body!);
        }
        unawaited(pump());
      },
      onResume: () => unawaited(pump()),
      onCancel: () => cancel(notify: false),
    );
    return controller!.stream;
  }

  Future<void> pump() async {
    if (reading || stopped || controller!.isPaused) return;
    reading = true;
    try {
      if (reader == null) {
        finish();
        return;
      }
      while (!stopped && !controller!.isPaused) {
        final chunk = await reader!.read().toDart;
        if (stopped) return;
        if (chunk.done) {
          reader!.releaseLock();
          reader = null;
          finish();
          return;
        }
        controller!.add((chunk.value! as JSUint8Array).toDart);
      }
    } catch (failure, stack) {
      if (!stopped) {
        controller!.addError(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: failure,
          ),
          stack,
        );
        await cancel(notify: false);
      }
    } finally {
      reading = false;
    }
  }

  void finish() {
    stopped = true;
    onFinished();
    unawaited(controller!.close());
  }

  Future<void> cancel({bool notify = true}) async {
    if (stopped) return;
    stopped = true;
    error = DioException(
      requestOptions: options,
      type: DioExceptionType.cancel,
      message: 'Browser request cancelled.',
    );
    abort.abort();
    if (!cancelled.isCompleted) cancelled.complete();
    onFinished();
    final uploadCancellation = upload?.cancel();
    Future<JSAny?>? bodyCancellation;
    try {
      bodyCancellation = reader != null
          ? reader!.cancel().toDart
          : body?.cancel().toDart;
    } catch (_) {
      // An aborted network stream may already have rejected its reader.
    }
    if (notify && controller != null && !controller!.isClosed) {
      controller!.addError(error!);
    }
    if (controller != null && !controller!.isClosed) {
      unawaited(controller!.close());
    }
    try {
      await bodyCancellation;
      reader?.releaseLock();
      reader = null;
      await uploadCancellation;
    } catch (_) {
      // An aborted network stream may already have rejected its reader.
    }
  }
}
