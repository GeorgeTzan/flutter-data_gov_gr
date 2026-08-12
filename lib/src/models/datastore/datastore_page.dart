import '../../core/raw_json.dart';

/// A DataStore response preserving row types and reported count semantics.
final class DataStorePage {
  /// Copies records, field metadata, and the complete response JSON.
  DataStorePage({
    required List<JsonObject> records,
    List<JsonObject> fields = const [],
    required this.offset,
    required this.requestedLimit,
    this.effectiveLimit,
    this.total,
    this.totalEstimated = false,
    JsonObject raw = const {},
  }) : records = List.unmodifiable(records.map(freezeJson)),
       fields = List.unmodifiable(fields.map(freezeJson)),
       raw = freezeJson(raw) {
    if (offset < 0 ||
        requestedLimit <= 0 ||
        (effectiveLimit != null && effectiveLimit! < 0) ||
        (total != null && total! < 0)) {
      throw ArgumentError('Invalid DataStore page coordinates');
    }
  }

  /// Returned rows, retaining source keys, values, and nulls.
  final List<JsonObject> records;

  /// Published field metadata, including unknown properties.
  final List<JsonObject> fields;

  /// The response offset.
  final int offset;

  /// The limit requested by the caller.
  final int requestedLimit;

  /// The effective server limit, only when observable.
  final int? effectiveLimit;

  /// The source total, absent when not reported.
  final int? total;

  /// Whether the source explicitly describes its total as an estimate.
  final bool totalEstimated;

  /// The complete immutable DataStore result metadata.
  final JsonObject raw;
}
