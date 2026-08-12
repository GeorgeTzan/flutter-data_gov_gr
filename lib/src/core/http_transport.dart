import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../client/data_gov_config.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/resources/download_options.dart';
import '../models/shared/rate_limit_status.dart';
import 'cancellation.dart';
import 'platform_adapter.dart';
import 'raw_json.dart';
import 'retry_scheduler.dart';

/// A bounded response stream and metadata from the final download response.
final class TransportDownload {
  /// Retains source metadata and the single-subscription decoded byte stream.
  TransportDownload({
    required this.finalUri,
    required this.contentType,
    required this.contentLength,
    required this.retrievedAt,
    required this.bytes,
  });

  /// Final URI exposed by the selected adapter after redirects.
  final Uri finalUri;

  /// Source Content-Type, absent when unpublished.
  final String? contentType;

  /// Published Content-Length, absent when unknown.
  final int? contentLength;

  /// Time the final response was received.
  final DateTime retrievedAt;

  /// Incremental decoded bytes, respecting cancellation, limits, and pauses.
  final Stream<Uint8List> bytes;
}

/// One client's HTTP pipeline with scoped credentials and operation lifetimes.
final class HttpTransport {
  /// Creates one Dio client, retaining caller ownership of injected adapters.
  HttpTransport(
    this.config, {
    HttpClientAdapter? adapter,
    DateTime Function()? now,
    Future<void> Function(Duration, CancellationSignal?)? wait,
    double Function()? jitter,
  }) : _now = now ?? DateTime.now,
       _wait = wait ?? _defaultWait,
       _ownsAdapter = adapter == null || config.disposeInjectedAdapter,
       _adapter = adapter ?? createPlatformAdapter() {
    _dio = Dio(
      BaseOptions(
        responseType: ResponseType.stream,
        followRedirects: false,
        validateStatus: (_) => true,
        connectTimeout: config.requestTimeout,
        sendTimeout: config.requestTimeout,
      ),
    );
    _dio.httpClientAdapter = _StreamingAdapter(_adapter);
    _scheduler = RetryScheduler(config.retry, now: _now, jitter: jitter);
  }

  /// Immutable policy for this transport.
  final DataGovConfig config;
  final DateTime Function() _now;
  final Future<void> Function(Duration, CancellationSignal?) _wait;
  final bool _ownsAdapter;
  final HttpClientAdapter _adapter;
  late final Dio _dio;
  late final RetryScheduler _scheduler;
  final Set<_Operation> _active = {};
  final _rateEvents = StreamController<RateLimitStatus>.broadcast(sync: true);
  RateLimitStatus _rate = RateLimitStatus.initial();
  bool _closed = false;

  /// Latest published quota, initially unavailable.
  RateLimitStatus get currentRateLimitStatus => _rate;

  /// Broadcast quota updates, replaying the current value on each subscription.
  Stream<RateLimitStatus> get rateLimitStatus =>
      Stream<RateLimitStatus>.multi((sink) {
        sink.add(_rate);
        final subscription = _rateEvents.stream.listen(
          sink.add,
          onError: sink.addError,
          onDone: sink.close,
        );
        sink.onCancel = subscription.cancel;
      }, isBroadcast: true);

  /// Rejects work after client disposal before validating its arguments.
  void throwIfClosed() {
    if (_closed) throw ClientClosedException('Client is closed.');
  }

  _Operation _begin(CancellationSignal? cancellation, Duration deadline) {
    throwIfClosed();
    cancellation?.throwIfCancelled();
    final operation = _Operation(_now().add(deadline), deadline, cancellation);
    _active.add(operation);
    return operation;
  }

  void _finish(_Operation operation) {
    operation.dispose();
    _active.remove(operation);
  }

  /// Reads a JSON object with a separate eight MiB decoded-byte ceiling.
  Future<JsonObject> requestJson(
    Uri uri, {
    String method = 'GET',
    JsonObject? parameters,
    CancellationSignal? cancellation,
    bool sendPortalCredentials = false,
  }) async {
    final operation = _begin(cancellation, config.retry.deadline);
    try {
      for (var attempt = 1; ; attempt++) {
        try {
          final response = await _headers(
            operation,
            uri,
            method,
            parameters,
            sendPortalCredentials,
            download: false,
          );
          final bytes = BytesBuilder(copy: false);
          final stream = _boundedStream(operation, response.body, 8388608);
          await for (final chunk in stream) {
            bytes.add(chunk);
          }
          Object? value;
          try {
            value = jsonDecode(utf8.decode(bytes.takeBytes()));
          } on FormatException catch (error) {
            throw DecodeException(
              'Invalid JSON response.',
              originalError: error,
            );
          }
          if (value is! Map<String, dynamic>) {
            throw DecodeException('Expected a JSON object.');
          }
          return freezeJson(value);
        } catch (error) {
          final failure = _convert(error, operation);
          await _retry(operation, failure, attempt);
        }
      }
    } finally {
      _finish(operation);
    }
  }

