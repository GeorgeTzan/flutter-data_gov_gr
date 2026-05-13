// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_limit_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RateLimitStatusImpl _$$RateLimitStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$RateLimitStatusImpl(
      remaining: (json['remaining'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      resetTime: DateTime.parse(json['resetTime'] as String),
    );

Map<String, dynamic> _$$RateLimitStatusImplToJson(
        _$RateLimitStatusImpl instance) =>
    <String, dynamic>{
      'remaining': instance.remaining,
      'limit': instance.limit,
      'resetTime': instance.resetTime.toIso8601String(),
    };
