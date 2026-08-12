import 'dart:async';

import '../exceptions/data_gov_exception.dart';
import 'cancellation.dart';

/// Binds subscription cancellation to pending source requests and file streams.
Stream<T> cancellableSource<T>(
  Stream<T> Function(CancellationSignal) source,
  CancellationSignal? cancellation,
) {
  late StreamController<T> controller;
  StreamSubscription<T>? subscription;
  final transfer = CancellationController();
  void Function()? detach;
  controller = StreamController<T>(
    sync: true,
    onListen: () {
      detach = cancellation?.onCancel(
        () => transfer.cancel(cancellation.reason),
      );
      subscription = source(transfer.signal).listen(
        controller.add,
        onError: controller.addError,
        onDone: () {
          detach?.call();
          unawaited(controller.close());
        },
      );
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () async {
      detach?.call();
      transfer.cancel('Source subscription cancelled.');
      try {
        await subscription?.cancel();
      } on CancelledException {
        // async* cancellation can return the error of its pending request.
      }
    },
  );
  return controller.stream;
}
