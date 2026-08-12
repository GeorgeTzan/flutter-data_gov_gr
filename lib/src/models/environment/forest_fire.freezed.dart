// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forest_fire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ForestFire {

/// The published `start_time` value.
@SourceDateConverter()@JsonKey(name: 'start_time') SourceDate get startTime;/// The published `end_time` value.
@SourceDateConverter()@JsonKey(name: 'end_time') SourceDate? get endTime;/// The published `fire_station` value.
@JsonKey(name: 'fire_station') String? get fireStation;/// The published `prefecture` value.
 String? get prefecture;/// The published `forestry` value.
 String? get forestry;/// The published `municipality` value.
 String? get municipality;/// The published `location` value.
 String? get location;/// The published `address` value.
 String? get address;/// The published `forest_area_burned` value.
@JsonKey(name: 'forest_area_burned') num? get forestAreaBurned;/// The published `woodland_area_burned` value.
@JsonKey(name: 'woodland_area_burned') num? get woodlandAreaBurned;/// The published `grove_area_burned` value.
@JsonKey(name: 'grove_area_burned') num? get groveAreaBurned;/// The published `low_vegetation_area_burned` value.
@JsonKey(name: 'low_vegetation_area_burned') num? get lowVegetationAreaBurned;/// The published `swamp_area_burned` value.
@JsonKey(name: 'swamp_area_burned') num? get swampAreaBurned;/// The published `agricultural_area_burned` value.
@JsonKey(name: 'agricultural_area_burned') num? get agriculturalAreaBurned;/// The published `crop_residue_area_burned` value.
@JsonKey(name: 'crop_residue_area_burned') num? get cropResidueAreaBurned;/// The published `dumping_ground_area_burned` value.
@JsonKey(name: 'dumping_ground_area_burned') num? get dumpingGroundAreaBurned;/// The published `firefighters` value.
 int? get firefighters;/// The published `wildland_crew` value.
@JsonKey(name: 'wildland_crew') int? get wildlandCrew;/// The published `volunteers` value.
 int? get volunteers;/// The published `army` value.
 int? get army;/// The published `other_firefighters` value.
@JsonKey(name: 'other_firefighters') int? get otherFirefighters;/// The published `fire_trucks` value.
@JsonKey(name: 'fire_trucks') int? get fireTrucks;/// The published `local_authorities_vehicles` value.
@JsonKey(name: 'local_authorities_vehicles') int? get localAuthoritiesVehicles;/// The published `water_tank_trucks` value.
@JsonKey(name: 'water_tank_trucks') int? get waterTankTrucks;/// The published `machinery` value.
 int? get machinery;/// The published `helicopters` value.
 int? get helicopters;/// The published `airplanes_cl415` value.
@JsonKey(name: 'airplanes_cl415') int? get airplanesCl415;/// The published `airplanes_cl215` value.
@JsonKey(name: 'airplanes_cl215') int? get airplanesCl215;/// The published `airplanes_pzl` value.
@JsonKey(name: 'airplanes_pzl') int? get airplanesPzl;/// The published `airplanes_gru` value.
@JsonKey(name: 'airplanes_gru') int? get airplanesGru;/// Immutable original source cells, including unknown columns.
@ImmutableSourceConverter() JsonObject get raw;/// Selected source identity and measured retrieval time.
@SourceProvenanceConverter() SourceProvenance get provenance;
/// Create a copy of ForestFire
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForestFireCopyWith<ForestFire> get copyWith => _$ForestFireCopyWithImpl<ForestFire>(this as ForestFire, _$identity);

  /// Serializes this ForestFire to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForestFire&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.fireStation, fireStation) || other.fireStation == fireStation)&&(identical(other.prefecture, prefecture) || other.prefecture == prefecture)&&(identical(other.forestry, forestry) || other.forestry == forestry)&&(identical(other.municipality, municipality) || other.municipality == municipality)&&(identical(other.location, location) || other.location == location)&&(identical(other.address, address) || other.address == address)&&(identical(other.forestAreaBurned, forestAreaBurned) || other.forestAreaBurned == forestAreaBurned)&&(identical(other.woodlandAreaBurned, woodlandAreaBurned) || other.woodlandAreaBurned == woodlandAreaBurned)&&(identical(other.groveAreaBurned, groveAreaBurned) || other.groveAreaBurned == groveAreaBurned)&&(identical(other.lowVegetationAreaBurned, lowVegetationAreaBurned) || other.lowVegetationAreaBurned == lowVegetationAreaBurned)&&(identical(other.swampAreaBurned, swampAreaBurned) || other.swampAreaBurned == swampAreaBurned)&&(identical(other.agriculturalAreaBurned, agriculturalAreaBurned) || other.agriculturalAreaBurned == agriculturalAreaBurned)&&(identical(other.cropResidueAreaBurned, cropResidueAreaBurned) || other.cropResidueAreaBurned == cropResidueAreaBurned)&&(identical(other.dumpingGroundAreaBurned, dumpingGroundAreaBurned) || other.dumpingGroundAreaBurned == dumpingGroundAreaBurned)&&(identical(other.firefighters, firefighters) || other.firefighters == firefighters)&&(identical(other.wildlandCrew, wildlandCrew) || other.wildlandCrew == wildlandCrew)&&(identical(other.volunteers, volunteers) || other.volunteers == volunteers)&&(identical(other.army, army) || other.army == army)&&(identical(other.otherFirefighters, otherFirefighters) || other.otherFirefighters == otherFirefighters)&&(identical(other.fireTrucks, fireTrucks) || other.fireTrucks == fireTrucks)&&(identical(other.localAuthoritiesVehicles, localAuthoritiesVehicles) || other.localAuthoritiesVehicles == localAuthoritiesVehicles)&&(identical(other.waterTankTrucks, waterTankTrucks) || other.waterTankTrucks == waterTankTrucks)&&(identical(other.machinery, machinery) || other.machinery == machinery)&&(identical(other.helicopters, helicopters) || other.helicopters == helicopters)&&(identical(other.airplanesCl415, airplanesCl415) || other.airplanesCl415 == airplanesCl415)&&(identical(other.airplanesCl215, airplanesCl215) || other.airplanesCl215 == airplanesCl215)&&(identical(other.airplanesPzl, airplanesPzl) || other.airplanesPzl == airplanesPzl)&&(identical(other.airplanesGru, airplanesGru) || other.airplanesGru == airplanesGru)&&const DeepCollectionEquality().equals(other.raw, raw)&&(identical(other.provenance, provenance) || other.provenance == provenance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,startTime,endTime,fireStation,prefecture,forestry,municipality,location,address,forestAreaBurned,woodlandAreaBurned,groveAreaBurned,lowVegetationAreaBurned,swampAreaBurned,agriculturalAreaBurned,cropResidueAreaBurned,dumpingGroundAreaBurned,firefighters,wildlandCrew,volunteers,army,otherFirefighters,fireTrucks,localAuthoritiesVehicles,waterTankTrucks,machinery,helicopters,airplanesCl415,airplanesCl215,airplanesPzl,airplanesGru,const DeepCollectionEquality().hash(raw),provenance]);