  /// Opens a download after retaining at most one bounded, nonempty chunk.
  ///
  /// Pre-byte failures retry before publishing final response metadata. The
  /// returned stream resumes lazily and cannot retry after publication.
  Future<TransportDownload> openDownload(
    Uri uri, {
    required DownloadOptions options,
    CancellationSignal? cancellation,
  }) async {
    final operation = _begin(
      cancellation,
      options.deadline ?? config.retry.deadline,
    );
    try {
      for (var attempt = 1; ; attempt++) {
        StreamIterator<Uint8List>? iterator;
        try {
          final response = await _headers(
            operation,
            uri,
            'GET',
            null,
            false,
            download: true,
          );
          final retrievedAt = _now();
          iterator = StreamIterator(
            _boundedStream(operation, response.body, options.maxBytes),
          );
          var hasChunk = await iterator.moveNext();
          while (hasChunk && iterator.current.isEmpty) {
            hasChunk = await iterator.moveNext();
          }
          operation.check(_now());
          if (!hasChunk) {
            await iterator.cancel();
            _finish(operation);
          }
          return TransportDownload(
            finalUri: response.uri,
            contentType: _header(response.body.headers, 'content-type'),
            contentLength: _nonnegative(
              _header(response.body.headers, 'content-length'),
            ),
            retrievedAt: retrievedAt,
            bytes: hasChunk
                ? _primedStream(operation, iterator, hasChunk)
                : const Stream<Uint8List>.empty(),
          );
        } catch (error) {
          await iterator?.cancel();
          await _retry(operation, _convert(error, operation), attempt);
        }
      }
    } catch (_) {
      _finish(operation);
      rethrow;
    }
  }

  Stream<Uint8List> _primedStream(
    _Operation operation,
    StreamIterator<Uint8List> iterator,
    bool hasChunk,
  ) {
    late StreamController<Uint8List> controller;
    var stopped = false;
    var pumping = false;
    var first = hasChunk;
    void done() {
      if (stopped) return;
      stopped = true;
      unawaited(iterator.cancel());
      _finish(operation);
      unawaited(controller.close());
    }

    Future<void> pump() async {
      if (pumping || stopped || controller.isPaused) return;
      pumping = true;
      try {
        operation.check(_now());
        if (!hasChunk) {
          done();
          return;
        }
        while (!stopped && !controller.isPaused) {
          if (first) {
            first = false;
          } else if (!await iterator.moveNext()) {
            done();
            return;
          }
          operation.check(_now());
          if (!stopped) controller.add(iterator.current);
        }
      } catch (error, stack) {
        if (!stopped) {
          controller.addError(_convert(error, operation), stack);
          done();
        }
      } finally {
        pumping = false;
      }
    }

    final abortBody = operation.onAbort;
    controller = StreamController<Uint8List>(
      sync: true,
      onListen: () => scheduleMicrotask(() => unawaited(pump())),
      onPause: () => operation.pauseBody?.call(),
      onResume: () {
        operation.resumeBody?.call();
        unawaited(pump());
      },
      onCancel: () async {
        stopped = true;
        operation.abort(CancelledException('Download subscription cancelled.'));
        await iterator.cancel();
        _finish(operation);
      },
    );
    operation.onAbort = () {
      abortBody?.call();
      if (!stopped) {
        controller.addError(operation.failure!);
        done();
      }
    };
    return controller.stream;
  }

