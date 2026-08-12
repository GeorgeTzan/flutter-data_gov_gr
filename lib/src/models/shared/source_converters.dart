import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/raw_json.dart';
import '../../exceptions/data_gov_exception.dart';
import 'source_date.dart';
import 'source_provenance.dart';

/// Serializes a published date as its unmodified source text.
class SourceDateConverter implements JsonConverter<SourceDate, String> {
  /// Creates a source date converter.
  const SourceDateConverter();
  @override
  SourceDate fromJson(String json) => SourceDate(json);
  @override
  String toJson(SourceDate object) => object.raw;
}

/// Serializes source identity and independently measured retrieval time.
class SourceProvenanceConverter
    implements JsonConverter<SourceProvenance, Map<String, dynamic>> {
  /// Creates a provenance converter.
  const SourceProvenanceConverter();
  @override
  SourceProvenance fromJson(Map<String, dynamic> json) =>
      SourceProvenance.fromJson(json);
  @override
  Map<String, dynamic> toJson(SourceProvenance object) => object.toJson();
}

/// Recursively copies and freezes retained source JSON during deserialization.
class ImmutableSourceConverter
    implements JsonConverter<JsonObject, Map<String, dynamic>> {
  /// Creates an immutable source converter.
  const ImmutableSourceConverter();
  @override
  JsonObject fromJson(Map<String, dynamic> json) => freezeJson(json);
  @override
  Map<String, dynamic> toJson(JsonObject object) => object;
}

/// Validates documented source cells with field and source-position context.
final class SourceRecordDecoder {
  /// Reads a source record without changing its retained raw representation.
  SourceRecordDecoder(this.record, this.provenance);
  final JsonObject record;
  final SourceProvenance provenance;

  /// Requires a nonblank source string, preserving its original text.
  String string(String field) {
    final value = record[field];
    if (value is! String || value.trim().isEmpty) {
      throw invalid(field, 'Expected a nonblank source string.');
    }
    return value;
  }

  /// Reads optional strings; blanks remain absent.
  String? optionalString(String field) {
    if (_blank(record[field])) return null;
    return string(field);
  }

  /// Requires a valid ISO calendar date or timestamp and retains its text.
  SourceDate date(String field) {
    final value = string(field);
    final parts = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})(?:[Tt ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?(?:[zZ]|[+-](\d{2})(?::?(\d{2}))?)?)?$',
    ).firstMatch(value);
    final parsed = DateTime.tryParse(value);
    if (parts == null || parsed == null) {
      throw invalid(field, 'Expected a valid ISO source date.');
    }
    final year = int.parse(parts[1]!);
    final month = int.parse(parts[2]!);
    final day = int.parse(parts[3]!);
    final calendar = DateTime.utc(year, month, day);
    if (calendar.year != year ||
        calendar.month != month ||
        calendar.day != day ||
        (parts[4] != null && int.parse(parts[4]!) > 23) ||
        (parts[5] != null && int.parse(parts[5]!) > 59) ||
        (parts[6] != null && int.parse(parts[6]!) > 59) ||
        (parts[7] != null && int.parse(parts[7]!) > 23) ||
        (parts[8] != null && int.parse(parts[8]!) > 59)) {
      throw invalid(field, 'Expected a valid ISO source date.');
    }
    return SourceDate(value);
  }

  /// Reads an optional source date; blank values remain absent.
  SourceDate? optionalDate(String field) =>
      _blank(record[field]) ? null : date(field);

  /// Reads a finite numeric source value without deriving units.
  num? number(String field) {
    final value = record[field];
    if (_blank(value)) return null;
    final parsed = value is num
        ? value
        : value is String
        ? num.tryParse(value.trim())
        : null;
    if (parsed == null || !parsed.isFinite) {
      throw invalid(field, 'Expected a finite source number.');
    }
    return parsed;
  }

  /// Reads an optional integral count without replacing blanks with zero.
  ///
  /// Counts must be within -9007199254740991 through 9007199254740991,
  /// the exact portable integer range shared by the VM and JavaScript.
  int? integer(String field) {
    final parsed = number(field);
    if (parsed == null) return null;
    final raw = record[field];
    if (raw is String) {
      final parts = RegExp(
        r'^([+-]?)(\d*)(?:\.(\d*))?(?:[eE]([+-]?\d+))?$',
      ).firstMatch(raw.trim());
      if (parts != null) {
        final fraction = parts[3] ?? '';
        var digits = '${parts[2]}$fraction'.replaceFirst(RegExp(r'^0+'), '');
        if (digits.isEmpty) return 0;
        final exponent = int.tryParse(parts[4] ?? '0');
        if (exponent == null) {
          throw invalid(field, 'Expected a portable integral source count.');
        }
        var scale = exponent - fraction.length;
        final trailingZeros = RegExp(r'0+$').firstMatch(digits);
        if (trailingZeros != null) {
          scale += digits.length - trailingZeros.start;
          digits = digits.substring(0, trailingZeros.start);
        }
        if (scale < 0) {
          throw invalid(field, 'Expected an integral source count.');
        }
        if (scale > 16 - digits.length) {
          throw invalid(
            field,
            'Source count exceeds the portable integer range.',
          );
        }
        final magnitude = BigInt.parse(digits) * BigInt.from(10).pow(scale);
        if (magnitude > BigInt.from(9007199254740991)) {
          throw invalid(
            field,
            'Source count exceeds the portable integer range.',
          );
        }
        return (parts[1] == '-' ? -magnitude : magnitude).toInt();
      }
    }
    if (parsed < -9007199254740991 || parsed > 9007199254740991) {
      throw invalid(field, 'Source count exceeds the portable integer range.');
    }
    if (parsed is int) return parsed;
    if (parsed != parsed.truncateToDouble()) {
      throw invalid(field, 'Expected an integral source count.');
    }
    return parsed.toInt();
  }

  /// Creates a contextual source decoding failure.
  DecodeException invalid(String field, String message) => DecodeException(
    message,
    details: {'field': field, 'sourceRow': provenance.sourceRow},
  );

  bool _blank(Object? value) =>
      value == null || value is String && value.trim().isEmpty;
}
