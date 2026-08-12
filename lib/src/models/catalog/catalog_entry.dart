import '../../core/raw_json.dart';
import '../shared/source_date.dart';
import 'resource_metadata.dart';

/// A catalog entry of any published type, retaining unknown metadata.
final class CatalogEntry {
  CatalogEntry._(this.raw)
    : resources = List<ResourceMetadata>.unmodifiable(
        ((raw['resources'] as List?) ?? const []).map(
          (value) => ResourceMetadata.fromJson(
            Map<String, Object?>.from(value as Map),
          ),
        ),
      );

  /// Decodes metadata without filtering entry types or resources.
  factory CatalogEntry.fromJson(JsonObject json) =>
      CatalogEntry._(freezeJson(json));

  /// Immutable metadata, including unknown publisher fields.
  final JsonObject raw;

  /// Every published resource in source order.
  final List<ResourceMetadata> resources;

  /// The catalog identifier, separate from the entry name.
  String get id => raw['id'] as String? ?? '';

  /// The catalog entry name.
  String get name => raw['name'] as String? ?? '';

  /// The unmodified type string, including future catalog types.
  String get kind => raw['type'] as String? ?? '';

  /// The published title, if present.
  String? get title => raw['title'] as String?;

  /// The published description, if present.
  String? get description => (raw['notes'] ?? raw['description']) as String?;

  /// Published title translations, retaining their JSON shapes.
  JsonObject get titleTranslated =>
      (raw['title_translated'] as JsonObject?) ?? const {};

  /// Published description translations, retaining their JSON shapes.
  JsonObject get descriptionTranslated =>
      ((raw['notes_translated'] ?? raw['description_translated'])
          as JsonObject?) ??
      const {};

  /// Published tag values, without flattening tag objects.
  List<Object?> get tags => (raw['tags'] as List<Object?>?) ?? const [];

  /// Published theme values, retaining combination values.
  List<Object?> get themes =>
      ((raw['theme'] ?? raw['themes']) as List<Object?>?) ?? const [];

  /// The publisher's organization metadata.
  Object? get organization => raw['organization'];

  /// The publisher metadata, with its original JSON shape.
  Object? get publisher => raw['publisher'];

  /// The contact metadata, with its original JSON shape.
  Object? get contactPoint => raw['contact_point'];

  /// The published spatial coverage.
  Object? get spatial => raw['spatial'];

  /// The published temporal coverage.
  Object? get temporal => raw['temporal'];

  /// Additional metadata entries in their published shape.
  Object? get extras => raw['extras'];

  /// The catalog metadata creation date, if published.
  SourceDate? get metadataCreated => _date('metadata_created');

  /// The catalog metadata modification date, if published.
  SourceDate? get metadataModified => _date('metadata_modified');

  /// Published service endpoints, without treating them as resource files.
  List<String> get serviceEndpoints {
    final value = raw['endpoint_url'];
    if (value is String) {
      return List<String>.unmodifiable([value]);
    }
    return List<String>.unmodifiable(
      (value as List? ?? const []).whereType<String>(),
    );
  }

  SourceDate? _date(String key) {
    final value = raw[key];
    return value is String ? SourceDate(value) : null;
  }
}
