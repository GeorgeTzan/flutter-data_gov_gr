// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forest_fire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForestFire _$ForestFireFromJson(Map<String, dynamic> json) => _ForestFire(
  startTime: const SourceDateConverter().fromJson(json['start_time'] as String),
  endTime: _$JsonConverterFromJson<String, SourceDate>(
    json['end_time'],
    const SourceDateConverter().fromJson,
  ),
  fireStation: json['fire_station'] as String?,
  prefecture: json['prefecture'] as String?,
  forestry: json['forestry'] as String?,
  municipality: json['municipality'] as String?,
  location: json['location'] as String?,
  address: json['address'] as String?,
  forestAreaBurned: json['forest_area_burned'] as num?,
  woodlandAreaBurned: json['woodland_area_burned'] as num?,
  groveAreaBurned: json['grove_area_burned'] as num?,
  lowVegetationAreaBurned: json['low_vegetation_area_burned'] as num?,
  swampAreaBurned: json['swamp_area_burned'] as num?,
  agriculturalAreaBurned: json['agricultural_area_burned'] as num?,
  cropResidueAreaBurned: json['crop_residue_area_burned'] as num?,
  dumpingGroundAreaBurned: json['dumping_ground_area_burned'] as num?,
  firefighters: (json['firefighters'] as num?)?.toInt(),
  wildlandCrew: (json['wildland_crew'] as num?)?.toInt(),
  volunteers: (json['volunteers'] as num?)?.toInt(),
  army: (json['army'] as num?)?.toInt(),
  otherFirefighters: (json['other_firefighters'] as num?)?.toInt(),
  fireTrucks: (json['fire_trucks'] as num?)?.toInt(),
  localAuthoritiesVehicles: (json['local_authorities_vehicles'] as num?)
      ?.toInt(),
  waterTankTrucks: (json['water_tank_trucks'] as num?)?.toInt(),
  machinery: (json['machinery'] as num?)?.toInt(),
  helicopters: (json['helicopters'] as num?)?.toInt(),
  airplanesCl415: (json['airplanes_cl415'] as num?)?.toInt(),
  airplanesCl215: (json['airplanes_cl215'] as num?)?.toInt(),
  airplanesPzl: (json['airplanes_pzl'] as num?)?.toInt(),
  airplanesGru: (json['airplanes_gru'] as num?)?.toInt(),
  raw: const ImmutableSourceConverter().fromJson(
    json['raw'] as Map<String, dynamic>,
  ),
  provenance: const SourceProvenanceConverter().fromJson(
    json['provenance'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ForestFireToJson(
  _ForestFire instance,
) => <String, dynamic>{
  'start_time': const SourceDateConverter().toJson(instance.startTime),
  'end_time': _$JsonConverterToJson<String, SourceDate>(
    instance.endTime,
    const SourceDateConverter().toJson,
  ),
  'fire_station': instance.fireStation,
  'prefecture': instance.prefecture,
  'forestry': instance.forestry,
  'municipality': instance.municipality,
  'location': instance.location,
  'address': instance.address,
  'forest_area_burned': instance.forestAreaBurned,
  'woodland_area_burned': instance.woodlandAreaBurned,
  'grove_area_burned': instance.groveAreaBurned,
  'low_vegetation_area_burned': instance.lowVegetationAreaBurned,
  'swamp_area_burned': instance.swampAreaBurned,
  'agricultural_area_burned': instance.agriculturalAreaBurned,
  'crop_residue_area_burned': instance.cropResidueAreaBurned,
  'dumping_ground_area_burned': instance.dumpingGroundAreaBurned,
  'firefighters': instance.firefighters,
  'wildland_crew': instance.wildlandCrew,
  'volunteers': instance.volunteers,
  'army': instance.army,
  'other_firefighters': instance.otherFirefighters,
  'fire_trucks': instance.fireTrucks,
  'local_authorities_vehicles': instance.localAuthoritiesVehicles,
  'water_tank_trucks': instance.waterTankTrucks,
  'machinery': instance.machinery,
  'helicopters': instance.helicopters,
  'airplanes_cl415': instance.airplanesCl415,
  'airplanes_cl215': instance.airplanesCl215,
  'airplanes_pzl': instance.airplanesPzl,
  'airplanes_gru': instance.airplanesGru,
  'raw': const ImmutableSourceConverter().toJson(instance.raw),
  'provenance': const SourceProvenanceConverter().toJson(instance.provenance),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
