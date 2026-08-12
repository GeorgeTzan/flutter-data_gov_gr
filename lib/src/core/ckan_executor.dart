import '../exceptions/data_gov_exception.dart';
import 'cancellation.dart';
import 'http_transport.dart';
import 'raw_json.dart';

/// Executes read-only CKAN actions and validates their response envelopes.
final class CkanExecutor {
  /// Uses the shared transport and selected action directory.
  CkanExecutor(this.transport, this.actionBase);

  /// The owning client's single HTTP pipeline.
  final HttpTransport transport;

  /// The selected CKAN action directory.
  final Uri actionBase;

  /// Returns the result exactly as represented by a successful envelope.
  Future<Object?> call(
    String action, {
    JsonObject parameters = const {},
    bool usePost = false,
    CancellationSignal? cancellation,
  }) async {
    transport.throwIfClosed();
    cancellation?.throwIfCancelled();
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(action)) {
      throw ValidationException('Invalid CKAN action.', action: action);
    }
    final JsonObject envelope;
    try {
      envelope = await transport.requestJson(
        actionBase.resolve(action),
        method: usePost ? 'POST' : 'GET',
        parameters: parameters,
        cancellation: cancellation,
        sendPortalCredentials: true,
      );
    } on DataGovException catch (error) {
      throw exceptionWithAction(error, action);
    }
    if (envelope['success'] == false) {
      final error = envelope['error'];
      if (error is Map && error['__type'] == 'Validation Error') {
        throw ValidationException(
          'CKAN action parameters were rejected.',
          action: action,
          statusCode: 200,
          details: error,
        );
      }
      throw CkanActionException(
        'CKAN action failed.',
        action: action,
        statusCode: 200,
        details: envelope['error'],
      );
    }
    if (envelope['success'] != true || !envelope.containsKey('result')) {
      throw DecodeException(
        'Invalid CKAN response envelope.',
        action: action,
        statusCode: 200,
      );
    }
    return envelope['result'];
  }
}
