import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_limit_status.freezed.dart';
part 'rate_limit_status.g.dart';

/// Represents the current rate limit status for the data.gov.gr API.
@freezed
class RateLimitStatus with _$RateLimitStatus {
  const factory RateLimitStatus({
    required int remaining,
    required int limit,
    required DateTime resetTime,
  }) = _RateLimitStatus;

  factory RateLimitStatus.fromJson(Map<String, dynamic> json) =>
      _$RateLimitStatusFromJson(json);

  factory RateLimitStatus.initial() => RateLimitStatus(
        remaining: 0,
        limit: 0,
        resetTime: DateTime.fromMillisecondsSinceEpoch(0),
      );
}
