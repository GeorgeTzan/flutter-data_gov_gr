/// Immutable retry and deadline bounds for an operation.
final class RetryPolicy {
  /// Creates validated bounds, defaulting to three attempts including the first.
  factory RetryPolicy({
    int maxAttempts = 3,
    Duration initialBackoff = const Duration(milliseconds: 250),
    Duration maxBackoff = const Duration(seconds: 2),
    Duration deadline = const Duration(seconds: 60),
  }) {
    if (maxAttempts < 1) {
      throw ArgumentError.value(maxAttempts, 'maxAttempts', 'Must be positive');
    }
    if (initialBackoff < Duration.zero ||
        maxBackoff <= Duration.zero ||
        initialBackoff > maxBackoff ||
        deadline <= Duration.zero) {
      throw ArgumentError('Invalid retry durations');
    }
    return RetryPolicy._(maxAttempts, initialBackoff, maxBackoff, deadline);
  }

  const RetryPolicy._(
    this.maxAttempts,
    this.initialBackoff,
    this.maxBackoff,
    this.deadline,
  );

  /// Validated defaults usable in optional argument declarations.
  static const defaults = RetryPolicy._(
    3,
    Duration(milliseconds: 250),
    Duration(seconds: 2),
    Duration(seconds: 60),
  );

  /// Maximum attempts including the initial request.
  final int maxAttempts;

  /// The initial exponential backoff before jitter.
  final Duration initialBackoff;

  /// The maximum backoff after applying jitter.
  final Duration maxBackoff;

  /// The total operation deadline, reset for each traversal page.
  final Duration deadline;
}

/// Immutable capacity bounds for retained metadata JSON.
final class MetadataCachePolicy {
  /// Creates validated cache bounds; a zero TTL disables retention.
  factory MetadataCachePolicy({
    Duration ttl = const Duration(minutes: 5),
    int maxEntries = 128,
    int maxBytes = 8388608,
  }) {
    if (ttl < Duration.zero || maxEntries <= 0 || maxBytes <= 0) {
      throw ArgumentError('Invalid metadata cache bounds');
    }
    return MetadataCachePolicy._(ttl, maxEntries, maxBytes);
  }

  const MetadataCachePolicy._(this.ttl, this.maxEntries, this.maxBytes);

  /// Validated defaults usable in optional argument declarations.
  static const defaults = MetadataCachePolicy._(
    Duration(minutes: 5),
    128,
    8388608,
  );

  /// The maximum age of a retained metadata response.
  final Duration ttl;

  /// The maximum number of retained metadata responses.
  final int maxEntries;

  /// The maximum retained JSON payload bytes.
  final int maxBytes;
}

/// Immutable connection, ownership, retry, and metadata cache configuration.
final class DataGovConfig {
  /// Creates configuration for an absolute HTTP(S) action directory URL.
  ///
  /// The URL must end in `/` and cannot contain credentials, query, or fragment.
  DataGovConfig({
    Uri? actionBaseUrl,
    this.apiKey,
    this.requestTimeout = const Duration(seconds: 30),
    this.retry = RetryPolicy.defaults,
    this.metadataCache = MetadataCachePolicy.defaults,
    this.disposeInjectedAdapter = false,
  }) : actionBaseUrl =
           actionBaseUrl ?? Uri.parse('https://data.gov.gr/api/3/action/') {
    final url = this.actionBaseUrl;
    if (!const {'http', 'https'}.contains(url.scheme) ||
        url.host.isEmpty ||
        RegExp(r'\s|%20', caseSensitive: false).hasMatch(url.host) ||
        url.userInfo.isNotEmpty ||
        url.hasQuery ||
        url.hasFragment ||
        !url.path.endsWith('/')) {
      throw ArgumentError.value(
        url,
        'actionBaseUrl',
        'Expected an absolute HTTP(S) directory URL without credentials, query, or fragment',
      );
    }
    if (requestTimeout <= Duration.zero) {
      throw ArgumentError.value(
        requestTimeout,
        'requestTimeout',
        'Must be positive',
      );
    }
  }

  /// The selected CKAN action directory URL.
  final Uri actionBaseUrl;

  /// Optional API key for the configured CKAN origin.
  final String? apiKey;

  /// Timeout for each HTTP request attempt.
  final Duration requestTimeout;

  /// Retry and per-operation deadline bounds.
  final RetryPolicy retry;

  /// Metadata-only cache bounds.
  final MetadataCachePolicy metadataCache;

  /// Whether closing the client also disposes a caller-supplied adapter.
  final bool disposeInjectedAdapter;
}
