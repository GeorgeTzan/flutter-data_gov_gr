// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internet_traffic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InternetTraffic _$InternetTrafficFromJson(Map<String, dynamic> json) =>
    _InternetTraffic(
      date: const SourceDateConverter().fromJson(json['date'] as String),
      avgIn: json['avg_in'] as num?,
      avgOut: json['avg_out'] as num?,
      maxIn: json['max_in'] as num?,
      maxOut: json['max_out'] as num?,
      raw: const ImmutableSourceConverter().fromJson(
        json['raw'] as Map<String, dynamic>,
      ),
      provenance: const SourceProvenanceConverter().fromJson(
        json['provenance'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$InternetTrafficToJson(
  _InternetTraffic instance,
) => <String, dynamic>{
  'date': const SourceDateConverter().toJson(instance.date),
  'avg_in': instance.avgIn,
  'avg_out': instance.avgOut,
  'max_in': instance.maxIn,
  'max_out': instance.maxOut,
  'raw': const ImmutableSourceConverter().toJson(instance.raw),
  'provenance': const SourceProvenanceConverter().toJson(instance.provenance),
};
