/// Immutable bounds for a buffered JSON resource read.
final class JsonOptions {
  /// Creates validated bounds; a null [maxBytes] explicitly removes the ceiling.
  factory JsonOptions({int? maxBytes = 8388608, Duration? deadline}) {
    if (maxBytes != null && maxBytes <= 0) {
      throw ArgumentError.value(
        maxBytes,
        'maxBytes',
        'Must be positive or null',
      );
    }
    if (deadline != null && deadline <= Duration.zero) {
      throw ArgumentError.value(deadline, 'deadline', 'Must be positive');
    }
    return JsonOptions._(maxBytes, deadline);
  }

  const JsonOptions._(this.maxBytes, this.deadline);

  /// Validated defaults usable in optional argument declarations.
  static const defaults = JsonOptions._(8388608, null);

  /// Maximum decoded JSON bytes, or null for an explicitly unbounded read.
  final int? maxBytes;

  /// Optional operation deadline overriding the configured default.
  final Duration? deadline;
}
