import 'dart:convert';
import 'dart:typed_data';

import '../core/raw_json.dart';
import '../exceptions/data_gov_exception.dart';
import '../models/resources/json_options.dart';

/// Reads a bounded JSON document without changing its root shape.
final class JsonReader {
  /// Creates a JSON reader without retained state.
  const JsonReader();

  /// Decodes strict UTF-8 JSON and recursively freezes its values.
  Future<Object?> read(Stream<List<int>> bytes, JsonOptions options) async {
    final buffer = BytesBuilder(copy: false);
    await for (final chunk in bytes) {
      final limit = options.maxBytes;
      if (limit != null && buffer.length + chunk.length > limit) {
        throw ByteLimitException('JSON document exceeds decoded byte ceiling.');
      }
      buffer.add(chunk);
    }
    try {
      final document = jsonDecode(utf8.decode(buffer.takeBytes()));
      return freezeJson({'document': document})['document'];
    } on FormatException catch (error) {
      throw DecodeException(
        'Resource is not valid UTF-8 JSON.',
        originalError: error,
      );
    }
  }
}
