import '../core/cancellation.dart';
import '../core/cancellable_source.dart';
import '../core/raw_json.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/catalog/catalog_entry.dart';
import '../models/catalog/resource_metadata.dart';
import '../models/resources/csv_options.dart';
import '../models/shared/source_provenance.dart';
import '../parsers/csv_reader.dart';
import 'resource_service.dart';

export '../core/cancellable_source.dart' show cancellableSource;

/// Resolves the explicitly selected member of an audited source entry.
ResourceMetadata selectedResource(CatalogEntry entry, String resourceId) {
  for (final resource in entry.resources) {
    if (resource.id == resourceId && resourceId.trim().isNotEmpty) {
      return resource;
    }
  }
  throw UnsupportedResourceException(
    'Selected resource does not belong to the audited entry.',
    details: {'entryId': entry.id, 'resourceId': resourceId},
  );
}

/// Copies source provenance with a one-based physical source record position.
SourceProvenance sourceRow(SourceProvenance source, int row) =>
    SourceProvenance(
      entryId: source.entryId,
      resourceId: source.resourceId,
      sourceUrl: source.sourceUrl,
      publishedModified: source.publishedModified,
      retrievedAt: source.retrievedAt,
      sourceRow: row,
    );

/// Composes metadata and bounded CSV decoding with subscription cancellation.
Stream<T> typedCsv<T>({
  required Future<CatalogEntry> Function(CancellationSignal) entry,
  required ResourceService resources,
  required String resourceId,
  required CsvOptions options,
  required List<String> requiredHeaders,
  required T Function(JsonObject, SourceProvenance) decode,
  CancellationSignal? cancellation,
}) => cancellableSource((signal) async* {
  final selectedEntry = await entry(signal);
  signal.throwIfCancelled();
  final resource = selectedResource(selectedEntry, resourceId);
  final format = resource.format?.trim().toLowerCase();
  if (format != null &&
      format.isNotEmpty &&
      !const {'csv', 'text/csv', 'application/csv'}.contains(format)) {
    throw UnsupportedFormatException('Selected typed helper requires CSV.');
  }
  final download = await resources.download(
    resource,
    options: options.download,
    cancellation: signal,
  );
  final provenance = SourceProvenance(
    entryId: selectedEntry.id,
    resourceId: resource.id,
    sourceUrl: download.provenance.sourceUrl,
    publishedModified: resource.modified,
    retrievedAt: download.provenance.retrievedAt,
  );
  var row = 1;
  await for (final record in const CsvReader().rows(
    download.bytes,
    options,
    requiredHeaders: requiredHeaders,
  )) {
    signal.throwIfCancelled();
    yield decode(record, sourceRow(provenance, ++row));
  }
}, cancellation);
