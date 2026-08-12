import 'dart:async';

import '../core/cancellation.dart';
import '../core/raw_json.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/catalog/catalog_query.dart';
import '../models/catalog/resource_metadata.dart';
import '../services/catalog_service.dart';
import 'audit_report.dart';

/// Audits observed catalog metadata without downloading resource files.
final class CatalogAudit {
  /// Uses the selected catalog's anonymous or configured source connection.
  CatalogAudit(this._catalog);

  final CatalogService _catalog;

  /// Traverses search pages, retaining conflicting observations and failures.
  ///
  /// A cap always produces an incomplete report. Completeness requires an
  /// uncapped scan from offset zero in `id asc` order, stable totals, unique
  /// nonempty entry IDs, and an observed count matching the reported total.
  /// Cancellation returns the evidence gathered so far rather than losing it.
  Future<AuditReport> run({
    required CatalogQuery query,
    int? maxEntries,
    Duration pageDelay = const Duration(milliseconds: 250),
    CancellationSignal? cancellation,
  }) async {
    if (maxEntries != null && maxEntries <= 0) {
      throw ArgumentError.value(maxEntries, 'maxEntries', 'Must be positive');
    }
    if (pageDelay < Duration.zero) {
      throw ArgumentError.value(pageDelay, 'pageDelay', 'Must be nonnegative');
    }
    final startedAt = DateTime.now().toUtc();
    final pages = <JsonObject>[];
    final errors = <JsonObject>[];
    final observations = <JsonObject>[];
    final totals = <int>[];
    final ids = <String>{};
    final duplicates = <String>{};
    final resourceIds = <String>{};
    final duplicateResourceIds = <String>{};
    final kinds = <String, int>{};
    final urlStatuses = <String, int>{};
    final formatStatuses = <String, int>{};
    var missingIds = 0;
    var missingResourceIds = 0;
    var resourceCount = 0;
    var offset = query.offset;
    var pageSizesReliable = true;
    var stopReason = 'sourceTotalReached';
    var reachedTotal = false;
    while (true) {
      final requestedSize = maxEntries == null
          ? query.pageSize
          : (maxEntries - observations.length).clamp(1, query.pageSize);
      try {
        cancellation?.throwIfCancelled();
        final page = await _catalog.search(
          CatalogQuery(
            text: query.text,
            filters: query.filters,
            facets: query.facets,
            sort: query.sort,
            offset: offset,
            pageSize: requestedSize,
          ),
          cancellation: cancellation,
        );
        totals.add(page.total);
        pages.add({
          'offset': offset,
          'requestedPageSize': requestedSize,
          'returnedEntryCount': page.entries.length,
          'total': page.total,
        });
        if (page.entries.length > requestedSize) pageSizesReliable = false;
        final uniqueBeforePage = ids.length;
        for (final entry in page.entries) {
          if (entry.id.isEmpty) {
            missingIds++;
          } else if (!ids.add(entry.id)) {
            duplicates.add(entry.id);
          }
          kinds.update(entry.kind, (count) => count + 1, ifAbsent: () => 1);
          final resources = <JsonObject>[];
          for (final resource in entry.resources) {
            resourceCount++;
            if (resource.id.isEmpty) {
              missingResourceIds++;
            } else if (!resourceIds.add(resource.id)) {
              duplicateResourceIds.add(resource.id);
            }
            final observation = _resource(resource);
            resources.add(observation);
            urlStatuses.update(
              observation['urlStatus']! as String,
              (count) => count + 1,
              ifAbsent: () => 1,
            );
            formatStatuses.update(
              observation['formatStatus']! as String,
              (count) => count + 1,
              ifAbsent: () => 1,
            );
          }
          observations.add({
            'pageOffset': offset,
            'id': sanitizeExceptionText(entry.id),
            'kind': sanitizeExceptionText(entry.kind),
            'resources': resources,
          });
        }
        offset += page.entries.length;
        if (maxEntries != null && observations.length >= maxEntries) {
          stopReason = 'entryCap';
          break;
        }
        if (offset >= page.total) {
          reachedTotal = true;
          break;
        }
        if (page.entries.isEmpty) {
          stopReason = 'emptyPageBeforeTotal';
          break;
        }
        if (ids.length == uniqueBeforePage) {
          stopReason = 'noUniqueProgress';
          break;
        }
        await _pace(pageDelay, cancellation);
      } catch (error) {
        stopReason = error is CancelledException ? 'cancelled' : 'pageError';
        errors.add({
          'offset': offset,
          'type': error.runtimeType.toString(),
          'message': sanitizeExceptionText(error.toString()),
          if (error is DataGovException) ...{
            'action': error.action,
            'statusCode': error.statusCode,
            'details': error.details,
          },
        });
        break;
      }
    }
    final totalChanged = totals.toSet().length > 1;
    final complete =
        maxEntries == null &&
        query.offset == 0 &&
        query.sort == 'id asc' &&
        reachedTotal &&
        !totalChanged &&
        errors.isEmpty &&
        duplicates.isEmpty &&
        missingIds == 0 &&
        pageSizesReliable &&
        totals.isNotEmpty &&
        ids.length == totals.last;
    return AuditReport({
      'portal': _catalog.actionBaseUrl.toString(),
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': DateTime.now().toUtc().toIso8601String(),
      'query': {
        'text': query.text == null ? null : sanitizeExceptionText(query.text!),
        'filters': query.filters.map(sanitizeExceptionText).toList(),
        'sort': query.sort,
        'offset': query.offset,
        'pageSize': query.pageSize,
      },
      'maxEntries': maxEntries,
      'pageDelayMs': pageDelay.inMilliseconds,
      'pageCount': pages.length,
      'pageTotals': totals,
      'pages': pages,
      'totalChanged': totalChanged,
      'observedEntryCount': observations.length,
      'uniqueEntryCount': ids.length,
      'uniqueEntryIds': ids.map(sanitizeExceptionText).toList(),
      'duplicateEntryIds': duplicates.map(sanitizeExceptionText).toList(),
      'missingEntryIdCount': missingIds,
      'countsByKind': {
        for (final kind in kinds.entries)
          sanitizeExceptionText(kind.key): kind.value,
      },
      'resourceCount': resourceCount,
      'uniqueResourceCount': resourceIds.length,
      'resourceIds': resourceIds.map(sanitizeExceptionText).toList(),
      'duplicateResourceIds': duplicateResourceIds
          .map(sanitizeExceptionText)
          .toList(),
      'missingResourceIdCount': missingResourceIds,
      'resourceUrlStatuses': urlStatuses,
      'resourceFormatStatuses': formatStatuses,
      'observations': observations,
      'pageErrors': errors,
      'pageSizesReliable': pageSizesReliable,
      'stopReason': stopReason,
      'sourceChecks': {
        'performed': false,
        'parsedResourceCount': 0,
        'downloadedResourceCount': 0,
      },
      'complete': complete,
    });
  }
}