  Stream<Uint8List> _boundedStream(
    _Operation operation,
    ResponseBody body,
    int? maxBytes,
  ) {
    late StreamController<Uint8List> controller;
    StreamSubscription<Uint8List>? subscription;
    Timer? idleTimer;
    var size = 0;
    var ended = false;
    void stop([Object? error, StackTrace? stack]) {
      if (ended) return;
      ended = true;
      idleTimer?.cancel();
      unawaited(subscription?.cancel());
      operation.onAbort = null;
      operation.pauseBody = null;
      operation.resumeBody = null;
      if (error != null) controller.addError(error, stack);
      unawaited(controller.close());
    }

    void watchIdle() {
      idleTimer?.cancel();
      if (!ended) {
        idleTimer = Timer(config.requestTimeout, () {
          stop(RequestTimeoutException('Response body timed out.'));
          operation.token?.cancel();
        });
      }
    }

    void pauseBody() {
      idleTimer?.cancel();
      subscription?.pause();
    }

    void resumeBody() {
      subscription?.resume();
      if (!(subscription?.isPaused ?? true)) watchIdle();
    }

    operation.onAbort = () => stop(operation.failure);
    operation.pauseBody = pauseBody;
    operation.resumeBody = resumeBody;
    controller = StreamController<Uint8List>(
      sync: true,
      onListen: () {
        if (operation.failure != null) {
          stop(operation.failure);
          return;
        }
        watchIdle();
        subscription = body.stream.listen(
          (chunk) {
            if (ended) return;
            watchIdle();
            try {
              operation.check(_now());
            } catch (error, stack) {
              stop(error, stack);
              return;
            }
            size += chunk.length;
            if (maxBytes != null && size > maxBytes) {
              operation.abort(
                ByteLimitException('Decoded response exceeds byte ceiling.'),
              );
              return;
            }
            controller.add(chunk);
          },
          onError: (Object error, StackTrace stack) =>
              stop(_convert(error, operation), stack),
          onDone: () => stop(),
        );
      },
      onPause: pauseBody,
      onResume: resumeBody,
      onCancel: () async {
        idleTimer?.cancel();
        await subscription?.cancel();
        operation.onAbort = null;
        operation.pauseBody = null;
        operation.resumeBody = null;
      },
    );
    return controller.stream;
  }

  Future<_Response> _headers(
    _Operation operation,
    Uri uri,
    String method,
    JsonObject? parameters,
    bool credentials, {
    required bool download,
  }) async {
    operation.check(_now());
    _validateUri(uri);
    final requestMethod = method.toUpperCase();
    if (!const {'GET', 'POST'}.contains(requestMethod)) {
      throw ValidationException(
        'Only read-only GET and POST requests are supported.',
      );
    }
    var current = uri;
    var sendKey = credentials && _credentialScope(uri);
    for (var redirect = 0; ; redirect++) {
      operation.check(_now());
      operation.retryAt = null;
      final token = CancelToken();
      operation.token = token;
      final headers = <String, Object?>{
        if (sendKey && config.apiKey != null) 'Authorization': config.apiKey,
      };
      final query = requestMethod == 'GET' && parameters != null
          ? parameters.map(
              (k, v) => MapEntry(
                k,
                v is String || v is num || v is bool || v == null
                    ? v?.toString()
                    : jsonEncode(v),
              ),
            )
          : null;
      Response<ResponseBody> response;
      try {
        response = await _dio
            .requestUri<ResponseBody>(
              query == null
                  ? current
                  : current.replace(
                      queryParameters: {...current.queryParameters, ...query},
                    ),
              data: requestMethod == 'POST'
                  ? jsonEncode(parameters ?? {})
                  : null,
              cancelToken: token,
              options: Options(
                method: requestMethod,
                headers: headers,
                contentType: requestMethod == 'POST'
                    ? Headers.jsonContentType
                    : null,
                responseType: ResponseType.stream,
                followRedirects:
                    download &&
                    const bool.fromEnvironment('dart.library.js_interop'),
                receiveTimeout: config.requestTimeout,
              ),
            )
            .timeout(
              config.requestTimeout,
              onTimeout: () {
                token.cancel();
                throw RequestTimeoutException('HTTP request timed out.');
              },
            );
      } catch (error) {
        throw _convert(error, operation);
      }
      final body = response.extra[_StreamingAdapter.bodyKey] as ResponseBody;
      var handedOff = false;
      var bodyConsumed = false;
      try {
        operation.check(_now());
        _observeRate(body.headers);
        final status = response.statusCode ?? 0;
        if (const {301, 302, 303, 307, 308}.contains(status)) {
          final location = _header(body.headers, 'location');
          if (redirect >= 5 || location == null) {
            throw NetworkException(
              'Redirect cannot be followed safely.',
              statusCode: status,
            );
          }
          current = current.resolve(location);
          _validateUri(current);
          sendKey = false;
          continue;
        }
        if (status < 200 || status >= 300) {
          operation.retryAt = _scheduler.retryAt(
            _header(body.headers, 'retry-after'),
          );
          bodyConsumed = true;
          final details = await _errorDetails(body, operation);
          throw _statusFailure(status, operation.retryAt, details);
        }
        final finalUrl = body.extra['dataGovFinalUrl'];
        final result = _Response(
          body,
          finalUrl is String ? Uri.parse(finalUrl) : response.realUri,
        );
        handedOff = true;
        return result;
      } finally {
        if (!handedOff && !bodyConsumed) {
          await _discardBody(body);
        }
      }
    }
  }

