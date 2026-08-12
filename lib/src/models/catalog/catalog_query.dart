/// Immutable options for catalog search and traversal.
final class CatalogQuery {
  /// Creates a query with positive page size and nonnegative offset.
  CatalogQuery({
    this.text,
    List<String> filters = const [],
    List<String> facets = const [],
    this.sort = 'id asc',
    this.offset = 0,
    this.pageSize = 100,
  }) : filters = List.unmodifiable(filters),
       facets = List.unmodifiable(facets) {
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'Must be nonnegative');
    }
    if (pageSize <= 0) {
      throw ArgumentError.value(pageSize, 'pageSize', 'Must be positive');
    }
    if (sort.trim().isEmpty) {
      throw ArgumentError.value(sort, 'sort', 'Must not be empty');
    }
  }

  /// The optional full-text search expression.
  final String? text;

  /// Server-side filter expressions, retained in caller order.
  final List<String> filters;

  /// Requested facet field names.
  final List<String> facets;

  /// The server-side sort expression; deterministic by default.
  final String sort;

  /// The first requested record offset.
  final int offset;

  /// The requested maximum entries per page.
  final int pageSize;
}
