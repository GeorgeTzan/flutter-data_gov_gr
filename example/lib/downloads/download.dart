/// Platform-specific file saving; browser saves have an explicit memory bound.
library;

import 'dart:typed_data';

export 'download_stub.dart'
    if (dart.library.io) 'download_io.dart'
    if (dart.library.js_interop) 'download_web.dart';

/// Collects a browser file payload, cancelling the source if it exceeds 16 MiB.
Future<Uint8List> bufferBrowserDownload(Stream<List<int>> bytes) async {
  const limit = 16 * 1024 * 1024;
  final buffer = BytesBuilder(copy: false);
  await for (final chunk in bytes) {
    if (buffer.length + chunk.length > limit) {
      throw StateError('Browser download exceeds the 16 MiB memory limit.');
    }
    buffer.add(chunk);
  }
  return buffer.takeBytes();
}
