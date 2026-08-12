import '../core/cancellation.dart';
import '../models/health/vaccination_data.dart';
import '../models/resources/csv_options.dart';
import 'catalog_service.dart';
import 'resource_service.dart';
import 'typed_source.dart';

/// Reads the audited vaccination CSV without filling absent source values.
final class HealthService {
  /// Composes catalog metadata and bounded resource downloads.
  HealthService(this._catalog, this._resources);
  final CatalogService _catalog;
  final ResourceService _resources;

  /// Streams the thirteen audited columns of `mdg_emvolio`.
  ///
  /// Required identity/date headers are checked even for a header-only file.
  /// CSV source row positions include the header as row one.
  Stream<VaccinationData> vaccinations({
    String resourceId = 'd0c5e369-461d-4110-8930-f4b656c119d5',
    CsvOptions options = CsvOptions.defaults,
    CancellationSignal? cancellation,
  }) => typedCsv(
    entry: (signal) => _catalog.getEntry('mdg_emvolio', cancellation: signal),
    resources: _resources,
    resourceId: resourceId,
    options: options,
    requiredHeaders: const ['area', 'areaid', 'referencedate'],
    decode: (record, provenance) =>
        VaccinationData.fromSourceRecord(record, provenance: provenance),
    cancellation: cancellation,
  );
}
