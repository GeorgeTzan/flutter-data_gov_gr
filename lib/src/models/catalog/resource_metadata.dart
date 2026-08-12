import '../../core/raw_json.dart';
import '../shared/source_date.dart';

/// Lossless published metadata for a resource, including unusable URLs.
final class ResourceMetadata {
  ResourceMetadata._(this.raw);

  /// Retains every published field without requiring a usable download URL.
  factory ResourceMetadata.fromJson(JsonObject json) =>
      ResourceMetadata._(freezeJson(json));

  /// Immutable metadata, including unknown publisher fields.
  final JsonObject raw;

  /// The resource identifier; empty when the publisher omitted it.
  String get id => raw['id'] as String? ?? '';

  /// The publisher's format label, if present.
  String? get format => raw['format'] as String?;

  /// The published resource name, if present.
  String? get name => raw['name'] as String?;

  /// The original resource URL, including malformed values.
  String? get url => raw['url'] as String?;

  /// The distinct download-role URL, which may be a catalog webpage.
  String? get downloadUrl => raw['download_url'] as String?;

  /// The distinct access-role URL, if published.
  String? get accessUrl => raw['access_url'] as String?;

  /// The publisher's URL role string.
  String? get urlType => raw['url_type'] as String?;

  /// The publisher's resource role string.
  String? get resourceType => raw['resource_type'] as String?;

  /// Whether the publisher explicitly reports an active DataStore.
  bool? get datastoreActive => raw['datastore_active'] as bool?;

  /// The resource modification text, if published.
  SourceDate? get modified {
    final value = raw['last_modified'] ?? raw['modified'];
    return value is String ? SourceDate(value) : null;
  }

  /// A usable absolute HTTP(S) file URL, without substituting URL roles.
  ///
  /// An existing but unusable [url] remains unusable. A missing [url] permits
  /// [downloadUrl] only when an explicit file/download role was published.
  Uri? get fileUri {
    final roles = [urlType?.toLowerCase(), resourceType?.toLowerCase()];
    if (roles.any(
      (role) => const {
        'api',
        'service',
        'dataservice',
        'data-service',
        'endpoint',
        'access',
        'documentation',
        'landing_page',
      }.contains(role),
    )) {
      return null;
    }
    final candidate =
        url ??
        (roles.any(
              (role) => const {'download', 'file', 'upload'}.contains(role),
            )
            ? downloadUrl
            : null);
    if (candidate == null || RegExp(r'\s').hasMatch(candidate)) {
      return null;
    }
    final uri = Uri.tryParse(candidate);
    if (uri == null ||
        !const {'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    try {
      if (RegExp(
        r'[\s\x00-\x1f\x7f]',
      ).hasMatch(Uri.decodeComponent(uri.host))) {
        return null;
      }
    } on FormatException {
      return null;
    }
    return uri;
  }
}