JsonObject _resource(ResourceMetadata resource) {
  final format = resource.format?.trim().toLowerCase();
  return {
    'id': sanitizeExceptionText(resource.id),
    'url': _reportUrl(resource.url),
    'downloadUrl': _reportUrl(resource.downloadUrl),
    'accessUrl': _reportUrl(resource.accessUrl),
    'urlQueriesOmitted': true,
    'urlStatus': resource.fileUri != null
        ? 'usableFileUrl'
        : resource.url == null &&
              resource.downloadUrl == null &&
              resource.accessUrl == null
        ? 'missingUrl'
        : 'unusableFileUrl',
    'format': resource.format == null
        ? null
        : sanitizeExceptionText(resource.format!),
    'formatStatus': format == null || format.isEmpty
        ? 'missingFormat'
        : const {
            'csv',
            'text/csv',
            'application/csv',
            'json',
            'geojson',
            'application/json',
            'application/geo+json',
          }.contains(format)
        ? 'supportedParser'
        : 'unsupportedParser',
    'datastoreActive': resource.datastoreActive,
    'downloadChecked': false,
    'parseChecked': false,
  };
}

String? _reportUrl(String? value) {
  if (value == null) return null;
  try {
    final uri = Uri.tryParse(value);
    if (uri == null) return '[unusable URL omitted]';
    // Signed publisher URLs use arbitrary query keys as bearer credentials.
    return Uri(
      scheme: uri.scheme,
      host: uri.hasAuthority ? uri.host : null,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();
  } on FormatException {
    return '[unusable URL omitted]';
  }
}

Future<void> _pace(Duration delay, CancellationSignal? cancellation) async {
  if (delay == Duration.zero) return;
  final done = Completer<void>();
  final timer = Timer(delay, done.complete);
  final unsubscribe = cancellation?.onCancel(() {
    if (!done.isCompleted) done.complete();
  });
  try {
    await done.future;
    cancellation?.throwIfCancelled();
  } finally {
    timer.cancel();
    unsubscribe?.call();
  }
}
