/// Base class for all exceptions thrown by the data.gov.gr SDK.
sealed class DataGovException implements Exception {
  /// The error message describing the exception.
  final String message;

  /// The underlying cause of the exception, if any.
  final Object? originalError;

  /// Creates a new [DataGovException] instance.
  const DataGovException(this.message, [this.originalError]);

  @override
  String toString() => 'DataGovException: $message';
}

/// Exception thrown when the API request is unauthorized (invalid or missing API key).
class UnauthorizedException extends DataGovException {
  /// Creates a new [UnauthorizedException] instance.
  const UnauthorizedException([Object? originalError])
      : super('Unauthorized: Invalid or missing API token.', originalError);
}

/// Exception thrown when the API rate limit is exceeded.
class RateLimitException extends DataGovException {
  /// Creates a new [RateLimitException] instance.
  const RateLimitException([Object? originalError])
      : super('Rate Limit Exceeded: Please slow down your requests.',
            originalError);
}

/// Exception thrown when the server returns an internal error.
class ServerException extends DataGovException {
  /// Creates a new [ServerException] instance.
  const ServerException(
      [super.message = 'Internal Server Error.', super.originalError]);
}

/// Exception thrown when there is a network-level failure.
class NetworkException extends DataGovException {
  /// Creates a new [NetworkException] instance.
  const NetworkException(super.message, [super.originalError]);
}

/// Exception thrown for any unhandled or unknown failures.
class UnknownException extends DataGovException {
  /// Creates a new [UnknownException] instance.
  const UnknownException(super.message, [super.originalError]);
}