  Future<void> _retry(
    _Operation operation,
    DataGovException failure,
    int attempt,
  ) async {
    operation.check(_now());
    final transient =
        failure is RateLimitException ||
        failure is RequestTimeoutException ||
        failure is NetworkException &&
            (failure.statusCode == null ||
                const {
                  408,
                  425,
                  500,
                  502,
                  503,
                  504,
                }.contains(failure.statusCode));
    if (!transient || attempt >= config.retry.maxAttempts) throw failure;
    final delay = _scheduler.delay(
      attempt,
      retryAt: failure is RateLimitException
          ? failure.retryAt
          : operation.retryAt,
    );
    if (_now().add(delay).compareTo(operation.deadline) >= 0) throw failure;
    try {
      await _wait(delay, operation.cancellation.signal);
    } catch (error) {
      throw _convert(error, operation);
    }
    operation.check(_now());
  }

  Future<Object?> _errorDetails(ResponseBody body, _Operation operation) async {
    final iterator = StreamIterator(body.stream);
    final bytes = BytesBuilder(copy: false);
    Future<Object?> read() async {
      while (await iterator.moveNext()) {
        final chunk = iterator.current;
        if (bytes.length + chunk.length > 65536) return null;
        bytes.add(chunk);
      }
      final text = utf8.decode(bytes.takeBytes(), allowMalformed: true);
      if (text.isEmpty) return null;
      try {
        final value = jsonDecode(text);
        return value is Map ? value['error'] ?? value : value;
      } on FormatException {
        return text;
      }
    }

    try {
      return await Future.any([
        read(),
        operation.cancellation.signal.whenCancelled.then<Object?>((_) => null),
      ]).timeout(const Duration(milliseconds: 100), onTimeout: () => null);
    } catch (_) {
      return null;
    } finally {
      try {
        unawaited(iterator.cancel().catchError((Object _) {}));
      } catch (_) {
        // Adapter cleanup may never complete; preserve the primary failure.
      }
    }
  }

  DataGovException _statusFailure(
    int status,
    DateTime? retryAt,
    Object? details,
  ) => switch (status) {
    400 || 409 || 422 => ValidationException(
      'Request parameters were rejected.',
      statusCode: status,
      details: details,
      retryAt: retryAt,
    ),
    401 => AuthenticationException(
      'Authentication failed.',
      statusCode: status,
      details: details,
      retryAt: retryAt,
    ),
    403 => PermissionException(
      'Access denied.',
      statusCode: status,
      details: details,
      retryAt: retryAt,
    ),
    404 => NotFoundException(
      'Source was not found.',
      statusCode: status,
      details: details,
      retryAt: retryAt,
    ),
    429 => RateLimitException(
      'Source rate limit exceeded.',
      statusCode: status,
      details: details,
      retryAt: retryAt,
    ),
    _ => NetworkException(
      'HTTP request failed.',
      statusCode: status,
      details: details,
      retryAt: retryAt,
    ),
  };

  DataGovException _convert(Object error, _Operation operation) {
    if (operation.failure != null) return operation.failure!;
    if (error is DataGovException) return error;
    if (error is DioException) {
      if (const {
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      }.contains(error.type)) {
        return RequestTimeoutException(
          'HTTP request timed out.',
          originalError: error,
        );
      }
      if (error.type == DioExceptionType.cancel) {
        return CancelledException('Operation cancelled.', originalError: error);
      }
    }
    return NetworkException('HTTP transport failed.', originalError: error);
  }

  bool _credentialScope(Uri uri) {
    final base = config.actionBaseUrl;
    if (uri.scheme != base.scheme ||
        uri.host != base.host ||
        uri.port != base.port ||
        uri.userInfo.isNotEmpty) {
      return false;
    }
    final normalized = uri.normalizePath();
    if (!normalized.path.startsWith(base.path)) return false;
    final action = normalized.path.substring(base.path.length);
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(action);
  }

