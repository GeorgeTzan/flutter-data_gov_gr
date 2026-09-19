/// Explains the platform save destination or browser payload bound.
const downloadNotice = 'File saving is unavailable on this platform.';

/// Rejects saving on platforms without a supported file implementation.
Future<void> saveDownload(String filename, Stream<List<int>> bytes) async {
  throw UnsupportedError(downloadNotice);
}