@override
String toString() {
  return 'ForestFire(startTime: $startTime, endTime: $endTime, fireStation: $fireStation, prefecture: $prefecture, forestry: $forestry, municipality: $municipality, location: $location, address: $address, forestAreaBurned: $forestAreaBurned, woodlandAreaBurned: $woodlandAreaBurned, groveAreaBurned: $groveAreaBurned, lowVegetationAreaBurned: $lowVegetationAreaBurned, swampAreaBurned: $swampAreaBurned, agriculturalAreaBurned: $agriculturalAreaBurned, cropResidueAreaBurned: $cropResidueAreaBurned, dumpingGroundAreaBurned: $dumpingGroundAreaBurned, firefighters: $firefighters, wildlandCrew: $wildlandCrew, volunteers: $volunteers, army: $army, otherFirefighters: $otherFirefighters, fireTrucks: $fireTrucks, localAuthoritiesVehicles: $localAuthoritiesVehicles, waterTankTrucks: $waterTankTrucks, machinery: $machinery, helicopters: $helicopters, airplanesCl415: $airplanesCl415, airplanesCl215: $airplanesCl215, airplanesPzl: $airplanesPzl, airplanesGru: $airplanesGru, raw: $raw, provenance: $provenance)';
}


}

/// @nodoc
abstract mixin class $ForestFireCopyWith<$Res>  {
  factory $ForestFireCopyWith(ForestFire value, $Res Function(ForestFire) _then) = _$ForestFireCopyWithImpl;
@useResult
$Res call({
@SourceDateConverter()@JsonKey(name: 'start_time') SourceDate startTime,@SourceDateConverter()@JsonKey(name: 'end_time') SourceDate? endTime,@JsonKey(name: 'fire_station') String? fireStation, String? prefecture, String? forestry, String? municipality, String? location, String? address,@JsonKey(name: 'forest_area_burned') num? forestAreaBurned,@JsonKey(name: 'woodland_area_burned') num? woodlandAreaBurned,@JsonKey(name: 'grove_area_burned') num? groveAreaBurned,@JsonKey(name: 'low_vegetation_area_burned') num? lowVegetationAreaBurned,@JsonKey(name: 'swamp_area_burned') num? swampAreaBurned,@JsonKey(name: 'agricultural_area_burned') num? agriculturalAreaBurned,@JsonKey(name: 'crop_residue_area_burned') num? cropResidueAreaBurned,@JsonKey(name: 'dumping_ground_area_burned') num? dumpingGroundAreaBurned, int? firefighters,@JsonKey(name: 'wildland_crew') int? wildlandCrew, int? volunteers, int? army,@JsonKey(name: 'other_firefighters') int? otherFirefighters,@JsonKey(name: 'fire_trucks') int? fireTrucks,@JsonKey(name: 'local_authorities_vehicles') int? localAuthoritiesVehicles,@JsonKey(name: 'water_tank_trucks') int? waterTankTrucks, int? machinery, int? helicopters,@JsonKey(name: 'airplanes_cl415') int? airplanesCl415,@JsonKey(name: 'airplanes_cl215') int? airplanesCl215,@JsonKey(name: 'airplanes_pzl') int? airplanesPzl,@JsonKey(name: 'airplanes_gru') int? airplanesGru,@ImmutableSourceConverter() JsonObject raw,@SourceProvenanceConverter() SourceProvenance provenance
});




}
/// @nodoc
class _$ForestFireCopyWithImpl<$Res>
    implements $ForestFireCopyWith<$Res> {
  _$ForestFireCopyWithImpl(this._self, this._then);

  final ForestFire _self;
  final $Res Function(ForestFire) _then;

/// Create a copy of ForestFire
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startTime = null,Object? endTime = freezed,Object? fireStation = freezed,Object? prefecture = freezed,Object? forestry = freezed,Object? municipality = freezed,Object? location = freezed,Object? address = freezed,Object? forestAreaBurned = freezed,Object? woodlandAreaBurned = freezed,Object? groveAreaBurned = freezed,Object? lowVegetationAreaBurned = freezed,Object? swampAreaBurned = freezed,Object? agriculturalAreaBurned = freezed,Object? cropResidueAreaBurned = freezed,Object? dumpingGroundAreaBurned = freezed,Object? firefighters = freezed,Object? wildlandCrew = freezed,Object? volunteers = freezed,Object? army = freezed,Object? otherFirefighters = freezed,Object? fireTrucks = freezed,Object? localAuthoritiesVehicles = freezed,Object? waterTankTrucks = freezed,Object? machinery = freezed,Object? helicopters = freezed,Object? airplanesCl415 = freezed,Object? airplanesCl215 = freezed,Object? airplanesPzl = freezed,Object? airplanesGru = freezed,Object? raw = null,Object? provenance = null,}) {
  return _then(_self.copyWith(
startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as SourceDate,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as SourceDate?,fireStation: freezed == fireStation ? _self.fireStation : fireStation // ignore: cast_nullable_to_non_nullable
as String?,prefecture: freezed == prefecture ? _self.prefecture : prefecture // ignore: cast_nullable_to_non_nullable
as String?,forestry: freezed == forestry ? _self.forestry : forestry // ignore: cast_nullable_to_non_nullable
as String?,municipality: freezed == municipality ? _self.municipality : municipality // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,forestAreaBurned: freezed == forestAreaBurned ? _self.forestAreaBurned : forestAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,woodlandAreaBurned: freezed == woodlandAreaBurned ? _self.woodlandAreaBurned : woodlandAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,groveAreaBurned: freezed == groveAreaBurned ? _self.groveAreaBurned : groveAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,lowVegetationAreaBurned: freezed == lowVegetationAreaBurned ? _self.lowVegetationAreaBurned : lowVegetationAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,swampAreaBurned: freezed == swampAreaBurned ? _self.swampAreaBurned : swampAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,agriculturalAreaBurned: freezed == agriculturalAreaBurned ? _self.agriculturalAreaBurned : agriculturalAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,cropResidueAreaBurned: freezed == cropResidueAreaBurned ? _self.cropResidueAreaBurned : cropResidueAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,dumpingGroundAreaBurned: freezed == dumpingGroundAreaBurned ? _self.dumpingGroundAreaBurned : dumpingGroundAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,firefighters: freezed == firefighters ? _self.firefighters : firefighters // ignore: cast_nullable_to_non_nullable
as int?,wildlandCrew: freezed == wildlandCrew ? _self.wildlandCrew : wildlandCrew // ignore: cast_nullable_to_non_nullable
as int?,volunteers: freezed == volunteers ? _self.volunteers : volunteers // ignore: cast_nullable_to_non_nullable
as int?,army: freezed == army ? _self.army : army // ignore: cast_nullable_to_non_nullable
as int?,otherFirefighters: freezed == otherFirefighters ? _self.otherFirefighters : otherFirefighters // ignore: cast_nullable_to_non_nullable
as int?,fireTrucks: freezed == fireTrucks ? _self.fireTrucks : fireTrucks // ignore: cast_nullable_to_non_nullable
as int?,localAuthoritiesVehicles: freezed == localAuthoritiesVehicles ? _self.localAuthoritiesVehicles : localAuthoritiesVehicles // ignore: cast_nullable_to_non_nullable
as int?,waterTankTrucks: freezed == waterTankTrucks ? _self.waterTankTrucks : waterTankTrucks // ignore: cast_nullable_to_non_nullable
as int?,machinery: freezed == machinery ? _self.machinery : machinery // ignore: cast_nullable_to_non_nullable
as int?,helicopters: freezed == helicopters ? _self.helicopters : helicopters // ignore: cast_nullable_to_non_nullable
as int?,airplanesCl415: freezed == airplanesCl415 ? _self.airplanesCl415 : airplanesCl415 // ignore: cast_nullable_to_non_nullable
as int?,airplanesCl215: freezed == airplanesCl215 ? _self.airplanesCl215 : airplanesCl215 // ignore: cast_nullable_to_non_nullable
as int?,airplanesPzl: freezed == airplanesPzl ? _self.airplanesPzl : airplanesPzl // ignore: cast_nullable_to_non_nullable
as int?,airplanesGru: freezed == airplanesGru ? _self.airplanesGru : airplanesGru // ignore: cast_nullable_to_non_nullable
as int?,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as JsonObject,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as SourceProvenance,
  ));
}

}


