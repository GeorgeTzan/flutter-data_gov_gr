import '../core/cancellation.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/datastore/datastore_query.dart';
import '../models/shared/source_provenance.dart';
import '../models/telecom/internet_traffic.dart';
import 'catalog_service.dart';
import 'datastore_service.dart';
import 'typed_source.dart';

/// Reads the audited internet traffic source without deriving units or totals.
final class TelecomService {
  /// Composes catalog metadata and the selected source's DataStore service.
  TelecomService(this._catalog, this._datastore);
  final CatalogService _catalog;
  final DataStoreService _datastore;

  /// Streams source averages and maxima from `internet_traffic`.
  ///
  /// [query] is passed to DataStore unchanged; filtering is server-side only.
  /// Source row positions reflect the requested traversal offset and order.
  Stream<InternetTraffic> internetTraffic({
    String resourceId = '14560622-570b-479a-a05f-659afc3d92d8',
    DataStoreQuery? query,
    CancellationSignal? cancellation,
  }) => cancellableSource((signal) async* {
    final entry = await _catalog.getEntry(
      'internet_traffic',
      cancellation: signal,
    );
    final resource = selectedResource(entry, resourceId);
    if (resource.datastoreActive == false) {
      throw UnsupportedResourceException(
        'Selected traffic resource has no active DataStore.',
      );
    }
    final sourceUrl = resource.url;
    if (sourceUrl == null || sourceUrl.trim().isEmpty) {
      throw UnsupportedResourceException(
        'Selected traffic resource has no published source URL.',
      );
    }
    final selectedQuery = query ?? DataStoreQuery();
    await for (final page in _datastore.pages(
      resource.id,
      selectedQuery,
      cancellation: signal,
    )) {
      if (!page.fields.any((field) => field['id'] == 'date')) {
        throw DecodeException(
          'Traffic source is missing the required date column.',
          details: {'field': 'date'},
        );
      }
      final provenance = SourceProvenance(
        entryId: entry.id,
        resourceId: resource.id,
        sourceUrl: sourceUrl,
        publishedModified: resource.modified,
        retrievedAt: DateTime.now().toUtc(),
      );
      for (var index = 0; index < page.records.length; index++) {
        signal.throwIfCancelled();
        yield InternetTraffic.fromSourceRecord(
          page.records[index],
          provenance: sourceRow(provenance, page.offset + index + 1),
        );
      }
    }
  }, cancellation);
}
