import 'dart:convert';

import '../core/cancellation.dart';
import '../core/cancellable_source.dart';
import '../core/ckan_executor.dart';
import '../core/metadata_cache.dart';
import '../core/raw_json.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/catalog/catalog_entry.dart';
import '../models/catalog/catalog_page.dart';
import '../models/catalog/catalog_query.dart';
import '../models/catalog/organization.dart';
import '../models/catalog/resource_metadata.dart';
import '../models/catalog/theme.dart';

/// Read-only catalog discovery and cached published metadata.
final class CatalogService {
  /// Uses the owning client's shared executor and metadata cache.
  CatalogService(this._executor, this._cache);

  final CkanExecutor _executor;
  final MetadataCache _cache;

  /// The selected portal's CKAN action directory.
  Uri get actionBaseUrl => _executor.actionBase;

  /// Searches all published kinds with the source total and raw facets.
  Future<CatalogPage> search(
    CatalogQuery query, {
    CancellationSignal? cancellation,
  }) async {
    final result = await _executor.call(
      'package_search',
      parameters: {
        if (query.text != null) 'q': query.text,
        if (query.filters.isNotEmpty)
          'fq': query.filters.map((filter) => '($filter)').join(' AND '),
        if (query.facets.isNotEmpty) 'facet.field': query.facets,
        'sort': query.sort,
        'start': query.offset,
        'rows': query.pageSize,
      },
      cancellation: cancellation,
    );
    return _decode('package_search', () {
      final json = _object(result);
      final total = json['count'];
      if (total is! int || total < 0) {
        throw const FormatException('Expected a nonnegative catalog count.');
      }
      return CatalogPage(
        entries: _objects(json['results']).map(CatalogEntry.fromJson).toList(),
        offset: query.offset,
        requestedPageSize: query.pageSize,
        total: total,
        rawFacets: json['search_facets'] == null
            ? const {}
            : _object(json['search_facets']),
      );
    });
  }

  /// Traverses all matching entries in the requested deterministic order.
  Stream<CatalogEntry> entries(
    CatalogQuery query, {
    CancellationSignal? cancellation,
  }) => cancellableSource((signal) async* {
    var offset = query.offset;
    final seen = <String>{};
    while (true) {
      _check(signal);
      final page = await search(
        CatalogQuery(
          text: query.text,
          filters: query.filters,
          facets: query.facets,
          sort: query.sort,
          offset: offset,
          pageSize: query.pageSize,
        ),
        cancellation: signal,
      );
      if (page.entries.isEmpty) return;
      _recordIds(page.entries.map((entry) => entry.id), seen, 'package_search');
      for (final entry in page.entries) {
        _check(signal);
        yield entry;
      }
      _check(signal);
      offset += page.entries.length;
      if (offset >= page.total) return;
    }
  }, cancellation);

  /// Returns the published metadata for an entry identifier or name.
  Future<CatalogEntry> getEntry(
    String idOrName, {
    bool refresh = false,
    CancellationSignal? cancellation,
  }) => _metadata(
    'package_show',
    {'id': idOrName},
    (value) => CatalogEntry.fromJson(_object(value)),
    refresh: refresh,
    cancellation: cancellation,
  );

  /// Returns resource metadata without requiring a usable file URL.
  Future<ResourceMetadata> getResource(
    String id, {
    bool refresh = false,
    CancellationSignal? cancellation,
  }) => _metadata(
    'resource_show',
    {'id': id},
    (value) => ResourceMetadata.fromJson(_object(value)),
    refresh: refresh,
    cancellation: cancellation,
  );

  /// Lists full organization metadata at the requested offset.
  Future<OrganizationPage> organizations(
    OrganizationQuery query, {
    bool refresh = false,
    CancellationSignal? cancellation,
  }) => _metadata(
    'organization_list',
    {'all_fields': true, 'limit': query.pageSize, 'offset': query.offset},
    (value) => OrganizationPage(
      organizations: _objects(value).map(Organization.fromJson).toList(),
      offset: query.offset,
    ),
    usePost: true,
    refresh: refresh,
    cancellation: cancellation,
  );

  /// Traverses organizations until the selected source returns an empty page.
  Stream<Organization> allOrganizations(
    OrganizationQuery query, {
    CancellationSignal? cancellation,
  }) => cancellableSource((signal) async* {
    var offset = query.offset;
    final seen = <String>{};
    while (true) {
      _check(signal);
      final page = await organizations(
        OrganizationQuery(offset: offset, pageSize: query.pageSize),
        refresh: true,
        cancellation: signal,
      );
      if (page.organizations.isEmpty) return;
      _recordIds(
        page.organizations.map((organization) => organization.id),
        seen,
        'organization_list',
      );
      for (final organization in page.organizations) {
        _check(signal);
        yield organization;
      }
      _check(signal);
      offset += page.organizations.length;
      if (page.total != null && offset >= page.total!) return;
    }
  }, cancellation);

  /// Returns published data themes without inventing missing labels.
  Future<List<Theme>> themes({
    bool refresh = false,
    CancellationSignal? cancellation,
  }) => _metadata(
    'vocabularyadmin_vocabulary_show',
    {'id': 'Data theme'},
    (value) => List<Theme>.unmodifiable(
      _objects(_object(value)['tags']).map(Theme.fromJson),
    ),
    usePost: true,
    refresh: refresh,
    cancellation: cancellation,
  );

  /// Clears metadata retained by this catalog service.
  void clearCache() {
    _cache.removeWhere((key) => key.startsWith('catalog:'));
  }

  Future<T> _metadata<T>(
    String action,
    JsonObject parameters,
    T Function(Object?) decode, {
    bool usePost = false,
    bool refresh = false,
    CancellationSignal? cancellation,
  }) async {
    _check(cancellation);
    final keys = parameters.keys.toList()..sort();
    final key =
        'catalog:$action:${jsonEncode({for (final key in keys) key: parameters[key]})}';
    if (!refresh) {
      final cached = _cache.get(key);
      if (cached != null) return _decode(action, () => decode(cached));
    }
    final raw = await _executor.call(
      action,
      parameters: parameters,
      usePost: usePost,
      cancellation: cancellation,
    );
    _check(cancellation);
    final decoded = _decode(action, () => decode(raw));
    _cache.put(key, raw!, jsonBytes: utf8.encode(jsonEncode(raw)).length);
    return decoded;
  }

  void _check(CancellationSignal? cancellation) {
    _executor.transport.throwIfClosed();
    cancellation?.throwIfCancelled();
  }
}

JsonObject _object(Object? value) {
  if (value is! Map) {
    throw const FormatException('Expected a metadata object.');
  }
  return Map<String, Object?>.from(value);
}

List<JsonObject> _objects(Object? value) {
  if (value is! List) {
    throw const FormatException('Expected a metadata list.');
  }
  return value.map(_object).toList();
}

T _decode<T>(String action, T Function() decode) {
  try {
    return decode();
  } on FormatException catch (error) {
    throw DecodeException(
      'Invalid catalog metadata.',
      action: action,
      originalError: error,
    );
  } on TypeError catch (error) {
    throw DecodeException(
      'Invalid catalog metadata.',
      action: action,
      originalError: error,
    );
  }
}

void _recordIds(Iterable<String> ids, Set<String> seen, String action) {
  for (final id in ids) {
    if (id.isEmpty || !seen.add(id)) {
      throw PaginationException(
        'Catalog traversal encountered a missing or repeated identifier.',
        action: action,
      );
    }
  }
}
