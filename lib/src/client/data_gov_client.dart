import 'package:dio/dio.dart';

import '../core/ckan_executor.dart';
import '../core/http_transport.dart';
import '../core/metadata_cache.dart';
import '../models/shared/rate_limit_status.dart';
import '../services/catalog_service.dart';
import '../services/datastore_service.dart';
import '../services/resource_service.dart';
import '../services/telecom_service.dart';
import '../services/health_service.dart';
import '../services/environment_service.dart';
import 'data_gov_config.dart';

/// Read-only v2 client for one selected CKAN source.
///
/// Anonymous reads use [DataGovConfig]'s defaults. All services share one
/// HTTP pipeline; successful catalog metadata is retained in a client-local
/// cache. Version 2 replaces domain routing, implicit mocks, mutable Dio access,
/// and arbitrary interceptors with explicit catalog, DataStore, and file APIs.
final class DataGovClient {
  /// Creates a client, optionally using a caller-supplied HTTP [adapter].
  ///
  /// Injected adapters remain caller-owned unless
  /// [DataGovConfig.disposeInjectedAdapter] is enabled. A default platform
  /// adapter is owned by this client. Operations accept cancellation signals;
  /// [close] also cancels all active requests and download streams.
  DataGovClient({DataGovConfig? config, HttpClientAdapter? adapter}) {
    final selectedConfig = config ?? DataGovConfig();
    _transport = HttpTransport(selectedConfig, adapter: adapter);
    final executor = CkanExecutor(_transport, selectedConfig.actionBaseUrl);
    _cache = MetadataCache(selectedConfig.metadataCache);
    catalog = CatalogService(executor, _cache);
    datastore = DataStoreService(executor);
    resources = ResourceService(_transport);
    telecom = TelecomService(catalog, datastore);
    health = HealthService(catalog, resources);
    environment = EnvironmentService(catalog, resources);
  }

  late final HttpTransport _transport;
  late final MetadataCache _cache;

  /// Discovery and published metadata for the selected catalog.
  late final CatalogService catalog;

  /// Resource-specific server-side table queries and lazy traversal.
  late final DataStoreService datastore;

  /// Bounded source downloads and explicit CSV/JSON readers.
  late final ResourceService resources;

  /// Verified internet traffic averages and maxima from the selected source.
  late final TelecomService telecom;

  /// Verified vaccination source columns with nullable optional cells.
  late final HealthService health;

  /// Verified forest-fire rows from an explicitly selected source resource.
  late final EnvironmentService environment;

  /// Latest published quota, initially unavailable.
  RateLimitStatus get currentRateLimitStatus =>
      _transport.currentRateLimitStatus;

  /// Broadcast quota updates, replaying the current value to each listener.
  Stream<RateLimitStatus> get rateLimitStatus => _transport.rateLimitStatus;

  /// Cancels active work, clears metadata, and closes owned resources once.
  ///
  /// Repeated calls are safe. All service operations reject work after close,
  /// including reads that could otherwise be served from metadata cache.
  void close() {
    _transport.close();
    _cache.clear();
  }
}
