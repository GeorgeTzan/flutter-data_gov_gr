import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:rxdart/subjects.dart';

import '../interceptors/ckan_compatibility_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/rate_limit_interceptor.dart';
import '../models/shared/rate_limit_status.dart';
import '../services/business_service.dart';
import '../services/discovery_service.dart';
import '../services/education_service.dart';
import '../services/environment_service.dart';
import '../services/fuel_service.dart';
import '../services/generic_service.dart';
import '../services/health_service.dart';
import '../services/justice_service.dart';
import '../services/procurement_service.dart';
import '../services/society_service.dart';
import '../services/technology_service.dart';
import '../services/telecom_service.dart';
import '../services/transport_service.dart';

/// The main client for interacting with the Greek Government Open Data API (data.gov.gr).
///
/// It provides access to individual type-safe services (e.g. [fuel], [health]) as well
/// as a [generic] service for querying any endpoint dynamically.
class DataGovClient {
  static const String _baseUrl = 'https://data.gov.gr/api/3/action/';
  static const String _userAgent = 'data_gov_gr_sdk_dart/1.0.0';

  final Dio _dio;
  final BehaviorSubject<RateLimitStatus> _rateLimitController =
      BehaviorSubject<RateLimitStatus>.seeded(RateLimitStatus.initial());

  /// Fuel prices and station information.
  late final FuelService fuel;

  /// Health-related statistics (e.g. vaccinations).
  late final HealthService health;

  /// Telecom data and GR-IX internet traffic.
  late final TelecomService telecom;

  /// Environment-related metrics (e.g. forest fire data).
  late final EnvironmentService environment;

  /// Programmatic metadata discovery of datasets, topics, and providers.
  late final DiscoveryService discovery;

  /// Generic client query service for dynamic and custom datasets.
  late final GenericService generic;

  /// Procurement data (KIMDIS decisions).
  late final ProcurementService procurement;

  /// Business, economy, debt, budget, and revenue data.
  late final BusinessService business;

  /// Crime and road safety statistics.
  late final JusticeService justice;

  /// University and vocational training metrics.
  late final EducationService education;

  /// Labor market and employment metrics.
  late final SocietyService society;

  /// Digital adoption and technology statistics.
  late final TechnologyService technology;

  /// Public transport and airport traffic metrics.
  late final TransportService transport;

  /// Creates a new [DataGovClient] instance.
  ///
  /// Requires an [apiKey] for authentication. Set [enableLogging] to true
  /// to log request/response details to stdout.
  DataGovClient({
    required String apiKey,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
  }) : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Authorization': apiKey,
            'X-CKAN-API-Key': apiKey,
            'User-Agent': _userAgent,
          },
        )) {
    fuel = FuelService(this);
    health = HealthService(this);
    telecom = TelecomService(this);
    environment = EnvironmentService(this);
    discovery = DiscoveryService(this);
    generic = GenericService(this);
    procurement = ProcurementService(this);
    business = BusinessService(this);
    justice = JusticeService(this);
    education = EducationService(this);
    society = SocietyService(this);
    technology = TechnologyService(this);
    transport = TransportService(this);

    _dio.interceptors.addAll([
      CkanCompatibilityInterceptor(),
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

  /// The underlying [Dio] HTTP client instance.
  Dio get dio => _dio;

  /// A stream that emits updates on the current rate-limit usage (remaining requests, resets, etc.).
  Stream<RateLimitStatus> get rateLimitStatus => _rateLimitController.stream;

  /// Closes the HTTP client and releases any active resources.
  void dispose() {
    _rateLimitController.close();
    _dio.close();
  }
}
