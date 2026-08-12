import '../../core/raw_json.dart';
import 'catalog_entry.dart';

/// One catalog response with source counts and unmodified facet buckets.
final class CatalogPage {
  /// Copies entries and facets and validates page coordinates.
  CatalogPage({
    required List<CatalogEntry> entries,
    required this.offset,
    required this.requestedPageSize,
    this.effectivePageSize,
    required this.total,
    JsonObject rawFacets = const {},
  }) : entries = List.unmodifiable(entries),
       rawFacets = freezeJson(rawFacets) {
    if (offset < 0 ||
        requestedPageSize <= 0 ||
        total < 0 ||
        (effectivePageSize != null && effectivePageSize! < 0)) {
      throw ArgumentError('Invalid catalog page coordinates');
    }
  }

  /// All returned entries in source order.
  final List<CatalogEntry> entries;

  /// The response offset.
  final int offset;

  /// The page size requested by the caller.
  final int requestedPageSize;

  /// The effective server page size, only when observable.
  final int? effectivePageSize;

  /// The total reported for this response.
  final int total;

  /// Raw facet buckets, including serialized combination keys.
  final JsonObject rawFacets;
}
