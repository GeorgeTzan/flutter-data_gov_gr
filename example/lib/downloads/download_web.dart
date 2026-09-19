import 'dart:js_interop';
import 'download.dart' show bufferBrowserDownload;
import 'package:web/web.dart' as web;

/// Explains the platform save destination or browser payload bound.
const downloadNotice =
    'Browser save: 16 MiB memory limit; use native for larger files.';

/// Buffers at most 16 MiB before creating a browser Blob download.
Future<void> saveDownload(String filename, Stream<List<int>> bytes) async {
  final payload = await bufferBrowserDownload(bytes);
  final blob = web.Blob(<JSAny>[payload.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  try {
    web.document.body?.appendChild(anchor);
    anchor.click();
    await Future<void>.delayed(const Duration(seconds: 1));
  } finally {
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }
}
