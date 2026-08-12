import '../core/raw_json.dart';
import '../exceptions/data_gov_exception.dart';

/// Immutable evidence from a catalog traversal, independent of file parsing.
final class AuditReport {
  /// Sanitizes URL credentials throughout a deeply immutable JSON report.
  AuditReport(JsonObject evidence)
    : _evidence = freezeJson(_sanitizeReportValue(evidence)! as JsonObject);

  final JsonObject _evidence;

  /// Whether an uncapped traversal covered a stable, consistent source total.
  ///
  /// This makes no claim that resource URLs work or files can be parsed.
  bool get complete => _evidence['complete'] == true;

  /// Portal, timing, page history, entry/resource observations and failures.
  ///
  /// Kind/resource counts include duplicate observations; unique ID counts are
  /// separate. URL query strings, fragments, and user info are omitted to avoid
  /// exposing signed source credentials. URL status describes metadata syntax,
  /// and parser support describes recognized labels, without source checks.
  JsonObject toJson() => _evidence;
}

Object? _sanitizeReportValue(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries)
        _sanitizeReportText(entry.key.toString()): _sanitizeReportValue(
          entry.value,
        ),
    };
  }
  if (value is Iterable) {
    return value.map(_sanitizeReportValue).toList();
  }
  if (value == null || value is num || value is bool) return value;
  return _sanitizeReportText(value.toString());
}

String _sanitizeReportText(String value) => sanitizeExceptionText(
  value.replaceAllMapped(
    // Apostrophes and punctuation can be part of a signed URI. Consume the
    // entire token before removing credentials; only restore known wrappers.
    RegExp(r'\b[a-z][a-z0-9+.-]*://[^\s<>"]+', caseSensitive: false),
    (match) {
      var candidate = match[0]!;
      final opening = match.start == 0 ? '' : value[match.start - 1];
      final closing = switch (opening) {
        "'" => RegExp(r"'[)\]},.;:!?]*$"),
        '(' => RegExp(r'\)[)\]},.;:!?]*$'),
        '[' => RegExp(r'\][)\]},.;:!?]*$'),
        _ => null,
      };
      final suffixMatch = closing?.firstMatch(candidate);
      final suffix = suffixMatch?.group(0) ?? '';
      if (suffixMatch != null) {
        candidate = candidate.substring(0, suffixMatch.start);
      }
      try {
        final uri = Uri.tryParse(candidate);
        if (uri == null) return '[unusable URL omitted]$suffix';
        final safe = Uri(
          scheme: uri.scheme,
          host: uri.hasAuthority ? uri.host : null,
          port: uri.hasPort ? uri.port : null,
          path: uri.path,
        ).toString();
        return '$safe$suffix';
      } on FormatException {
        return '[unusable URL omitted]$suffix';
      }
    },
  ),
);
