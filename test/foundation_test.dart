import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late ErrorInterceptor interceptor;
  late MockErrorInterceptorHandler mockHandler;

  setUp(() {
    interceptor = ErrorInterceptor();
    mockHandler = MockErrorInterceptorHandler();
    registerFallbackValue(DioException(requestOptions: RequestOptions()));
  });

  group('ErrorInterceptor Mapping', () {
    test('maps 401 to UnauthorizedException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 401,
        ),
      );

      interceptor.onError(dioError, mockHandler);

      final captured = verify(() => mockHandler.next(captureAny()))
          .captured
          .first as DioException;
      expect(captured.error, isA<UnauthorizedException>());
    });

    test('maps 429 to RateLimitException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 429,
        ),
      );

      interceptor.onError(dioError, mockHandler);

      final captured = verify(() => mockHandler.next(captureAny()))
          .captured
          .first as DioException;
      expect(captured.error, isA<RateLimitException>());
    });

    test('maps 500 to ServerException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
        ),
      );

      interceptor.onError(dioError, mockHandler);

      final captured = verify(() => mockHandler.next(captureAny()))
          .captured
          .first as DioException;
      expect(captured.error, isA<ServerException>());
    });

    test('maps connection timeout to NetworkException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionTimeout,
      );

      interceptor.onError(dioError, mockHandler);

      final captured = verify(() => mockHandler.next(captureAny()))
          .captured
          .first as DioException;
      expect(captured.error, isA<NetworkException>());
      expect(
          (captured.error as NetworkException).message, contains('timed out'));
    });
  });
}
