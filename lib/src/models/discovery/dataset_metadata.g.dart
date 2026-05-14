// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataset_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DatasetMetadataImpl _$$DatasetMetadataImplFromJson(
        Map<String, dynamic> json) =>
    _$DatasetMetadataImpl(
      identifier: json['identifier'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      keyword:
          (json['keyword'] as List<dynamic>).map((e) => e as String).toList(),
      modified: DateTime.parse(json['modified'] as String),
      publisher: json['publisher'] as String,
      contactPoint: json['contact_point'] as String?,
      spatial: json['spatial'] as String,
      temporal: json['temporal'] as String,
      accrualPeriodicity: json['accrual_periodicity'] as String?,
    );

Map<String, dynamic> _$$DatasetMetadataImplToJson(
        _$DatasetMetadataImpl instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'title': instance.title,
      'description': instance.description,
      'keyword': instance.keyword,
      'modified': instance.modified.toIso8601String(),
      'publisher': instance.publisher,
      'contact_point': instance.contactPoint,
      'spatial': instance.spatial,
      'temporal': instance.temporal,
      'accrual_periodicity': instance.accrualPeriodicity,
    };
