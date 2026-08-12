import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/raw_json.dart';
import '../shared/source_converters.dart';
import '../shared/source_date.dart';
import '../shared/source_provenance.dart';

part 'forest_fire.freezed.dart';
part 'forest_fire.g.dart';

/// Published environment source values, retaining raw cells and source provenance.
///
/// Numeric units are retained as published and are not inferred or converted.
@freezed
abstract class ForestFire with _$ForestFire {
  /// Creates source values; optional cells remain nullable.
  const factory ForestFire({
    /// The published `start_time` value.
    @SourceDateConverter()
    @JsonKey(name: 'start_time')
    required SourceDate startTime,

    /// The published `end_time` value.
    @SourceDateConverter() @JsonKey(name: 'end_time') SourceDate? endTime,

    /// The published `fire_station` value.
    @JsonKey(name: 'fire_station') String? fireStation,

    /// The published `prefecture` value.
    String? prefecture,

    /// The published `forestry` value.
    String? forestry,

    /// The published `municipality` value.
    String? municipality,

    /// The published `location` value.
    String? location,

    /// The published `address` value.
    String? address,

    /// The published `forest_area_burned` value.
    @JsonKey(name: 'forest_area_burned') num? forestAreaBurned,

    /// The published `woodland_area_burned` value.
    @JsonKey(name: 'woodland_area_burned') num? woodlandAreaBurned,

    /// The published `grove_area_burned` value.
    @JsonKey(name: 'grove_area_burned') num? groveAreaBurned,

    /// The published `low_vegetation_area_burned` value.
    @JsonKey(name: 'low_vegetation_area_burned') num? lowVegetationAreaBurned,

    /// The published `swamp_area_burned` value.
    @JsonKey(name: 'swamp_area_burned') num? swampAreaBurned,

    /// The published `agricultural_area_burned` value.
    @JsonKey(name: 'agricultural_area_burned') num? agriculturalAreaBurned,

    /// The published `crop_residue_area_burned` value.
    @JsonKey(name: 'crop_residue_area_burned') num? cropResidueAreaBurned,

    /// The published `dumping_ground_area_burned` value.
    @JsonKey(name: 'dumping_ground_area_burned') num? dumpingGroundAreaBurned,

    /// The published `firefighters` value.
    int? firefighters,

    /// The published `wildland_crew` value.
    @JsonKey(name: 'wildland_crew') int? wildlandCrew,

    /// The published `volunteers` value.
    int? volunteers,

    /// The published `army` value.
    int? army,

    /// The published `other_firefighters` value.
    @JsonKey(name: 'other_firefighters') int? otherFirefighters,

    /// The published `fire_trucks` value.
    @JsonKey(name: 'fire_trucks') int? fireTrucks,

    /// The published `local_authorities_vehicles` value.
    @JsonKey(name: 'local_authorities_vehicles') int? localAuthoritiesVehicles,

    /// The published `water_tank_trucks` value.
    @JsonKey(name: 'water_tank_trucks') int? waterTankTrucks,

    /// The published `machinery` value.
    int? machinery,

    /// The published `helicopters` value.
    int? helicopters,

    /// The published `airplanes_cl415` value.
    @JsonKey(name: 'airplanes_cl415') int? airplanesCl415,

    /// The published `airplanes_cl215` value.
    @JsonKey(name: 'airplanes_cl215') int? airplanesCl215,

    /// The published `airplanes_pzl` value.
    @JsonKey(name: 'airplanes_pzl') int? airplanesPzl,

    /// The published `airplanes_gru` value.
    @JsonKey(name: 'airplanes_gru') int? airplanesGru,

    /// Immutable original source cells, including unknown columns.
    @ImmutableSourceConverter() required JsonObject raw,

    /// Selected source identity and measured retrieval time.
    @SourceProvenanceConverter() required SourceProvenance provenance,
  }) = _ForestFire;

  /// Restores the serialized model and its explicit source metadata.
  factory ForestFire.fromJson(Map<String, dynamic> json) =>
      _$ForestFireFromJson(json);

  /// Decodes documented source columns with field and row error context.
  factory ForestFire.fromSourceRecord(
    JsonObject record, {
    required SourceProvenance provenance,
  }) {
    final source = SourceRecordDecoder(record, provenance);
    return ForestFire(
      startTime: source.date('start_time'),
      endTime: source.optionalDate('end_time'),
      fireStation: source.optionalString('fire_station'),
      prefecture: source.optionalString('prefecture'),
      forestry: source.optionalString('forestry'),
      municipality: source.optionalString('municipality'),
      location: source.optionalString('location'),
      address: source.optionalString('address'),
      forestAreaBurned: source.number('forest_area_burned'),
      woodlandAreaBurned: source.number('woodland_area_burned'),
      groveAreaBurned: source.number('grove_area_burned'),
      lowVegetationAreaBurned: source.number('low_vegetation_area_burned'),
      swampAreaBurned: source.number('swamp_area_burned'),
      agriculturalAreaBurned: source.number('agricultural_area_burned'),
      cropResidueAreaBurned: source.number('crop_residue_area_burned'),
      dumpingGroundAreaBurned: source.number('dumping_ground_area_burned'),
      firefighters: source.integer('firefighters'),
      wildlandCrew: source.integer('wildland_crew'),
      volunteers: source.integer('volunteers'),
      army: source.integer('army'),
      otherFirefighters: source.integer('other_firefighters'),
      fireTrucks: source.integer('fire_trucks'),
      localAuthoritiesVehicles: source.integer('local_authorities_vehicles'),
      waterTankTrucks: source.integer('water_tank_trucks'),
      machinery: source.integer('machinery'),
      helicopters: source.integer('helicopters'),
      airplanesCl415: source.integer('airplanes_cl415'),
      airplanesCl215: source.integer('airplanes_cl215'),
      airplanesPzl: source.integer('airplanes_pzl'),
      airplanesGru: source.integer('airplanes_gru'),
      raw: freezeJson(record),
      provenance: provenance,
    );
  }
}
