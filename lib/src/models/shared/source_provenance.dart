import '../../core/raw_json.dart';
import 'source_date.dart';

/// Identifies a selected source and distinguishes published and retrieval time.
final class SourceProvenance {
  /// Creates provenance; [sourceRow], when present, is one-based.
  SourceProvenance({
    this.entryId,
    required this.resourceId,
    required this.sourceUrl,
    this.publishedModified,
    required this.retrievedAt,
    this.sourceRow,
  }) {
    if (sourceRow != null && sourceRow! <= 0) {
      throw ArgumentError.value(sourceRow, 'sourceRow', 'Must be one-based');
    }
  }

  /// Restores the JSON representation used by generated domain models.
  factory SourceProvenance.fromJson(JsonObject json) => SourceProvenance(
    entryId: json['entryId'] as String?,
    resourceId: json['resourceId'] as String,
    sourceUrl: json['sourceUrl'] as String,
    publishedModified: json['publishedModified'] == null
        ? null
        : SourceDate(json['publishedModified'] as String),
    retrievedAt: DateTime.parse(json['retrievedAt'] as String),
    sourceRow: json['sourceRow'] as int?,
  );

  /// The catalog entry ID when known.
  final String? entryId;

  /// The selected resource ID.
  final String resourceId;

  /// The original selected source URL.
  final String sourceUrl;

  /// The published modification date, without guessed timezone information.
  final SourceDate? publishedModified;

  /// The locally measured retrieval time.
  final DateTime retrievedAt;

  /// The one-based position in the source, when meaningful.
  final int? sourceRow;

  /// Produces JSON suitable for generated domain model serialization.
  JsonObject toJson() => {
    'entryId': entryId,
    'resourceId': resourceId,
    'sourceUrl': sourceUrl,
    'publishedModified': publishedModified?.raw,
    'retrievedAt': retrievedAt.toIso8601String(),
    'sourceRow': sourceRow,
  };
}
