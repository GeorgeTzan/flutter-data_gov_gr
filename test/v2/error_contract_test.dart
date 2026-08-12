import 'package:data_gov_gr/src/exceptions/data_gov_exception.dart';
import 'package:data_gov_gr/src/models/shared/rate_limit_status.dart';
import 'package:test/test.dart';

void main() {
  test('exceptions_preserve_sanitized_context', () {
    final original = StateError('underlying cause');
    final details = {
      'message': 'invalid resource',
      'Authorization': 'Bearer hidden-bearer',
      'nested': {
        'api_key': 'hidden-key',
        'url':
            'https://user:pass@example.test/data?token=hidden-token&limit=10',
      },
      'errors': ['Cookie: hidden-cookie', 'safe detail'],
    };
    final error = CkanActionException(
      'request failed',
      action: 'package_show',
      statusCode: 200,
      details: details,
      originalError: original,
    );
    expect(error.message, 'request failed');
    expect(error.action, 'package_show');
    expect(error.statusCode, 200);
    expect(error.originalError, same(original));
    expect(error.details, isA<Map>());
    expect((error.details as Map)['message'], 'invalid resource');
    final diagnostic = error.details.toString();
    for (final secret in [
      'hidden-bearer',
      'hidden-key',
      'hidden-token',
      'hidden-cookie',
      'user:pass',
    ]) {
      expect(diagnostic, isNot(contains(secret)));
      expect(error.toString(), isNot(contains(secret)));
    }
    expect(diagnostic, contains('limit=10'));
    expect(diagnostic, contains('safe detail'));
    (details['nested'] as Map)['api_key'] = 'changed';
    expect(error.details.toString(), isNot(contains('changed')));
    expect(
      () => (error.details as Map)['message'] = 'changed',
      throwsUnsupportedError,
    );
  });

  test('exception_text_redacts_url_and_header_secrets', () {
    final error = NetworkException(
      'GET https://example.test/?api_key=hidden-query failed; '
      'Authorization: Bearer hidden-header',
      details: 'https://user:password@example.test/?access_token=hidden-access',
    );
    for (final secret in [
      'hidden-query',
      'hidden-header',
      'password',
      'hidden-access',
    ]) {
      expect(
        '${error.message} ${error.details} $error',
        isNot(contains(secret)),
      );
    }
  });

  test('rate_limit_error_retains_optional_retry_time', () {
    final retryAt = DateTime.utc(2026, 10, 11);
    final error = RateLimitException(
      'slow down',
      retryAt: retryAt,
      statusCode: 429,
    );
    expect(error.retryAt, retryAt);
    expect(error.statusCode, 429);
    expect(RateLimitException('slow down').retryAt, isNull);
  });

  test('malformed_secret_urls_do_not_replace_the_original_failure', () {
    final original = StateError('source failure');
    final error = NetworkException(
      'GET https://example.test/?token=%FF failed',
      originalError: original,
    );
    expect(error.originalError, same(original));
    expect(error.message, isNot(contains('%FF')));
  });

  test('rate_status_without_headers_is_unavailable', () {
    const status = RateLimitStatus();
    expect(status.available, isFalse);
    expect(status.limit, isNull);
    expect(status.remaining, isNull);
    expect(status.resetAt, isNull);
    expect(RateLimitStatus.fromJson({}), status);
    expect(RateLimitStatus.initial(), status);
  });

  test('partial_rate_status_preserves_unknown_quota_fields', () {
    const status = RateLimitStatus(remaining: 0);
    expect(status.available, isTrue);
    expect(status.limit, isNull);
    expect(status.resetAt, isNull);
    expect(RateLimitStatus.fromJson(status.toJson()), status);
    final reset = DateTime.utc(2026, 10, 11);
    expect(RateLimitStatus(resetAt: reset).available, isFalse);
    expect(const RateLimitStatus(limit: -1).available, isFalse);
  });
}
