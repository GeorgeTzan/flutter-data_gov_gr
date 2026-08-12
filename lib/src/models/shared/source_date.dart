/// A published date retaining its original text and timezone semantics.
final class SourceDate {
  /// Retains [raw] even when it is not a parseable ISO date.
  const SourceDate(this.raw);

  /// The unmodified source date text.
  final String raw;

  /// Whether Dart can parse the source as an ISO date or timestamp.
  bool get isParseable => DateTime.tryParse(raw) != null;

  /// The UTC instant, available only for explicitly offset-qualified timestamps.
  DateTime? get utcValue {
    if (!RegExp(r'[Tt ]\d.*(?:[zZ]|[+-]\d{2}(?::?\d{2})?)$').hasMatch(raw)) {
      return null;
    }
    return DateTime.tryParse(raw)?.toUtc();
  }
}
