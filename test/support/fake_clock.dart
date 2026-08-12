import 'dart:async';

import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';

/// A logical clock whose methods can be injected into transport tests.
final class FakeClock {
  /// Starts at [initialTime], with a fixed retry jitter sample.
  FakeClock(DateTime initialTime, {this.jitterValue = 0.5})
    : _now = initialTime;

  DateTime _now;
  final _waiters = <_Waiter>[];

  /// The deterministic sample returned by [jitter].
  final double jitterValue;

  /// The current logical time.
  DateTime now() => _now;

  /// A fixed jitter sample for reproducible retry calculations.
  double jitter() => jitterValue;

  /// The number of waits that are still pending.
  int get pendingWaitCount => _waiters.length;

  /// Waits for logical time or rejects when [cancellation] is cancelled.
  Future<void> wait(Duration duration, CancellationSignal? cancellation) async {
    cancellation?.throwIfCancelled();
    if (duration <= Duration.zero) {
      return;
    }
    final waiter = _Waiter(_now.add(duration));
    _waiters.add(waiter);
    final detach = cancellation?.onCancel(() {
      if (_waiters.remove(waiter)) {
        waiter.done.completeError(
          CancelledException(cancellation.reason ?? 'Operation cancelled.'),
        );
      }
    });
    try {
      await waiter.done.future;
    } finally {
      detach?.call();
      _waiters.remove(waiter);
    }
  }

  /// Advances time, completing all waits whose deadlines have been reached.
  void advance(Duration duration) {
    if (duration.isNegative) {
      throw ArgumentError.value(duration, 'duration', 'Cannot reverse time.');
    }
    _now = _now.add(duration);
    final ready = _waiters.where((waiter) => !waiter.at.isAfter(_now)).toList();
    for (final waiter in ready) {
      _waiters.remove(waiter);
      waiter.done.complete();
    }
  }
}

final class _Waiter {
  _Waiter(this.at);

  final DateTime at;
  final done = Completer<void>();
}
