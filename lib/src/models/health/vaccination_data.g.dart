// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VaccinationData _$VaccinationDataFromJson(Map<String, dynamic> json) =>
    _VaccinationData(
      area: json['area'] as String,
      areaId: json['areaid'] as String,
      referenceDate: const SourceDateConverter().fromJson(
        json['referencedate'] as String,
      ),
      dayTotal: (json['daytotal'] as num?)?.toInt(),
      dayDiff: (json['daydiff'] as num?)?.toInt(),
      totalVaccinations: (json['totalvaccinations'] as num?)?.toInt(),
      totalDistinctPersons: (json['totaldistinctpersons'] as num?)?.toInt(),
      dailyDose1: (json['dailydose1'] as num?)?.toInt(),
      dailyDose2: (json['dailydose2'] as num?)?.toInt(),
      dailyDose3: (json['dailydose3'] as num?)?.toInt(),
      totalDose1: (json['totaldose1'] as num?)?.toInt(),
      totalDose2: (json['totaldose2'] as num?)?.toInt(),
      totalDose3: (json['totaldose3'] as num?)?.toInt(),
      raw: const ImmutableSourceConverter().fromJson(
        json['raw'] as Map<String, dynamic>,
      ),
      provenance: const SourceProvenanceConverter().fromJson(
        json['provenance'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$VaccinationDataToJson(
  _VaccinationData instance,
) => <String, dynamic>{
  'area': instance.area,
  'areaid': instance.areaId,
  'referencedate': const SourceDateConverter().toJson(instance.referenceDate),
  'daytotal': instance.dayTotal,
  'daydiff': instance.dayDiff,
  'totalvaccinations': instance.totalVaccinations,
  'totaldistinctpersons': instance.totalDistinctPersons,
  'dailydose1': instance.dailyDose1,
  'dailydose2': instance.dailyDose2,
  'dailydose3': instance.dailyDose3,
  'totaldose1': instance.totalDose1,
  'totaldose2': instance.totalDose2,
  'totaldose3': instance.totalDose3,
  'raw': const ImmutableSourceConverter().toJson(instance.raw),
  'provenance': const SourceProvenanceConverter().toJson(instance.provenance),
};
