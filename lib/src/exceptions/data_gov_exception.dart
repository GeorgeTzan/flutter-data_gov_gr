/// Base class for all exceptions thrown by the data.gov.gr SDK.
sealed class DataGovException implements Exception {
  /// A human-readable message describing the error.
  final String message;

  /// The original object that caused the exception, if any.
  final Object? originalError;

  const DataGovException(this.message, [this.originalError]);

  @override
  String toString() => 'DataGovException: $message';
}

/// Thrown when the API token is invalid or missing.
class UnauthorizedException extends DataGovException {
  const UnauthorizedException([Object? originalError])
      : super('Unauthorized: Invalid or missing API token.', originalError);
}

/// Thrown when the rate limit for the API is exceeded.
class RateLimitException extends DataGovException {
  const RateLimitException([Object? originalError])
      : super('Rate Limit Exceeded: Please slow down your requests.', originalError);
}

/// Thrown when the government server returns a 5xx error.
class ServerException extends DataGovException {
  const ServerException([String message = 'Internal Server Error.', Object? originalError])
      : super(message, originalError);
}

/// Thrown when there is a network-level issue (e.g., connection timeout).
class NetworkException extends DataGovException {
  const NetworkException(String message, [Object? originalError])
      : super(message, originalError);
}

/// Thrown for any other unexpected errors.
class UnknownException extends DataGovException {
  const UnknownException(String message, [Object? originalError])
      : super(message, originalError);
}
