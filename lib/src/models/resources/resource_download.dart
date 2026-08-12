import 'dart:async';

import '../shared/source_provenance.dart';

/// A streamed download and its observed source metadata.
final class ResourceDownload {
  /// Creates a single-subscription view of [bytes] with demand-driven delivery.
  ResourceDownload({
    required this.finalUrl,
    this.contentType,
    this.contentLength,
    required this.provenance,
    required Stream<List<int>> bytes,
  }) : bytes = _singleSubscription(bytes) {
    if (contentLength != null && contentLength! < 0) {
      throw ArgumentError.value(
        contentLength,
        'contentLength',
        'Must be nonnegative',
      );
    }
  }

  /// The final response URL after redirects.
  final Uri finalUrl;

  /// The response content type, when reported.
  final String? contentType;

  /// The reported content length; it does not replace decoded-byte enforcement.
  final int? contentLength;

  /// The selected source and retrieval metadata.
  final SourceProvenance provenance;

  /// Single-subscription decoded bytes, streamed under consumer demand.
  final Stream<List<int>> bytes;

  static Stream<List<int>> _singleSubscription(Stream<List<int>> source) {
    late StreamController<List<int>> controller;
    StreamSubscription<List<int>>? subscription;
    controller = StreamController<List<int>>(
      sync: true,
      onListen: () {
        subscription = source.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }
}
