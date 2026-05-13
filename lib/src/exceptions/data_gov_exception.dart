sealed class DataGovException implements Exception {
  final String message;
  final Object? originalError;

  const DataGovException(this.message, [this.originalError]);

  @override
  String toString() => 'DataGovException: $message';
}

class UnauthorizedException extends DataGovException {
  const UnauthorizedException([Object? originalError])
      : super('Unauthorized: Invalid or missing API token.', originalError);
}

class RateLimitException extends DataGovException {
  const RateLimitException([Object? originalError])
      : super('Rate Limit Exceeded: Please slow down your requests.', originalError);
}

class ServerException extends DataGovException {
  const ServerException([String message = 'Internal Server Error.', Object? originalError])
      : super(message, originalError);
}

class NetworkException extends DataGovException {
  const NetworkException(String message, [Object? originalError])
      : super(message, originalError);
}

class UnknownException extends DataGovException {
  const UnknownException(String message, [Object? originalError])
      : super(message, originalError);
}
