import 'package:dio/dio.dart';
import '../exceptions/data_gov_exception.dart';

/// An interceptor that maps [DioException]s to custom [DataGovException]s.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapToDataGovException(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
      message: exception.message,
    ));
  }

  DataGovException _mapToDataGovException(DioException err) {
    if (err.response != null) {
      final statusCode = err.response!.statusCode;

      switch (statusCode) {
        case 401:
          return UnauthorizedException(err);
        case 429:
          return RateLimitException(err);
        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException(
            'Server Error ($statusCode): ${err.response?.statusMessage ?? "Internal Server Error"}',
            err,
          );
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timed out.', err);
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection.', err);
      case DioExceptionType.cancel:
        return UnknownException('Request was cancelled.', err);
      default:
        return UnknownException(
          err.message ?? 'An unexpected error occurred.',
          err,
        );
    }
  }
}
