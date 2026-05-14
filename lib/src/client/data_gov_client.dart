import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:rxdart/subjects.dart';

import '../interceptors/error_interceptor.dart';
import '../interceptors/rate_limit_interceptor.dart';
import '../models/shared/rate_limit_status.dart';
import '../services/discovery_service.dart';
import '../services/environment_service.dart';
import '../services/fuel_service.dart';
import '../services/generic_service.dart';
import '../services/health_service.dart';
import '../services/telecom_service.dart';

class DataGovClient {
  static const String _baseUrl = 'https://data.gov.gr/api/v1/query/';
  static const String _userAgent = 'data_gov_gr_sdk_dart/1.0.0';

  final Dio _dio;
  final BehaviorSubject<RateLimitStatus> _rateLimitController =
      BehaviorSubject<RateLimitStatus>.seeded(RateLimitStatus.initial());

  late final FuelService fuel;
  late final HealthService health;
  late final TelecomService telecom;
  late final EnvironmentService environment;
  late final DiscoveryService discovery;
  late final GenericService generic;

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
    fuel = FuelService(this);
    health = HealthService(this);
    telecom = TelecomService(this);
    environment = EnvironmentService(this);
    discovery = DiscoveryService(this);
    generic = GenericService(this);

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

    if (enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  Dio get dio => _dio;

  Stream<RateLimitStatus> get rateLimitStatus => _rateLimitController.stream;

  void dispose() {
    _rateLimitController.close();
    _dio.close();
  }
}
