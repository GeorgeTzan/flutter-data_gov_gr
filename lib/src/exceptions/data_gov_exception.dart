/// Base class for failures raised directly by the data.gov.gr SDK.
sealed class DataGovException implements Exception {
  /// Creates a failure with immutable, sanitized diagnostic context.
  DataGovException(
    String message, {
    String? action,
    this.statusCode,
    Object? details,
    this.originalError,
    this.retryAt,
  }) : message = sanitizeExceptionText(message),
       action = action == null ? null : sanitizeExceptionText(action),
       details = _sanitizeDetails(details);

  /// A sanitized description of the failure.
  final String message;

  /// The CKAN action associated with this failure, when available.
  final String? action;

  /// The source HTTP status, when a response was received.
  final int? statusCode;

  /// Immutable server details with credential-bearing values redacted.
  final Object? details;

  /// The source's suggested retry time, absent when unknown.
  ///
  /// Available for quota and transient HTTP failures, including when the
  /// required delay exceeds the remaining operation deadline.
  final DateTime? retryAt;

  /// The original cause, retained for inspection and omitted from diagnostics.
  final Object? originalError;

  @override
  String toString() => '$runtimeType: $message';
}

/// The source rejected missing or invalid authentication credentials.
final class AuthenticationException extends DataGovException {
  /// Creates an authentication failure.
  AuthenticationException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// The source denied access to the requested data.
final class PermissionException extends DataGovException {
  /// Creates a permission failure.
  PermissionException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// The requested source entity or endpoint does not exist.
final class NotFoundException extends DataGovException {
  /// Creates a missing-entity failure.
  NotFoundException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// The source rejected invalid request parameters.
final class ValidationException extends DataGovException {
  /// Creates a validation failure.
  ValidationException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// A CKAN action returned an unsuccessful envelope.
final class CkanActionException extends DataGovException {
  /// Creates a CKAN action failure.
  CkanActionException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// A request failed at the network or HTTP transport layer.
final class NetworkException extends DataGovException {
  /// Creates a network failure.
  NetworkException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// A request exceeded its timeout or operation deadline.
final class RequestTimeoutException extends DataGovException {
  /// Creates a timeout failure.
  RequestTimeoutException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// The source rejected a request because its quota was exceeded.
final class RateLimitException extends DataGovException {
  /// Creates a quota failure.
  RateLimitException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// A resource's published format cannot be decoded by the requested parser.
final class UnsupportedFormatException extends DataGovException {
  /// Creates an unsupported-format failure.
  UnsupportedFormatException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// A resource cannot be used as the requested file or table source.
final class UnsupportedResourceException extends DataGovException {
  /// Creates an unsupported-resource failure.
  UnsupportedResourceException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// Source bytes or envelopes are malformed for the requested decoding.
final class DecodeException extends DataGovException {
  /// Creates a decoding failure.
  DecodeException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// A response exceeded the configured decoded-byte ceiling.
final class ByteLimitException extends DataGovException {
  /// Creates a byte-ceiling failure.
  ByteLimitException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// A source cannot continue a consistent paginated traversal.
final class PaginationException extends DataGovException {
  /// Creates a pagination failure.
  PaginationException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// An operation was cancelled before it could complete.
final class CancelledException extends DataGovException {
  /// Creates a cancellation failure.
  CancelledException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

/// Work was rejected because its client has already closed.
final class ClientClosedException extends DataGovException {
  /// Creates a closed-client failure.
  ClientClosedException(
    super.message, {
    super.action,
    super.statusCode,
    super.details,
    super.originalError,
    super.retryAt,
  });
}

bool _isSecretKey(String key) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
  return const {
        'authorization',
        'proxyauthorization',
        'cookie',
        'setcookie',
        'apikey',
        'xapikey',
        'password',
        'passwd',
        'secret',
        'token',
        'accesstoken',
        'refreshtoken',
        'clientsecret',
        'signature',
      }.contains(normalized) ||
      normalized.endsWith('token') ||
      normalized.endsWith('password') ||
      normalized.endsWith('secret') ||
      normalized.endsWith('signature') ||
      normalized.endsWith('credential') ||
      normalized == 'sig';
}

Object? _sanitizeDetails(Object? value) {
  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        sanitizeExceptionText(
          entry.key.toString(),
        ): _isSecretKey(entry.key.toString())
            ? '[REDACTED]'
            : _sanitizeDetails(entry.value),
    });
  }
  if (value is Iterable) {
    return List<Object?>.unmodifiable(value.map(_sanitizeDetails));
  }
  if (value == null || value is num || value is bool) {
    return value;
  }
  return sanitizeExceptionText(value.toString());
}

/// Redacts authentication headers, secret URL parameters, and URL user info.
String sanitizeExceptionText(String value) {
  var sanitized = value.replaceAllMapped(
    RegExp(r'https?://[^\s<>"]+', caseSensitive: false),
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
        if (uri == null) return '[REDACTED URL]$suffix';
        final parameters = uri.queryParametersAll;
        final safe = uri
            .replace(
              userInfo: '',
              queryParameters: parameters.isEmpty
                  ? null
                  : {
                      for (final entry in parameters.entries)
                        entry.key: _isSecretKey(entry.key)
                            ? ['[REDACTED]']
                            : entry.value,
                    },
            )
            .toString();
        return '$safe$suffix';
      } on FormatException {
        return '[REDACTED URL]$suffix';
      }
    },
  );
  sanitized = sanitized.replaceAllMapped(
    RegExp(
      r'\b(authorization|proxy-authorization|cookie|set-cookie|x-api-key|api[_-]?key)\s*[:=]\s*[^\r\n]+',
      caseSensitive: false,
    ),
    (match) => '${match[1]}: [REDACTED]',
  );
  return sanitized;
}

/// Adds a known CKAN action without changing a failure's concrete classification.
DataGovException exceptionWithAction(DataGovException error, String action) {
  if (error.action != null) return error;
  final create = switch (error) {
    AuthenticationException() => AuthenticationException.new,
    PermissionException() => PermissionException.new,
    NotFoundException() => NotFoundException.new,
    ValidationException() => ValidationException.new,
    CkanActionException() => CkanActionException.new,
    NetworkException() => NetworkException.new,
    RequestTimeoutException() => RequestTimeoutException.new,
    RateLimitException() => RateLimitException.new,
    UnsupportedFormatException() => UnsupportedFormatException.new,
    UnsupportedResourceException() => UnsupportedResourceException.new,
    DecodeException() => DecodeException.new,
    ByteLimitException() => ByteLimitException.new,
    PaginationException() => PaginationException.new,
    CancelledException() => CancelledException.new,
    ClientClosedException() => ClientClosedException.new,
  };
  return create(
    error.message,
    action: action,
    statusCode: error.statusCode,
    details: error.details,
    originalError: error.originalError,
    retryAt: error.retryAt,
  );
}
