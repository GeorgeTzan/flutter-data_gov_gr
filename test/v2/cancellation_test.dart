import 'dart:async';

import 'package:data_gov_gr/src/core/cancellation.dart';
import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/testing/scripted_adapter.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import '../support/fake_clock.dart';

void main() {
  test('cancel_is_idempotent_and_observable', () async {
    final controller = CancellationController();
    expect(controller.signal.isCancelled, isFalse);
    expect(controller.signal.reason, isNull);
    controller.signal.throwIfCancelled();
    final observed = controller.signal.whenCancelled;
    controller.cancel('replaced');
    controller.cancel('ignored');
    await observed;
    expect(controller.signal.isCancelled, isTrue);
    expect(controller.signal.reason, 'replaced');
    expect(
      controller.signal.throwIfCancelled,
      throwsA(isA<CancelledException>()),
    );
  });

  test('cancel_without_reason_preserves_first_cancellation', () async {
    final controller = CancellationController()..cancel();
    controller.cancel('too late');
    await controller.signal.whenCancelled;
    expect(controller.signal.reason, isNull);
    expect(
      controller.signal.throwIfCancelled,
      throwsA(isA<CancelledException>()),
    );
  });

  test('fake_clock_advances_waits_without_sleeping', () async {
    final clock = FakeClock(DateTime.utc(2026), jitterValue: 0.25);
    var finished = false;
    final waiting = clock.wait(const Duration(seconds: 2), null).then((_) {
      finished = true;
    });
    clock.advance(const Duration(seconds: 1));
    await Future<void>.value();
    expect(finished, isFalse);
    clock.advance(const Duration(seconds: 1));
    await waiting;
    expect(clock.now(), DateTime.utc(2026, 1, 1, 0, 0, 2));
    expect(clock.jitter(), 0.25);
    expect(clock.pendingWaitCount, 0);
  });

  test('fake_clock_wait_observes_cancellation_and_removes_waiter', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final controller = CancellationController();
    final waiting = clock.wait(const Duration(days: 1), controller.signal);
    final rejected = expectLater(waiting, throwsA(isA<CancelledException>()));
    controller.cancel();
    await rejected;
    expect(clock.pendingWaitCount, 0);
    expect(clock.now(), DateTime.utc(2026));
    await expectLater(
      clock.wait(Duration.zero, controller.signal),
      throwsA(isA<CancelledException>()),
    );
  });

  test('cancellation_listeners_can_detach_completed_work', () {
    final controller = CancellationController();
    var completedCalls = 0;
    var pendingCalls = 0;
    final detach = controller.signal.onCancel(() => completedCalls++);
    controller.signal.onCancel(() => pendingCalls++);
    detach();
    detach();
    controller.cancel();
    controller.cancel();
    expect(completedCalls, 0);
    expect(pendingCalls, 1);
    controller.signal.onCancel(() => pendingCalls++);
    expect(pendingCalls, 2);
  });

  test('cancellation_listener_errors_stay_in_the_registration_zone', () {
    final controller = CancellationController();
    final errors = <Object>[];
    runZonedGuarded(() {
      controller.signal.onCancel(() => throw StateError('callback failed'));
    }, (error, stack) => errors.add(error));
    var notified = false;
    controller.signal.onCancel(() => notified = true);
    controller.cancel();
    expect(notified, isTrue);
    expect(errors, [isA<StateError>()]);
  });

  test('already_cancelled_requests_do_not_consume_scripts', () async {
    final token = CancelToken()..cancel('pre-cancelled');
    final adapter = ScriptedAdapter([
      (_) async => ResponseBody.fromString('available', 201),
    ]);
    await expectLater(
      adapter.fetch(
        RequestOptions(path: '/cancelled', cancelToken: token),
        null,
        token.whenCancel,
      ),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    expect(
      (await adapter.fetch(
        RequestOptions(path: '/next'),
        null,
        null,
      )).statusCode,
      201,
    );
  });

  test('script_exhaustion_cannot_fabricate_success', () async {
    final adapter = ScriptedAdapter([
      (request) async => ResponseBody.fromString('first', 200),
    ]);
    final request = RequestOptions(path: '/first');
    final response = await adapter.fetch(request, null, null);
    expect(response.statusCode, 200);
    await expectLater(
      adapter.fetch(RequestOptions(path: '/unexpected'), null, null),
      throwsA(isA<StateError>()),
    );
    expect(adapter.requests.map((request) => request.path), [
      '/first',
      '/unexpected',
    ]);
    adapter.close();
    adapter.close(force: true);
    expect(adapter.closeCount, 2);
    await expectLater(
      adapter.fetch(request, null, null),
      throwsA(isA<StateError>()),
    );
  });

  test('scripted_adapter_cancels_only_the_selected_request', () async {
    final blocked = Completer<ResponseBody>();
    final cancellation = Completer<void>();
    final adapter = ScriptedAdapter([
      (_) => blocked.future,
      (_) async => ResponseBody.fromString('second', 200),
    ]);
    final rejected = expectLater(
      adapter.fetch(
        RequestOptions(path: '/blocked'),
        null,
        cancellation.future,
      ),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    cancellation.complete();
    await rejected;
    expect(
      (await adapter.fetch(
        RequestOptions(path: '/second'),
        null,
        null,
      )).statusCode,
      200,
    );
    blocked.completeError(StateError('late script error'));
    await Future<void>.delayed(Duration.zero);
  });
}
