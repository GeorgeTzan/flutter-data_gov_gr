// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forest_fire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ForestFireImpl _$$ForestFireImplFromJson(Map<String, dynamic> json) =>
    _$ForestFireImpl(
      date: DateTime.parse(json['date'] as String),
      area: (json['area'] as num).toDouble(),
      location: json['location'] as String,
      fireType: json['fire_type'] as String?,
      cause: json['cause'] as String?,
    );

Map<String, dynamic> _$$ForestFireImplToJson(_$ForestFireImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'area': instance.area,
      'location': instance.location,
      'fire_type': instance.fireType,
      'cause': instance.cause,
    };