/// Adds pattern-matching-related methods to [ForestFire].
extension ForestFirePatterns on ForestFire {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForestFire value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForestFire() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForestFire value)  $default,){
final _that = this;
switch (_that) {
case _ForestFire():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForestFire value)?  $default,){
final _that = this;
switch (_that) {
case _ForestFire() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@SourceDateConverter()@JsonKey(name: 'start_time')  SourceDate startTime, @SourceDateConverter()@JsonKey(name: 'end_time')  SourceDate? endTime, @JsonKey(name: 'fire_station')  String? fireStation,  String? prefecture,  String? forestry,  String? municipality,  String? location,  String? address, @JsonKey(name: 'forest_area_burned')  num? forestAreaBurned, @JsonKey(name: 'woodland_area_burned')  num? woodlandAreaBurned, @JsonKey(name: 'grove_area_burned')  num? groveAreaBurned, @JsonKey(name: 'low_vegetation_area_burned')  num? lowVegetationAreaBurned, @JsonKey(name: 'swamp_area_burned')  num? swampAreaBurned, @JsonKey(name: 'agricultural_area_burned')  num? agriculturalAreaBurned, @JsonKey(name: 'crop_residue_area_burned')  num? cropResidueAreaBurned, @JsonKey(name: 'dumping_ground_area_burned')  num? dumpingGroundAreaBurned,  int? firefighters, @JsonKey(name: 'wildland_crew')  int? wildlandCrew,  int? volunteers,  int? army, @JsonKey(name: 'other_firefighters')  int? otherFirefighters, @JsonKey(name: 'fire_trucks')  int? fireTrucks, @JsonKey(name: 'local_authorities_vehicles')  int? localAuthoritiesVehicles, @JsonKey(name: 'water_tank_trucks')  int? waterTankTrucks,  int? machinery,  int? helicopters, @JsonKey(name: 'airplanes_cl415')  int? airplanesCl415, @JsonKey(name: 'airplanes_cl215')  int? airplanesCl215, @JsonKey(name: 'airplanes_pzl')  int? airplanesPzl, @JsonKey(name: 'airplanes_gru')  int? airplanesGru, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForestFire() when $default != null:
return $default(_that.startTime,_that.endTime,_that.fireStation,_that.prefecture,_that.forestry,_that.municipality,_that.location,_that.address,_that.forestAreaBurned,_that.woodlandAreaBurned,_that.groveAreaBurned,_that.lowVegetationAreaBurned,_that.swampAreaBurned,_that.agriculturalAreaBurned,_that.cropResidueAreaBurned,_that.dumpingGroundAreaBurned,_that.firefighters,_that.wildlandCrew,_that.volunteers,_that.army,_that.otherFirefighters,_that.fireTrucks,_that.localAuthoritiesVehicles,_that.waterTankTrucks,_that.machinery,_that.helicopters,_that.airplanesCl415,_that.airplanesCl215,_that.airplanesPzl,_that.airplanesGru,_that.raw,_that.provenance);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@SourceDateConverter()@JsonKey(name: 'start_time')  SourceDate startTime, @SourceDateConverter()@JsonKey(name: 'end_time')  SourceDate? endTime, @JsonKey(name: 'fire_station')  String? fireStation,  String? prefecture,  String? forestry,  String? municipality,  String? location,  String? address, @JsonKey(name: 'forest_area_burned')  num? forestAreaBurned, @JsonKey(name: 'woodland_area_burned')  num? woodlandAreaBurned, @JsonKey(name: 'grove_area_burned')  num? groveAreaBurned, @JsonKey(name: 'low_vegetation_area_burned')  num? lowVegetationAreaBurned, @JsonKey(name: 'swamp_area_burned')  num? swampAreaBurned, @JsonKey(name: 'agricultural_area_burned')  num? agriculturalAreaBurned, @JsonKey(name: 'crop_residue_area_burned')  num? cropResidueAreaBurned, @JsonKey(name: 'dumping_ground_area_burned')  num? dumpingGroundAreaBurned,  int? firefighters, @JsonKey(name: 'wildland_crew')  int? wildlandCrew,  int? volunteers,  int? army, @JsonKey(name: 'other_firefighters')  int? otherFirefighters, @JsonKey(name: 'fire_trucks')  int? fireTrucks, @JsonKey(name: 'local_authorities_vehicles')  int? localAuthoritiesVehicles, @JsonKey(name: 'water_tank_trucks')  int? waterTankTrucks,  int? machinery,  int? helicopters, @JsonKey(name: 'airplanes_cl415')  int? airplanesCl415, @JsonKey(name: 'airplanes_cl215')  int? airplanesCl215, @JsonKey(name: 'airplanes_pzl')  int? airplanesPzl, @JsonKey(name: 'airplanes_gru')  int? airplanesGru, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)  $default,) {final _that = this;
switch (_that) {
case _ForestFire():
return $default(_that.startTime,_that.endTime,_that.fireStation,_that.prefecture,_that.forestry,_that.municipality,_that.location,_that.address,_that.forestAreaBurned,_that.woodlandAreaBurned,_that.groveAreaBurned,_that.lowVegetationAreaBurned,_that.swampAreaBurned,_that.agriculturalAreaBurned,_that.cropResidueAreaBurned,_that.dumpingGroundAreaBurned,_that.firefighters,_that.wildlandCrew,_that.volunteers,_that.army,_that.otherFirefighters,_that.fireTrucks,_that.localAuthoritiesVehicles,_that.waterTankTrucks,_that.machinery,_that.helicopters,_that.airplanesCl415,_that.airplanesCl215,_that.airplanesPzl,_that.airplanesGru,_that.raw,_that.provenance);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@SourceDateConverter()@JsonKey(name: 'start_time')  SourceDate startTime, @SourceDateConverter()@JsonKey(name: 'end_time')  SourceDate? endTime, @JsonKey(name: 'fire_station')  String? fireStation,  String? prefecture,  String? forestry,  String? municipality,  String? location,  String? address, @JsonKey(name: 'forest_area_burned')  num? forestAreaBurned, @JsonKey(name: 'woodland_area_burned')  num? woodlandAreaBurned, @JsonKey(name: 'grove_area_burned')  num? groveAreaBurned, @JsonKey(name: 'low_vegetation_area_burned')  num? lowVegetationAreaBurned, @JsonKey(name: 'swamp_area_burned')  num? swampAreaBurned, @JsonKey(name: 'agricultural_area_burned')  num? agriculturalAreaBurned, @JsonKey(name: 'crop_residue_area_burned')  num? cropResidueAreaBurned, @JsonKey(name: 'dumping_ground_area_burned')  num? dumpingGroundAreaBurned,  int? firefighters, @JsonKey(name: 'wildland_crew')  int? wildlandCrew,  int? volunteers,  int? army, @JsonKey(name: 'other_firefighters')  int? otherFirefighters, @JsonKey(name: 'fire_trucks')  int? fireTrucks, @JsonKey(name: 'local_authorities_vehicles')  int? localAuthoritiesVehicles, @JsonKey(name: 'water_tank_trucks')  int? waterTankTrucks,  int? machinery,  int? helicopters, @JsonKey(name: 'airplanes_cl415')  int? airplanesCl415, @JsonKey(name: 'airplanes_cl215')  int? airplanesCl215, @JsonKey(name: 'airplanes_pzl')  int? airplanesPzl, @JsonKey(name: 'airplanes_gru')  int? airplanesGru, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)?  $default,) {final _that = this;
switch (_that) {
case _ForestFire() when $default != null:
return $default(_that.startTime,_that.endTime,_that.fireStation,_that.prefecture,_that.forestry,_that.municipality,_that.location,_that.address,_that.forestAreaBurned,_that.woodlandAreaBurned,_that.groveAreaBurned,_that.lowVegetationAreaBurned,_that.swampAreaBurned,_that.agriculturalAreaBurned,_that.cropResidueAreaBurned,_that.dumpingGroundAreaBurned,_that.firefighters,_that.wildlandCrew,_that.volunteers,_that.army,_that.otherFirefighters,_that.fireTrucks,_that.localAuthoritiesVehicles,_that.waterTankTrucks,_that.machinery,_that.helicopters,_that.airplanesCl415,_that.airplanesCl215,_that.airplanesPzl,_that.airplanesGru,_that.raw,_that.provenance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForestFire implements ForestFire {
  const _ForestFire({@SourceDateConverter()@JsonKey(name: 'start_time') required this.startTime, @SourceDateConverter()@JsonKey(name: 'end_time') this.endTime, @JsonKey(name: 'fire_station') this.fireStation, this.prefecture, this.forestry, this.municipality, this.location, this.address, @JsonKey(name: 'forest_area_burned') this.forestAreaBurned, @JsonKey(name: 'woodland_area_burned') this.woodlandAreaBurned, @JsonKey(name: 'grove_area_burned') this.groveAreaBurned, @JsonKey(name: 'low_vegetation_area_burned') this.lowVegetationAreaBurned, @JsonKey(name: 'swamp_area_burned') this.swampAreaBurned, @JsonKey(name: 'agricultural_area_burned') this.agriculturalAreaBurned, @JsonKey(name: 'crop_residue_area_burned') this.cropResidueAreaBurned, @JsonKey(name: 'dumping_ground_area_burned') this.dumpingGroundAreaBurned, this.firefighters, @JsonKey(name: 'wildland_crew') this.wildlandCrew, this.volunteers, this.army, @JsonKey(name: 'other_firefighters') this.otherFirefighters, @JsonKey(name: 'fire_trucks') this.fireTrucks, @JsonKey(name: 'local_authorities_vehicles') this.localAuthoritiesVehicles, @JsonKey(name: 'water_tank_trucks') this.waterTankTrucks, this.machinery, this.helicopters, @JsonKey(name: 'airplanes_cl415') this.airplanesCl415, @JsonKey(name: 'airplanes_cl215') this.airplanesCl215, @JsonKey(name: 'airplanes_pzl') this.airplanesPzl, @JsonKey(name: 'airplanes_gru') this.airplanesGru, @ImmutableSourceConverter() required final  JsonObject raw, @SourceProvenanceConverter() required this.provenance}): _raw = raw;
  factory _ForestFire.fromJson(Map<String, dynamic> json) => _$ForestFireFromJson(json);

/// The published `start_time` value.
@override@SourceDateConverter()@JsonKey(name: 'start_time') final  SourceDate startTime;
/// The published `end_time` value.
@override@SourceDateConverter()@JsonKey(name: 'end_time') final  SourceDate? endTime;
/// The published `fire_station` value.
@override@JsonKey(name: 'fire_station') final  String? fireStation;
/// The published `prefecture` value.
@override final  String? prefecture;
/// The published `forestry` value.
@override final  String? forestry;
/// The published `municipality` value.
@override final  String? municipality;
/// The published `location` value.
@override final  String? location;
/// The published `address` value.
@override final  String? address;
/// The published `forest_area_burned` value.
@override@JsonKey(name: 'forest_area_burned') final  num? forestAreaBurned;
/// The published `woodland_area_burned` value.
@override@JsonKey(name: 'woodland_area_burned') final  num? woodlandAreaBurned;
/// The published `grove_area_burned` value.
@override@JsonKey(name: 'grove_area_burned') final  num? groveAreaBurned;
/// The published `low_vegetation_area_burned` value.
@override@JsonKey(name: 'low_vegetation_area_burned') final  num? lowVegetationAreaBurned;
/// The published `swamp_area_burned` value.
@override@JsonKey(name: 'swamp_area_burned') final  num? swampAreaBurned;
/// The published `agricultural_area_burned` value.
@override@JsonKey(name: 'agricultural_area_burned') final  num? agriculturalAreaBurned;
/// The published `crop_residue_area_burned` value.
@override@JsonKey(name: 'crop_residue_area_burned') final  num? cropResidueAreaBurned;
/// The published `dumping_ground_area_burned` value.
@override@JsonKey(name: 'dumping_ground_area_burned') final  num? dumpingGroundAreaBurned;
/// The published `firefighters` value.
@override final  int? firefighters;
/// The published `wildland_crew` value.
@override@JsonKey(name: 'wildland_crew') final  int? wildlandCrew;
/// The published `volunteers` value.
@override final  int? volunteers;
/// The published `army` value.
@override final  int? army;
/// The published `other_firefighters` value.
@override@JsonKey(name: 'other_firefighters') final  int? otherFirefighters;
/// The published `fire_trucks` value.
@override@JsonKey(name: 'fire_trucks') final  int? fireTrucks;
/// The published `local_authorities_vehicles` value.
@override@JsonKey(name: 'local_authorities_vehicles') final  int? localAuthoritiesVehicles;
/// The published `water_tank_trucks` value.
@override@JsonKey(name: 'water_tank_trucks') final  int? waterTankTrucks;
/// The published `machinery` value.
@override final  int? machinery;
/// The published `helicopters` value.
@override final  int? helicopters;
/// The published `airplanes_cl415` value.
@override@JsonKey(name: 'airplanes_cl415') final  int? airplanesCl415;
/// The published `airplanes_cl215` value.
@override@JsonKey(name: 'airplanes_cl215') final  int? airplanesCl215;
/// The published `airplanes_pzl` value.
@override@JsonKey(name: 'airplanes_pzl') final  int? airplanesPzl;
/// The published `airplanes_gru` value.
@override@JsonKey(name: 'airplanes_gru') final  int? airplanesGru;
/// Immutable original source cells, including unknown columns.
 final  JsonObject _raw;
/// Immutable original source cells, including unknown columns.
@override@ImmutableSourceConverter() JsonObject get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}

/// Selected source identity and measured retrieval time.
@override@SourceProvenanceConverter() final  SourceProvenance provenance;

/// Create a copy of ForestFire
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForestFireCopyWith<_ForestFire> get copyWith => __$ForestFireCopyWithImpl<_ForestFire>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForestFireToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForestFire&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.fireStation, fireStation) || other.fireStation == fireStation)&&(identical(other.prefecture, prefecture) || other.prefecture == prefecture)&&(identical(other.forestry, forestry) || other.forestry == forestry)&&(identical(other.municipality, municipality) || other.municipality == municipality)&&(identical(other.location, location) || other.location == location)&&(identical(other.address, address) || other.address == address)&&(identical(other.forestAreaBurned, forestAreaBurned) || other.forestAreaBurned == forestAreaBurned)&&(identical(other.woodlandAreaBurned, woodlandAreaBurned) || other.woodlandAreaBurned == woodlandAreaBurned)&&(identical(other.groveAreaBurned, groveAreaBurned) || other.groveAreaBurned == groveAreaBurned)&&(identical(other.lowVegetationAreaBurned, lowVegetationAreaBurned) || other.lowVegetationAreaBurned == lowVegetationAreaBurned)&&(identical(other.swampAreaBurned, swampAreaBurned) || other.swampAreaBurned == swampAreaBurned)&&(identical(other.agriculturalAreaBurned, agriculturalAreaBurned) || other.agriculturalAreaBurned == agriculturalAreaBurned)&&(identical(other.cropResidueAreaBurned, cropResidueAreaBurned) || other.cropResidueAreaBurned == cropResidueAreaBurned)&&(identical(other.dumpingGroundAreaBurned, dumpingGroundAreaBurned) || other.dumpingGroundAreaBurned == dumpingGroundAreaBurned)&&(identical(other.firefighters, firefighters) || other.firefighters == firefighters)&&(identical(other.wildlandCrew, wildlandCrew) || other.wildlandCrew == wildlandCrew)&&(identical(other.volunteers, volunteers) || other.volunteers == volunteers)&&(identical(other.army, army) || other.army == army)&&(identical(other.otherFirefighters, otherFirefighters) || other.otherFirefighters == otherFirefighters)&&(identical(other.fireTrucks, fireTrucks) || other.fireTrucks == fireTrucks)&&(identical(other.localAuthoritiesVehicles, localAuthoritiesVehicles) || other.localAuthoritiesVehicles == localAuthoritiesVehicles)&&(identical(other.waterTankTrucks, waterTankTrucks) || other.waterTankTrucks == waterTankTrucks)&&(identical(other.machinery, machinery) || other.machinery == machinery)&&(identical(other.helicopters, helicopters) || other.helicopters == helicopters)&&(identical(other.airplanesCl415, airplanesCl415) || other.airplanesCl415 == airplanesCl415)&&(identical(other.airplanesCl215, airplanesCl215) || other.airplanesCl215 == airplanesCl215)&&(identical(other.airplanesPzl, airplanesPzl) || other.airplanesPzl == airplanesPzl)&&(identical(other.airplanesGru, airplanesGru) || other.airplanesGru == airplanesGru)&&const DeepCollectionEquality().equals(other._raw, _raw)&&(identical(other.provenance, provenance) || other.provenance == provenance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,startTime,endTime,fireStation,prefecture,forestry,municipality,location,address,forestAreaBurned,woodlandAreaBurned,groveAreaBurned,lowVegetationAreaBurned,swampAreaBurned,agriculturalAreaBurned,cropResidueAreaBurned,dumpingGroundAreaBurned,firefighters,wildlandCrew,volunteers,army,otherFirefighters,fireTrucks,localAuthoritiesVehicles,waterTankTrucks,machinery,helicopters,airplanesCl415,airplanesCl215,airplanesPzl,airplanesGru,const DeepCollectionEquality().hash(_raw),provenance]);

