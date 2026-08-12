// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_limit_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RateLimitStatus _$RateLimitStatusFromJson(Map<String, dynamic> json) =>
    _RateLimitStatus(
      limit: (json['limit'] as num?)?.toInt(),
      remaining: (json['remaining'] as num?)?.toInt(),
      resetAt: json['resetAt'] == null
          ? null
          : DateTime.parse(json['resetAt'] as String),
    );

Map<String, dynamic> _$RateLimitStatusToJson(_RateLimitStatus instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'remaining': instance.remaining,
      'resetAt': instance.resetAt?.toIso8601String(),
    };
