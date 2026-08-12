import '../../core/raw_json.dart';

/// One server-side sort field and direction.
final class DataStoreSort {
  /// Creates a sort term with a nonempty field name.
  DataStoreSort(this.field, {this.descending = false}) {
    if (field.trim().isEmpty) {
      throw ArgumentError.value(field, 'field', 'Must not be empty');
    }
  }

  /// The exact source field name.
  final String field;

  /// Whether the server should order this field descending.
  final bool descending;
}

/// Immutable operations performed by the resource-specific DataStore.
final class DataStoreQuery {
  /// Creates a query with deeply copied filters and valid pagination.
  DataStoreQuery({
    JsonObject filters = const {},
    this.text,
    List<String> fields = const [],
    List<DataStoreSort> sort = const [],
    this.limit = 100,
    this.offset = 0,
  }) : filters = freezeJson(filters),
       fields = List.unmodifiable(fields),
       sort = List.unmodifiable(sort) {
    if (offset < 0 || limit <= 0) {
      throw ArgumentError('Invalid DataStore pagination');
    }
  }

  /// Exact server-side filter values, retaining JSON types.
  final JsonObject filters;

  /// The optional full-text search expression.
  final String? text;

  /// Projected source field names in caller order.
  final List<String> fields;

  /// Ordered server-side sort terms.
  final List<DataStoreSort> sort;

  /// The requested maximum rows per page.
  final int limit;

  /// The first requested row offset.
  final int offset;

  /// Changes traversal coordinates while retaining the original query intent.
  DataStoreQuery copyWith({int? offset, int? limit}) => DataStoreQuery(
    filters: filters,
    text: text,
    fields: fields,
    sort: sort,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
  );
}
