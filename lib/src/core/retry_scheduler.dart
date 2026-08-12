import 'dart:math';

import '../client/data_gov_config.dart';

/// Computes read-only retry delays from server timing or bounded backoff.
final class RetryScheduler {
  /// Uses injected time and jitter for reproducible scheduling.
  RetryScheduler(this.policy, {required this.now, double Function()? jitter})
    : jitter = jitter ?? Random().nextDouble;

  /// The retry and deadline bounds.
  final RetryPolicy policy;

  /// The current operation time.
  final DateTime Function() now;

  /// A random sample between zero and one.
  final double Function() jitter;

  /// Parses Retry-After seconds or an RFC 1123 HTTP date.
  DateTime? retryAt(String? value) {
    if (value == null) return null;
    if (BigInt.tryParse(value.trim()) != null) {
      return timestampFromSeconds(value, relativeTo: now());
    }
    final match = RegExp(
      r'^\w{3}, (\d{2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
    ).firstMatch(value.trim());
    if (match == null) return null;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months.indexOf(match[2]!) + 1;
    if (month == 0) return null;
    return DateTime.utc(
      int.parse(match[3]!),
      month,
      int.parse(match[1]!),
      int.parse(match[4]!),
      int.parse(match[5]!),
      int.parse(match[6]!),
    );
  }

  /// Reads optional epoch seconds, or seconds relative to [relativeTo].
  ///
  /// Invalid, negative, or unrepresentable hints remain unavailable. Checked
  /// arithmetic prevents native integer overflow and browser precision loss.
  static DateTime? timestampFromSeconds(String? value, {DateTime? relativeTo}) {
    if (value == null) return null;
    final seconds = BigInt.tryParse(value.trim());
    if (seconds == null || seconds.isNegative) return null;
    final micros = seconds * BigInt.from(Duration.microsecondsPerSecond);
    if (micros > BigInt.parse('9223372036854775807')) return null;
    final base = relativeTo == null
        ? BigInt.zero
        : BigInt.from(relativeTo.microsecondsSinceEpoch);
    final timestamp = base + micros;
    final bound = BigInt.parse('8640000000000000000');
    if (timestamp < -bound || timestamp > bound) return null;
    return DateTime.fromMicrosecondsSinceEpoch(
      timestamp.toInt(),
      isUtc: relativeTo?.isUtc ?? true,
    );
  }

  /// Computes delay after [attempt], where the initial request is attempt one.
  Duration delay(int attempt, {DateTime? retryAt}) {
    if (retryAt != null) {
      final delay = retryAt.difference(now());
      return delay.isNegative ? Duration.zero : delay;
    }
    final initialMicros = policy.initialBackoff.inMicroseconds;
    if (initialMicros == 0) return Duration.zero;
    final sample = jitter().clamp(0.0, 1.0);
    final cap = policy.maxBackoff.inMicroseconds;
    var micros = initialMicros.toDouble() * (0.5 + sample);
    var remaining = attempt - 1;
    while (remaining > 0 && micros < cap) {
      micros *= 2;
      remaining--;
    }
    if (micros >= cap) return policy.maxBackoff;
    return Duration(microseconds: micros.round());
  }
}
