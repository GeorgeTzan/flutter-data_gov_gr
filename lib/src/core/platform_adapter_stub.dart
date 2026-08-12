import 'package:dio/dio.dart';

/// Uses Dio's standard adapter on native platforms.
HttpClientAdapter createPlatformAdapter() => HttpClientAdapter();
