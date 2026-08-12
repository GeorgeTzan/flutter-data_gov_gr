import '../core/cancellation.dart';
import '../models/environment/forest_fire.dart';
import '../models/resources/csv_options.dart';
import 'catalog_service.dart';
import 'resource_service.dart';
import 'typed_source.dart';

/// Reads a caller-selected resource of the audited forest-fire entry.
final class EnvironmentService {
  /// Composes catalog metadata and bounded resource downloads.
  EnvironmentService(this._catalog, this._resources);
  final CatalogService _catalog;
  final ResourceService _resources;

  /// Streams the thirty audited source columns of `mcp_forest_fires`.
  ///
  /// [resourceId] must belong to that entry; no resource is chosen implicitly.
  /// The provenance row is a source position, not an official incident ID.
  /// CSV source row positions include the header as row one.
  Stream<ForestFire> forestFires({
    required String resourceId,
    CsvOptions options = CsvOptions.defaults,
    CancellationSignal? cancellation,
  }) => typedCsv(
    entry: (signal) =>
        _catalog.getEntry('mcp_forest_fires', cancellation: signal),
    resources: _resources,
    resourceId: resourceId,
    options: options,
    requiredHeaders: const ['start_time'],
    decode: (record, provenance) =>
        ForestFire.fromSourceRecord(record, provenance: provenance),
    cancellation: cancellation,
  );
}
