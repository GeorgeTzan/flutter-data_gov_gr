// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VaccinationDataImpl _$$VaccinationDataImplFromJson(
        Map<String, dynamic> json) =>
    _$VaccinationDataImpl(
      area: json['area'] as String,
      areaId: (json['areaid'] as num).toInt(),
      dailyDose1: (json['dailydose1'] as num).toInt(),
      dailyDose2: (json['dailydose2'] as num).toInt(),
      dayDiff: (json['daydiff'] as num).toInt(),
      dayTotal: (json['daytotal'] as num).toInt(),
      referenceDate: DateTime.parse(json['referencedate'] as String),
      totalDose1: (json['totaldose1'] as num).toInt(),
      totalDose2: (json['totaldose2'] as num).toInt(),
      totalVaccinations: (json['totalvaccinations'] as num).toInt(),
    );

Map<String, dynamic> _$$VaccinationDataImplToJson(
        _$VaccinationDataImpl instance) =>
    <String, dynamic>{
      'area': instance.area,
      'areaid': instance.areaId,
      'dailydose1': instance.dailyDose1,
      'dailydose2': instance.dailyDose2,
      'daydiff': instance.dayDiff,
      'daytotal': instance.dayTotal,
      'referencedate': instance.referenceDate.toIso8601String(),
      'totaldose1': instance.totalDose1,
      'totaldose2': instance.totalDose2,
      'totalvaccinations': instance.totalVaccinations,
    };
