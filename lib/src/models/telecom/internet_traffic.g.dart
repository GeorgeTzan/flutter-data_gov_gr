// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internet_traffic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InternetTrafficImpl _$$InternetTrafficImplFromJson(
        Map<String, dynamic> json) =>
    _$InternetTrafficImpl(
      date: DateTime.parse(json['date'] as String),
      inbound: (json['inbound'] as num).toDouble(),
      outbound: (json['outbound'] as num).toDouble(),
      totalTraffic: (json['total_traffic'] as num).toDouble(),
    );

Map<String, dynamic> _$$InternetTrafficImplToJson(
        _$InternetTrafficImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'inbound': instance.inbound,
      'outbound': instance.outbound,
      'total_traffic': instance.totalTraffic,
    };
