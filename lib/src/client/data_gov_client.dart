import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:rxdart/subjects.dart';

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

class DataGovClient {
  static const String _baseUrl = 'https://old.data.gov.gr/api/v1/';
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
  late final ProcurementService procurement;
  late final BusinessService business;
  late final JusticeService justice;
  late final EducationService education;
  late final SocietyService society;
  late final TechnologyService technology;
  late final TransportService transport;

  DataGovClient({
    required String apiKey,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
  }) : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
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
    procurement = ProcurementService(this);
    business = BusinessService(this);
    justice = JusticeService(this);
    education = EducationService(this);
    society = SocietyService(this);
    technology = TechnologyService(this);
    transport = TransportService(this);

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
