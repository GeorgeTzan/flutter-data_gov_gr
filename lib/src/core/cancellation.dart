import 'dart:async';

import '../exceptions/data_gov_exception.dart';

/// Owns a cancellation signal shared by related operations.
final class CancellationController {
  /// Creates a controller with an initially active signal.
  CancellationController();

  /// The read-only cancellation state supplied to operations.
  final CancellationSignal signal = CancellationSignal._();

  /// Cancels once, retaining the first [reason], including a null reason.
  void cancel([String? reason]) => signal._cancel(reason);
}

/// Observable cancellation state without authority to cancel an operation.
final class CancellationSignal {
  CancellationSignal._();

  final _cancelled = Completer<void>();
  final _listeners = <void Function()>{};
  String? _reason;

  /// Whether cancellation has been requested.
  bool get isCancelled => _cancelled.isCompleted;

  /// The first cancellation reason, if one was supplied.
  String? get reason => _reason;

  /// Completes when cancellation is requested; never completes with an error.
  Future<void> get whenCancelled => _cancelled.future;

  /// Rejects further work after cancellation.
  void throwIfCancelled() {
    if (isCancelled) {
      throw CancelledException(reason ?? 'Operation cancelled.');
    }
  }

  /// Registers a callback and returns an idempotent unsubscribe function.
  ///
  /// Already cancelled signals invoke [callback] immediately. Callback errors
  /// are delivered to the registration zone without preventing other callbacks.
  void Function() onCancel(void Function() callback) {
    if (isCancelled) {
      Zone.current.runGuarded(callback);
      return () {};
    }
    final zone = Zone.current;
    void listener() => zone.runGuarded(callback);
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  void _cancel(String? reason) {
    if (isCancelled) {
      return;
    }
    _reason = reason;
    _cancelled.complete();
    final listeners = _listeners.toList();
    _listeners.clear();
    for (final listener in listeners) {
      listener();
    }
  }
}
