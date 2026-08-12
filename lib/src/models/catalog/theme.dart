import '../../core/raw_json.dart';

/// A published data-theme vocabulary value with lossless metadata.
final class Theme {
  Theme._(this.raw);

  /// Retains source labels and authority identifiers without guessing labels.
  factory Theme.fromJson(JsonObject json) => Theme._(freezeJson(json));

  /// Immutable published metadata.
  final JsonObject raw;

  /// The vocabulary code.
  String get code => (raw['code'] ?? raw['name']) as String? ?? '';

  /// The published Greek label, absent when missing or empty.
  String? get labelEl => _label(raw['label_el']);

  /// The published English label, absent when missing or empty.
  String? get labelEn => _label(raw['label_en']);

  /// The raw published authority URI string, if present.
  String? get authorityUri =>
      (raw['value_uri'] ?? raw['authority_uri'] ?? raw['uri']) as String?;

  String? _label(Object? value) =>
      value is String && value.isNotEmpty ? value : null;
}
