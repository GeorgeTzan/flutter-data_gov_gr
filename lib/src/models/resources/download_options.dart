/// Immutable bounds for a decoded resource download.
final class DownloadOptions {
  /// Creates validated bounds; a null [maxBytes] explicitly removes the ceiling.
  factory DownloadOptions({int? maxBytes = 67108864, Duration? deadline}) {
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
    return DownloadOptions._(maxBytes, deadline);
  }

  const DownloadOptions._(this.maxBytes, this.deadline);

  /// Validated defaults usable in optional argument declarations.
  static const defaults = DownloadOptions._(67108864, null);

  /// Maximum decoded bytes, or null for an explicitly unbounded download.
  final int? maxBytes;

  /// Optional operation deadline overriding the configured default.
  final Duration? deadline;
}
