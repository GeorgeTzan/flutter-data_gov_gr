import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// One deterministic request outcome supplied by a test.
typedef ScriptedStep = Future<ResponseBody> Function(RequestOptions options);

/// A FIFO HTTP adapter that rejects unexpected requests instead of inventing data.
final class ScriptedAdapter implements HttpClientAdapter {
  /// Copies [steps] so each request consumes exactly one scripted outcome.
  ScriptedAdapter(Iterable<ScriptedStep> steps) : _steps = Queue.of(steps);

  final Queue<ScriptedStep> _steps;
  final _requests = <RequestOptions>[];
  bool _closed = false;
  int _closeCount = 0;

  /// Requests observed by this adapter, including unexpected requests.
  List<RequestOptions> get requests => List.unmodifiable(_requests);

  /// The number of explicit close calls received.
  int get closeCount => _closeCount;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_closed) {
      throw StateError('ScriptedAdapter is closed.');
    }
    _requests.add(options);
    if (options.cancelToken?.isCancelled ?? false) {
      throw options.cancelToken!.cancelError!;
    }
    if (_steps.isEmpty) {
      throw StateError('ScriptedAdapter script exhausted.');
    }
    final step = _steps.removeFirst();
    final response = Future<ResponseBody>.sync(() => step(options));
    if (cancelFuture == null) {
      return response;
    }
    return Future.any([
      response,
      cancelFuture.then<ResponseBody>((_) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          message: 'Scripted request cancelled.',
        );
      }),
    ]);
  }

  @override
  void close({bool force = false}) {
    _closeCount++;
    _closed = true;
  }
}
