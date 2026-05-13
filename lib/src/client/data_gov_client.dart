import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:rxdart/subjects.dart';

import '../interceptors/error_interceptor.dart';
import '../interceptors/rate_limit_interceptor.dart';
import '../models/shared/rate_limit_status.dart';

/// The core client for interacting with the data.gov.gr API.
///
/// This client handles authentication, rate-limiting, and error mapping.
class DataGovClient {
  static const String _baseUrl = 'https://data.gov.gr/api/v1/query/';
  static const String _userAgent = 'data_gov_gr_sdk_dart/1.0.0';

  final Dio _dio;
  final BehaviorSubject<RateLimitStatus> _rateLimitController =
      BehaviorSubject<RateLimitStatus>.seeded(RateLimitStatus.initial());

  /// Creates a new instance of [DataGovClient].
  ///
  /// [apiKey] is the API token provided by data.gov.gr.
  /// [enableLogging] toggles the [LogInterceptor] for debugging.
  /// [interceptors] allows adding custom Dio interceptors.
  DataGovClient({
    required String apiKey,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
  }) : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {
            'Authorization': 'Token $apiKey',
            'User-Agent': _userAgent,
          },
        )) {
    // Add built-in interceptors
    _dio.interceptors.addAll([
      ErrorInterceptor(),
      RateLimitInterceptor(_rateLimitController),
      RetryInterceptor(
        dio: _dio,
        logPrint: enableLogging ? print : null,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 5),
        ],
      ),
    ]);

    // Optional logging
    if (enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    // Custom interceptors
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  /// The [Dio] instance used for network requests.
  Dio get dio => _dio;

  /// A stream of the current rate limit status.
  Stream<RateLimitStatus> get rateLimitStatus => _rateLimitController.stream;

  /// Closes the client and its reactive streams.
  void dispose() {
    _rateLimitController.close();
    _dio.close();
  }
}