  void _validateUri(Uri uri) {
    if (!const {'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw ValidationException(
        'Expected an absolute HTTP(S) URL without user information.',
      );
    }
  }

  void _observeRate(Map<String, List<String>> headers) {
    final limit = _nonnegative(
      _header(headers, 'x-ratelimit-limit') ??
          _header(headers, 'ratelimit-limit'),
    );
    final remaining = _nonnegative(
      _header(headers, 'x-ratelimit-remaining') ??
          _header(headers, 'ratelimit-remaining'),
    );
    final epoch = RetryScheduler.timestampFromSeconds(
      _header(headers, 'x-ratelimit-reset'),
    );
    final relativeReset = _header(headers, 'ratelimit-reset');
    final reset =
        epoch ??
        (relativeReset == null
            ? null
            : RetryScheduler.timestampFromSeconds(
                relativeReset,
                relativeTo: _now(),
              ));
    _rate = RateLimitStatus(limit: limit, remaining: remaining, resetAt: reset);
    _rateEvents.add(_rate);
  }

  /// Cancels this client's work and disposes an owned adapter exactly once.
  void close() {
    if (_closed) return;
    _closed = true;
    for (final operation in _active.toList()) {
      operation.abort(ClientClosedException('Client is closed.'));
      _finish(operation);
    }
    if (_ownsAdapter) _dio.close(force: true);
    unawaited(_rateEvents.close());
  }

  static Future<void> _defaultWait(
    Duration duration,
    CancellationSignal? cancellation,
  ) async {
    cancellation?.throwIfCancelled();
    final completer = Completer<void>();
    final timer = Timer(duration, completer.complete);
    final detach = cancellation?.onCancel(() {
      if (!completer.isCompleted) {
        completer.completeError(CancelledException('Operation cancelled.'));
      }
    });
    try {
      await completer.future;
    } finally {
      timer.cancel();
      detach?.call();
    }
  }
}

Future<void> _discardBody(ResponseBody body) async {
  try {
    await body.stream
        .listen((_) {}, onError: (Object _, StackTrace _) {})
        .cancel();
  } catch (_) {
    // Cleanup must preserve the response's original failure.
  }
}

String? _header(Map<String, List<String>> headers, String name) {
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == name && entry.value.isNotEmpty) {
      return entry.value.first;
    }
  }
  return null;
}

int? _nonnegative(String? value) {
  final number = int.tryParse(value ?? '');
  return number != null && number >= 0 ? number : null;
}

final class _Response {
  _Response(this.body, this.uri);
  final ResponseBody body;
  final Uri uri;
}

final class _Operation {
  _Operation(this.deadline, Duration duration, CancellationSignal? external) {
    timer = Timer(
      duration,
      () => abort(RequestTimeoutException('Operation deadline exceeded.')),
    );
    detach = external?.onCancel(
      () =>
          abort(CancelledException(external.reason ?? 'Operation cancelled.')),
    );
  }
  final DateTime deadline;
  final cancellation = CancellationController();
  late final Timer timer;
  void Function()? detach;
  void Function()? onAbort;
  void Function()? pauseBody;
  void Function()? resumeBody;
  CancelToken? token;
  DataGovException? failure;
  DateTime? retryAt;
  void abort(DataGovException error) {
    if (failure != null) return;
    failure = error;
    timer.cancel();
    detach?.call();
    detach = null;
    cancellation.cancel();
    token?.cancel();
    onAbort?.call();
  }

  void check(DateTime now) {
    if (failure != null) throw failure!;
    if (!now.isBefore(deadline)) {
      abort(RequestTimeoutException('Operation deadline exceeded.'));
      throw failure!;
    }
  }

  void dispose() {
    timer.cancel();
    detach?.call();
    detach = null;
    onAbort = null;
    pauseBody = null;
    resumeBody = null;
  }
}

final class _StreamingAdapter implements HttpClientAdapter {
  _StreamingAdapter(this.delegate);
  final HttpClientAdapter delegate;
  static const bodyKey = 'dataGovOriginalResponseBody';
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = await delegate.fetch(options, requestStream, cancelFuture);
    // Dio's stream transformation eagerly listens without forwarding pauses.
    final shim = ResponseBody(
      const Stream<Uint8List>.empty(),
      body.statusCode,
      statusMessage: body.statusMessage,
      isRedirect: body.isRedirect,
      headers: body.headers,
    );
    shim.extra = {...body.extra, bodyKey: body};
    return shim;
  }

  @override
  void close({bool force = false}) => delegate.close(force: force);
}
