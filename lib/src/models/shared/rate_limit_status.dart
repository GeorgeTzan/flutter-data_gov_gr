import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_limit_status.freezed.dart';
part 'rate_limit_status.g.dart';

/// Represents the current rate limit status for the data.gov.gr API.
@freezed
class RateLimitStatus with _$RateLimitStatus {
  const factory RateLimitStatus({
    /// The number of requests remaining in the current window.
    required int remaining,

    /// The maximum number of requests allowed in a window.
    required int limit,

    /// The time when the rate limit window will reset.
    required DateTime resetTime,
  }) = _RateLimitStatus;

  factory RateLimitStatus.fromJson(Map<String, dynamic> json) =>
      _$RateLimitStatusFromJson(json);

  /// Initial status when no requests have been made yet.
  factory RateLimitStatus.initial() => RateLimitStatus(
        remaining: 0,
        limit: 0,
        resetTime: DateTime.fromMillisecondsSinceEpoch(0),
      );
}
