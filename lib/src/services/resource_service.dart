import 'dart:async';

import '../core/cancellation.dart';
import '../core/http_transport.dart';
import '../core/raw_json.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/catalog/resource_metadata.dart';
import '../models/resources/csv_options.dart';
import '../models/resources/download_options.dart';
import '../models/resources/json_options.dart';
import '../models/resources/resource_download.dart';
import '../models/shared/source_provenance.dart';
import '../parsers/csv_reader.dart';
import '../parsers/json_reader.dart';

/// Reads selected resource files through the client's bounded HTTP pipeline.
final class ResourceService {
  /// Uses the shared client transport for resource requests.
  ResourceService(this._transport);

  final HttpTransport _transport;

  /// Streams CSV records with source string cells.
  ///
  /// Uses the first record as unique, nonempty headers. Malformed CSV and row
  /// widths raise [DecodeException]. Cancelling the subscription aborts its
  /// transfer, including a pending request before the first byte arrives.
  Stream<Map<String, String>> csvRows(
    ResourceMetadata resource, {
    CsvOptions options = CsvOptions.defaults,
    CancellationSignal? cancellation,
  }) {
    late StreamController<Map<String, String>> controller;
    StreamSubscription<Map<String, String>>? subscription;
    final transfer = CancellationController();
    void Function()? detach;
    var stopped = false;
    Future<void> start() async {
      try {
        _checkFormat(resource, const {'csv', 'text/csv', 'application/csv'});
        detach = cancellation?.onCancel(
          () => transfer.cancel(cancellation.reason),
        );
        final response = await download(
          resource,
          options: options.download,
          cancellation: transfer.signal,
        );
        subscription = const CsvReader()
            .rows(response.bytes, options)
            .listen(
              controller.add,
              onError: controller.addError,
              onDone: () {
                detach?.call();
                unawaited(controller.close());
              },
            );
        if (stopped) {
          await subscription!.cancel();
        } else if (controller.isPaused) {
          subscription!.pause();
        }
      } catch (error, stack) {
        detach?.call();
        if (!stopped) {
          controller.addError(error, stack);
          unawaited(controller.close());
        }
      }
    }

    controller = StreamController<Map<String, String>>(
      sync: true,
      onListen: () => unawaited(start()),
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        stopped = true;
        detach?.call();
        transfer.cancel('CSV subscription cancelled.');
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// Reads one bounded JSON document, retaining its root shape.
  ///
  /// Strict UTF-8 and JSON decoding failures raise [DecodeException]. Returned
  /// maps and lists are immutable. [options] controls the separate JSON byte
  /// ceiling and the shared transport's operation deadline.
  Future<Object?> readJson(
    ResourceMetadata resource, {
    JsonOptions options = JsonOptions.defaults,
    CancellationSignal? cancellation,
  }) async {
    _checkFormat(resource, const {
      'json',
      'geojson',
      'application/json',
      'application/geo+json',
    });
    final response = await download(
      resource,
      options: DownloadOptions(
        maxBytes: options.maxBytes,
        deadline: options.deadline,
      ),
      cancellation: cancellation,
    );
    return const JsonReader().read(response.bytes, options);
  }

  /// Selects a JSON array of objects; other selected shapes are rejected.
  ///
  /// GeoJSON feature collections require an explicit [select] callback.
  /// Returns immutable rows, or raises [DecodeException] for incompatible data.
  List<JsonObject> jsonObjectRows(
    Object? document, {
    Object? Function(Object?)? select,
  }) {
    final selected = select == null ? document : select(document);
    if (selected is! List) {
      throw DecodeException('Selected JSON rows must be an array of objects.');
    }
    try {
      return List<JsonObject>.unmodifiable(
        selected.map((row) {
          if (row is! Map || row.keys.any((key) => key is! String)) {
            throw DecodeException(
              'Selected JSON rows must contain only objects.',
            );
          }
          return freezeJson(Map<String, Object?>.from(row));
        }),
      );
    } on ArgumentError catch (error) {
      throw DecodeException(
        'Selected rows contain invalid JSON values.',
        originalError: error,
      );
    } on TypeError catch (error) {
      throw DecodeException(
        'Selected rows contain invalid JSON values.',
        originalError: error,
      );
    }
  }

  void _checkFormat(ResourceMetadata resource, Set<String> supported) {
    _transport.throwIfClosed();
    final format = resource.format?.trim().toLowerCase();
    if (format != null && format.isNotEmpty && !supported.contains(format)) {
      throw UnsupportedFormatException(
        'Resource format is incompatible with the requested parser.',
      );
    }
  }

  /// Downloads the actual file source under [options] and [cancellation].
  ///
  /// Rejects unusable URLs with [UnsupportedResourceException]. The transport
  /// validates at most one nonempty chunk before returning response metadata;
  /// subsequent bytes arrive under consumer demand. Failures before publication
  /// may retry, while errors on the returned stream never restart the download.
  Future<ResourceDownload> download(
    ResourceMetadata resource, {
    DownloadOptions options = DownloadOptions.defaults,
    CancellationSignal? cancellation,
  }) async {
    _transport.throwIfClosed();
    final uri = resource.fileUri;
    if (uri == null) {
      throw UnsupportedResourceException(
        'Resource has no usable HTTP(S) file URL.',
      );
    }
    final response = await _transport.openDownload(
      uri,
      options: options,
      cancellation: cancellation,
    );
    final entryId = resource.raw['package_id'];
    return ResourceDownload(
      finalUrl: response.finalUri,
      contentType: response.contentType,
      contentLength: response.contentLength,
      provenance: SourceProvenance(
        entryId: entryId is String ? entryId : null,
        resourceId: resource.id,
        sourceUrl: uri.toString(),
        publishedModified: resource.modified,
        retrievedAt: response.retrievedAt,
      ),
      bytes: response.bytes,
    );
  }
}
