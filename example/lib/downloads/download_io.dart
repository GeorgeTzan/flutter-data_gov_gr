import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Explains the platform save destination or browser payload bound.
const downloadNotice =
    'Save to Downloads, or application documents when unavailable.';

/// Streams to temporary output, replacing the destination only after success.
///
/// Failed or cancelled transfers remove temporary output and preserve an
/// existing completed file. Native saves do not retain the complete payload.
Future<void> saveDownload(String filename, Stream<List<int>> bytes) async {
  Directory? directory;
  try {
    directory = await getDownloadsDirectory();
  } on UnsupportedError {
    directory = null;
  }
  directory ??= await getApplicationDocumentsDirectory();
  await directory.create(recursive: true);
  final safeName = filename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  final file = File(
    '${directory.path}/${safeName.isEmpty || safeName == '.' || safeName == '..' ? 'resource.download' : safeName}',
  );
  final temporaryDirectory = await directory.createTemp('.download-');
  try {
    final temporary = File('${temporaryDirectory.path}/payload');
    final output = await temporary.open(mode: FileMode.write);
    try {
      await for (final chunk in bytes) {
        await output.writeFrom(chunk);
      }
      await output.flush();
    } finally {
      await output.close();
    }
    await temporary.rename(file.path);
  } finally {
    await temporaryDirectory.delete(recursive: true);
  }
}
