import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_limit_status.freezed.dart';
part 'rate_limit_status.g.dart';

/// Published request quota information, with unknown values left absent.
@freezed
abstract class RateLimitStatus with _$RateLimitStatus {
  const RateLimitStatus._();

  /// Creates a status from the quota fields that the server actually supplied.
  const factory RateLimitStatus({
    /// The maximum requests allowed in the current quota window.
    int? limit,

    /// Requests remaining in the current quota window.
    int? remaining,

    /// The published quota reset time, if available.
    DateTime? resetAt,
  }) = _RateLimitStatus;

  /// Reads published quota fields without defaulting absent fields to zero.
  factory RateLimitStatus.fromJson(Map<String, dynamic> json) =>
      _$RateLimitStatusFromJson(json);

  /// Creates an explicit unavailable status before any quota was published.
  factory RateLimitStatus.initial() => const RateLimitStatus();

  /// Whether at least one usable quota value was published.
  bool get available =>
      (limit != null && limit! >= 0) || (remaining != null && remaining! >= 0);
}
