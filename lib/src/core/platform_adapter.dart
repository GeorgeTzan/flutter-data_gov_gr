import 'package:dio/dio.dart';

import 'platform_adapter_stub.dart'
    if (dart.library.js_interop) 'fetch_adapter_web.dart'
    as platform;

/// Creates the transport adapter appropriate to the current Dart platform.
HttpClientAdapter createPlatformAdapter() => platform.createPlatformAdapter();
