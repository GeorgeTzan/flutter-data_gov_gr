import '../../core/raw_json.dart';

/// Lossless metadata for a publishing organization.
final class Organization {
  Organization._(this.raw);

  /// Retains all organization metadata, including unknown fields.
  factory Organization.fromJson(JsonObject json) =>
      Organization._(freezeJson(json));

  /// Immutable published metadata.
  final JsonObject raw;

  /// The organization identifier.
  String get id => raw['id'] as String? ?? '';

  /// The organization name.
  String get name => raw['name'] as String? ?? '';

  /// The organization title, if present.
  String? get title => raw['title'] as String?;

  /// The organization description, if present.
  String? get description => raw['description'] as String?;
}

/// Immutable pagination options for organization listing.
final class OrganizationQuery {
  /// Creates a query with positive page size and nonnegative offset.
  OrganizationQuery({this.offset = 0, this.pageSize = 100}) {
    if (offset < 0 || pageSize <= 0) {
      throw ArgumentError('Invalid organization pagination');
    }
  }

  /// The first organization offset.
  final int offset;

  /// The requested maximum organizations per page.
  final int pageSize;
}

/// A page of organizations with an optional source total.
final class OrganizationPage {
  /// Copies the page and validates coordinates.
  OrganizationPage({
    required List<Organization> organizations,
    required this.offset,
    this.total,
  }) : organizations = List.unmodifiable(organizations) {
    if (offset < 0 || (total != null && total! < 0)) {
      throw ArgumentError('Invalid organization page coordinates');
    }
  }

  /// The returned organizations in source order.
  final List<Organization> organizations;

  /// The response offset.
  final int offset;

  /// The source total, absent when not reported.
  final int? total;
}
