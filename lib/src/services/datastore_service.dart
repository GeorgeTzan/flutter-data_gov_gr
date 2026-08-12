import 'dart:convert';

import '../core/cancellation.dart';
import '../core/cancellable_source.dart';
import '../core/ckan_executor.dart';
import '../core/raw_json.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/datastore/datastore_page.dart';
import '../models/datastore/datastore_query.dart';

/// Queries one resource through the selected source's DataStore API.
final class DataStoreService {
  /// Uses the client's shared CKAN action executor.
  DataStoreService(this._executor);

  final CkanExecutor _executor;

  /// Requests one server-side filtered, projected, and sorted page.
  Future<DataStorePage> search(
    String resourceId,
    DataStoreQuery query, {
    CancellationSignal? cancellation,
  }) async {
    _check(cancellation);
    if (resourceId.trim().isEmpty) {
      throw ValidationException(
        'A resource ID is required.',
        action: 'datastore_search',
      );
    }
    final result = await _executor.call(
      'datastore_search',
      parameters: {
        'resource_id': resourceId,
        'filters': query.filters,
        if (query.text != null) 'q': query.text,
        if (query.fields.isNotEmpty) 'fields': query.fields.join(','),
        'sort': query.sort.isEmpty
            ? '_id asc'
            : query.sort
                  .map(
                    (term) =>
                        '${term.field} ${term.descending ? 'desc' : 'asc'}',
                  )
                  .join(','),
        'limit': query.limit,
        'offset': query.offset,
      },
      cancellation: cancellation,
    );
    _check(cancellation);
    if (result is! JsonObject) {
      throw _invalid('Expected a DataStore result object.');
    }
    final estimated = result['total_was_estimated'];
    if (estimated != null && estimated is! bool) {
      throw _invalid('Expected a boolean total_was_estimated.');
    }
    return DataStorePage(
      records: _objects(result['records'], 'records'),
      fields: _objects(result['fields'] ?? const [], 'fields'),
      offset: _coordinate(result['offset'], 'offset') ?? query.offset,
      requestedLimit: query.limit,
      effectiveLimit: _coordinate(result['limit'], 'limit'),
      total: _coordinate(result['total'], 'total'),
      totalEstimated: estimated == true,
      raw: result,
    );
  }

  /// Fetches pages on demand, advancing by the actual number of returned rows.
  Stream<DataStorePage> pages(
    String resourceId,
    DataStoreQuery query, {
    CancellationSignal? cancellation,
  }) => cancellableSource((signal) async* {
    var offset = query.offset;
    final identities = <String>{};
    while (true) {
      _check(signal);
      final page = await search(
        resourceId,
        query.copyWith(offset: offset),
        cancellation: signal,
      );
      if (page.offset < offset) {
        throw PaginationException(
          'DataStore response offset did not advance.',
          action: 'datastore_search',
        );
      }
      for (final record in page.records) {
        final id = record['_id'];
        if (id != null && !identities.add(jsonEncode(id))) {
          throw PaginationException(
            'DataStore repeated a record identity.',
            action: 'datastore_search',
          );
        }
      }
      yield page;
      final nextOffset = page.offset + page.records.length;
      if (page.records.isEmpty ||
          !page.totalEstimated &&
              page.total != null &&
              nextOffset >= page.total!) {
        return;
      }
      if (nextOffset <= offset) {
        throw PaginationException(
          'DataStore traversal did not advance.',
          action: 'datastore_search',
        );
      }
      offset = nextOffset;
    }
  }, cancellation);

  /// Emits unchanged source rows while consuming one page at a time.
  Stream<JsonObject> records(
    String resourceId,
    DataStoreQuery query, {
    CancellationSignal? cancellation,
  }) => cancellableSource((signal) async* {
    await for (final page in pages(resourceId, query, cancellation: signal)) {
      for (final record in page.records) {
        _check(signal);
        yield record;
      }
    }
  }, cancellation);

  void _check(CancellationSignal? cancellation) {
    _executor.transport.throwIfClosed();
    cancellation?.throwIfCancelled();
  }

  static List<JsonObject> _objects(Object? value, String name) {
    if (value is! List || value.any((item) => item is! JsonObject)) {
      throw _invalid('Expected a DataStore $name array of objects.');
    }
    return value.cast<JsonObject>();
  }

  static int? _coordinate(Object? value, String name) {
    if (value == null) return null;
    if (value is! int || value < 0) {
      throw _invalid('Expected a nonnegative DataStore $name integer.');
    }
    return value;
  }

  static DecodeException _invalid(String message) =>
      DecodeException(message, action: 'datastore_search');
}
