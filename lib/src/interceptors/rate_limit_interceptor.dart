import 'package:dio/dio.dart';
import 'package:rxdart/subjects.dart';
import '../models/shared/rate_limit_status.dart';

class RateLimitInterceptor extends Interceptor {
  final BehaviorSubject<RateLimitStatus> _statusController;

  RateLimitInterceptor(this._statusController);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final limit =
        int.tryParse(response.headers.value('X-RateLimit-Limit') ?? '');
    final remaining =
        int.tryParse(response.headers.value('X-RateLimit-Remaining') ?? '');
    final reset =
        int.tryParse(response.headers.value('X-RateLimit-Reset') ?? '');

    if (limit != null && remaining != null && reset != null) {
      final status = RateLimitStatus(
        limit: limit,
        remaining: remaining,
        resetTime: DateTime.fromMillisecondsSinceEpoch(reset * 1000),
      );
      _statusController.add(status);
    }

    handler.next(response);
  }
}