@override
String toString() {
  return 'ForestFire(startTime: $startTime, endTime: $endTime, fireStation: $fireStation, prefecture: $prefecture, forestry: $forestry, municipality: $municipality, location: $location, address: $address, forestAreaBurned: $forestAreaBurned, woodlandAreaBurned: $woodlandAreaBurned, groveAreaBurned: $groveAreaBurned, lowVegetationAreaBurned: $lowVegetationAreaBurned, swampAreaBurned: $swampAreaBurned, agriculturalAreaBurned: $agriculturalAreaBurned, cropResidueAreaBurned: $cropResidueAreaBurned, dumpingGroundAreaBurned: $dumpingGroundAreaBurned, firefighters: $firefighters, wildlandCrew: $wildlandCrew, volunteers: $volunteers, army: $army, otherFirefighters: $otherFirefighters, fireTrucks: $fireTrucks, localAuthoritiesVehicles: $localAuthoritiesVehicles, waterTankTrucks: $waterTankTrucks, machinery: $machinery, helicopters: $helicopters, airplanesCl415: $airplanesCl415, airplanesCl215: $airplanesCl215, airplanesPzl: $airplanesPzl, airplanesGru: $airplanesGru, raw: $raw, provenance: $provenance)';
}


}

/// @nodoc
abstract mixin class _$ForestFireCopyWith<$Res> implements $ForestFireCopyWith<$Res> {
  factory _$ForestFireCopyWith(_ForestFire value, $Res Function(_ForestFire) _then) = __$ForestFireCopyWithImpl;
@override @useResult
$Res call({
@SourceDateConverter()@JsonKey(name: 'start_time') SourceDate startTime,@SourceDateConverter()@JsonKey(name: 'end_time') SourceDate? endTime,@JsonKey(name: 'fire_station') String? fireStation, String? prefecture, String? forestry, String? municipality, String? location, String? address,@JsonKey(name: 'forest_area_burned') num? forestAreaBurned,@JsonKey(name: 'woodland_area_burned') num? woodlandAreaBurned,@JsonKey(name: 'grove_area_burned') num? groveAreaBurned,@JsonKey(name: 'low_vegetation_area_burned') num? lowVegetationAreaBurned,@JsonKey(name: 'swamp_area_burned') num? swampAreaBurned,@JsonKey(name: 'agricultural_area_burned') num? agriculturalAreaBurned,@JsonKey(name: 'crop_residue_area_burned') num? cropResidueAreaBurned,@JsonKey(name: 'dumping_ground_area_burned') num? dumpingGroundAreaBurned, int? firefighters,@JsonKey(name: 'wildland_crew') int? wildlandCrew, int? volunteers, int? army,@JsonKey(name: 'other_firefighters') int? otherFirefighters,@JsonKey(name: 'fire_trucks') int? fireTrucks,@JsonKey(name: 'local_authorities_vehicles') int? localAuthoritiesVehicles,@JsonKey(name: 'water_tank_trucks') int? waterTankTrucks, int? machinery, int? helicopters,@JsonKey(name: 'airplanes_cl415') int? airplanesCl415,@JsonKey(name: 'airplanes_cl215') int? airplanesCl215,@JsonKey(name: 'airplanes_pzl') int? airplanesPzl,@JsonKey(name: 'airplanes_gru') int? airplanesGru,@ImmutableSourceConverter() JsonObject raw,@SourceProvenanceConverter() SourceProvenance provenance
});




}
/// @nodoc
class __$ForestFireCopyWithImpl<$Res>
    implements _$ForestFireCopyWith<$Res> {
  __$ForestFireCopyWithImpl(this._self, this._then);

  final _ForestFire _self;
  final $Res Function(_ForestFire) _then;

/// Create a copy of ForestFire
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startTime = null,Object? endTime = freezed,Object? fireStation = freezed,Object? prefecture = freezed,Object? forestry = freezed,Object? municipality = freezed,Object? location = freezed,Object? address = freezed,Object? forestAreaBurned = freezed,Object? woodlandAreaBurned = freezed,Object? groveAreaBurned = freezed,Object? lowVegetationAreaBurned = freezed,Object? swampAreaBurned = freezed,Object? agriculturalAreaBurned = freezed,Object? cropResidueAreaBurned = freezed,Object? dumpingGroundAreaBurned = freezed,Object? firefighters = freezed,Object? wildlandCrew = freezed,Object? volunteers = freezed,Object? army = freezed,Object? otherFirefighters = freezed,Object? fireTrucks = freezed,Object? localAuthoritiesVehicles = freezed,Object? waterTankTrucks = freezed,Object? machinery = freezed,Object? helicopters = freezed,Object? airplanesCl415 = freezed,Object? airplanesCl215 = freezed,Object? airplanesPzl = freezed,Object? airplanesGru = freezed,Object? raw = null,Object? provenance = null,}) {
  return _then(_ForestFire(
startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as SourceDate,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as SourceDate?,fireStation: freezed == fireStation ? _self.fireStation : fireStation // ignore: cast_nullable_to_non_nullable
as String?,prefecture: freezed == prefecture ? _self.prefecture : prefecture // ignore: cast_nullable_to_non_nullable
as String?,forestry: freezed == forestry ? _self.forestry : forestry // ignore: cast_nullable_to_non_nullable
as String?,municipality: freezed == municipality ? _self.municipality : municipality // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,forestAreaBurned: freezed == forestAreaBurned ? _self.forestAreaBurned : forestAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,woodlandAreaBurned: freezed == woodlandAreaBurned ? _self.woodlandAreaBurned : woodlandAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,groveAreaBurned: freezed == groveAreaBurned ? _self.groveAreaBurned : groveAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,lowVegetationAreaBurned: freezed == lowVegetationAreaBurned ? _self.lowVegetationAreaBurned : lowVegetationAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,swampAreaBurned: freezed == swampAreaBurned ? _self.swampAreaBurned : swampAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,agriculturalAreaBurned: freezed == agriculturalAreaBurned ? _self.agriculturalAreaBurned : agriculturalAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,cropResidueAreaBurned: freezed == cropResidueAreaBurned ? _self.cropResidueAreaBurned : cropResidueAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,dumpingGroundAreaBurned: freezed == dumpingGroundAreaBurned ? _self.dumpingGroundAreaBurned : dumpingGroundAreaBurned // ignore: cast_nullable_to_non_nullable
as num?,firefighters: freezed == firefighters ? _self.firefighters : firefighters // ignore: cast_nullable_to_non_nullable
as int?,wildlandCrew: freezed == wildlandCrew ? _self.wildlandCrew : wildlandCrew // ignore: cast_nullable_to_non_nullable
as int?,volunteers: freezed == volunteers ? _self.volunteers : volunteers // ignore: cast_nullable_to_non_nullable
as int?,army: freezed == army ? _self.army : army // ignore: cast_nullable_to_non_nullable
as int?,otherFirefighters: freezed == otherFirefighters ? _self.otherFirefighters : otherFirefighters // ignore: cast_nullable_to_non_nullable
as int?,fireTrucks: freezed == fireTrucks ? _self.fireTrucks : fireTrucks // ignore: cast_nullable_to_non_nullable
as int?,localAuthoritiesVehicles: freezed == localAuthoritiesVehicles ? _self.localAuthoritiesVehicles : localAuthoritiesVehicles // ignore: cast_nullable_to_non_nullable
as int?,waterTankTrucks: freezed == waterTankTrucks ? _self.waterTankTrucks : waterTankTrucks // ignore: cast_nullable_to_non_nullable
as int?,machinery: freezed == machinery ? _self.machinery : machinery // ignore: cast_nullable_to_non_nullable
as int?,helicopters: freezed == helicopters ? _self.helicopters : helicopters // ignore: cast_nullable_to_non_nullable
as int?,airplanesCl415: freezed == airplanesCl415 ? _self.airplanesCl415 : airplanesCl415 // ignore: cast_nullable_to_non_nullable
as int?,airplanesCl215: freezed == airplanesCl215 ? _self.airplanesCl215 : airplanesCl215 // ignore: cast_nullable_to_non_nullable
as int?,airplanesPzl: freezed == airplanesPzl ? _self.airplanesPzl : airplanesPzl // ignore: cast_nullable_to_non_nullable
as int?,airplanesGru: freezed == airplanesGru ? _self.airplanesGru : airplanesGru // ignore: cast_nullable_to_non_nullable
as int?,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as JsonObject,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as SourceProvenance,
  ));
}


}

// dart format on
