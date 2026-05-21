import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_limit_status.freezed.dart';
part 'rate_limit_status.g.dart';

/// Represents the current rate limit status for the data.gov.gr API.
@freezed
class RateLimitStatus with _$RateLimitStatus {
  /// Creates a new [RateLimitStatus] instance.
  const factory RateLimitStatus({
    /// The number of remaining requests allowed in the current time window.
    required int remaining,

    /// The maximum number of requests allowed in the time window.
    required int limit,

    /// The time at which the current rate limit resets.
    required DateTime resetTime,
  }) = _RateLimitStatus;

  /// Creates a [RateLimitStatus] from a JSON map.
  factory RateLimitStatus.fromJson(Map<String, dynamic> json) =>
      _$RateLimitStatusFromJson(json);

  /// Creates an initial [RateLimitStatus] instance with zero limits.
  factory RateLimitStatus.initial() => RateLimitStatus(
        remaining: 0,
        limit: 0,
        resetTime: DateTime.fromMillisecondsSinceEpoch(0),
      );
}
