// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vaccination_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VaccinationData {

/// The published `area` value.
 String get area;/// The published `areaid` value.
@JsonKey(name: 'areaid') String get areaId;/// The published `referencedate` value.
@SourceDateConverter()@JsonKey(name: 'referencedate') SourceDate get referenceDate;/// The published `daytotal` value.
@JsonKey(name: 'daytotal') int? get dayTotal;/// The published `daydiff` value.
@JsonKey(name: 'daydiff') int? get dayDiff;/// The published `totalvaccinations` value.
@JsonKey(name: 'totalvaccinations') int? get totalVaccinations;/// The published `totaldistinctpersons` value.
@JsonKey(name: 'totaldistinctpersons') int? get totalDistinctPersons;/// The published `dailydose1` value.
@JsonKey(name: 'dailydose1') int? get dailyDose1;/// The published `dailydose2` value.
@JsonKey(name: 'dailydose2') int? get dailyDose2;/// The published `dailydose3` value.
@JsonKey(name: 'dailydose3') int? get dailyDose3;/// The published `totaldose1` value.
@JsonKey(name: 'totaldose1') int? get totalDose1;/// The published `totaldose2` value.
@JsonKey(name: 'totaldose2') int? get totalDose2;/// The published `totaldose3` value.
@JsonKey(name: 'totaldose3') int? get totalDose3;/// Immutable original source cells, including unknown columns.
@ImmutableSourceConverter() JsonObject get raw;/// Selected source identity and measured retrieval time.
@SourceProvenanceConverter() SourceProvenance get provenance;
/// Create a copy of VaccinationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VaccinationDataCopyWith<VaccinationData> get copyWith => _$VaccinationDataCopyWithImpl<VaccinationData>(this as VaccinationData, _$identity);

  /// Serializes this VaccinationData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VaccinationData&&(identical(other.area, area) || other.area == area)&&(identical(other.areaId, areaId) || other.areaId == areaId)&&(identical(other.referenceDate, referenceDate) || other.referenceDate == referenceDate)&&(identical(other.dayTotal, dayTotal) || other.dayTotal == dayTotal)&&(identical(other.dayDiff, dayDiff) || other.dayDiff == dayDiff)&&(identical(other.totalVaccinations, totalVaccinations) || other.totalVaccinations == totalVaccinations)&&(identical(other.totalDistinctPersons, totalDistinctPersons) || other.totalDistinctPersons == totalDistinctPersons)&&(identical(other.dailyDose1, dailyDose1) || other.dailyDose1 == dailyDose1)&&(identical(other.dailyDose2, dailyDose2) || other.dailyDose2 == dailyDose2)&&(identical(other.dailyDose3, dailyDose3) || other.dailyDose3 == dailyDose3)&&(identical(other.totalDose1, totalDose1) || other.totalDose1 == totalDose1)&&(identical(other.totalDose2, totalDose2) || other.totalDose2 == totalDose2)&&(identical(other.totalDose3, totalDose3) || other.totalDose3 == totalDose3)&&const DeepCollectionEquality().equals(other.raw, raw)&&(identical(other.provenance, provenance) || other.provenance == provenance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,area,areaId,referenceDate,dayTotal,dayDiff,totalVaccinations,totalDistinctPersons,dailyDose1,dailyDose2,dailyDose3,totalDose1,totalDose2,totalDose3,const DeepCollectionEquality().hash(raw),provenance);

@override
String toString() {
  return 'VaccinationData(area: $area, areaId: $areaId, referenceDate: $referenceDate, dayTotal: $dayTotal, dayDiff: $dayDiff, totalVaccinations: $totalVaccinations, totalDistinctPersons: $totalDistinctPersons, dailyDose1: $dailyDose1, dailyDose2: $dailyDose2, dailyDose3: $dailyDose3, totalDose1: $totalDose1, totalDose2: $totalDose2, totalDose3: $totalDose3, raw: $raw, provenance: $provenance)';
}


}

/// @nodoc
abstract mixin class $VaccinationDataCopyWith<$Res>  {
  factory $VaccinationDataCopyWith(VaccinationData value, $Res Function(VaccinationData) _then) = _$VaccinationDataCopyWithImpl;
@useResult
$Res call({
 String area,@JsonKey(name: 'areaid') String areaId,@SourceDateConverter()@JsonKey(name: 'referencedate') SourceDate referenceDate,@JsonKey(name: 'daytotal') int? dayTotal,@JsonKey(name: 'daydiff') int? dayDiff,@JsonKey(name: 'totalvaccinations') int? totalVaccinations,@JsonKey(name: 'totaldistinctpersons') int? totalDistinctPersons,@JsonKey(name: 'dailydose1') int? dailyDose1,@JsonKey(name: 'dailydose2') int? dailyDose2,@JsonKey(name: 'dailydose3') int? dailyDose3,@JsonKey(name: 'totaldose1') int? totalDose1,@JsonKey(name: 'totaldose2') int? totalDose2,@JsonKey(name: 'totaldose3') int? totalDose3,@ImmutableSourceConverter() JsonObject raw,@SourceProvenanceConverter() SourceProvenance provenance
});




}
/// @nodoc
class _$VaccinationDataCopyWithImpl<$Res>
    implements $VaccinationDataCopyWith<$Res> {
  _$VaccinationDataCopyWithImpl(this._self, this._then);

  final VaccinationData _self;
  final $Res Function(VaccinationData) _then;

/// Create a copy of VaccinationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? area = null,Object? areaId = null,Object? referenceDate = null,Object? dayTotal = freezed,Object? dayDiff = freezed,Object? totalVaccinations = freezed,Object? totalDistinctPersons = freezed,Object? dailyDose1 = freezed,Object? dailyDose2 = freezed,Object? dailyDose3 = freezed,Object? totalDose1 = freezed,Object? totalDose2 = freezed,Object? totalDose3 = freezed,Object? raw = null,Object? provenance = null,}) {
  return _then(_self.copyWith(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,areaId: null == areaId ? _self.areaId : areaId // ignore: cast_nullable_to_non_nullable
as String,referenceDate: null == referenceDate ? _self.referenceDate : referenceDate // ignore: cast_nullable_to_non_nullable
as SourceDate,dayTotal: freezed == dayTotal ? _self.dayTotal : dayTotal // ignore: cast_nullable_to_non_nullable
as int?,dayDiff: freezed == dayDiff ? _self.dayDiff : dayDiff // ignore: cast_nullable_to_non_nullable
as int?,totalVaccinations: freezed == totalVaccinations ? _self.totalVaccinations : totalVaccinations // ignore: cast_nullable_to_non_nullable
as int?,totalDistinctPersons: freezed == totalDistinctPersons ? _self.totalDistinctPersons : totalDistinctPersons // ignore: cast_nullable_to_non_nullable
as int?,dailyDose1: freezed == dailyDose1 ? _self.dailyDose1 : dailyDose1 // ignore: cast_nullable_to_non_nullable
as int?,dailyDose2: freezed == dailyDose2 ? _self.dailyDose2 : dailyDose2 // ignore: cast_nullable_to_non_nullable
as int?,dailyDose3: freezed == dailyDose3 ? _self.dailyDose3 : dailyDose3 // ignore: cast_nullable_to_non_nullable
as int?,totalDose1: freezed == totalDose1 ? _self.totalDose1 : totalDose1 // ignore: cast_nullable_to_non_nullable
as int?,totalDose2: freezed == totalDose2 ? _self.totalDose2 : totalDose2 // ignore: cast_nullable_to_non_nullable
as int?,totalDose3: freezed == totalDose3 ? _self.totalDose3 : totalDose3 // ignore: cast_nullable_to_non_nullable
as int?,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as JsonObject,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as SourceProvenance,
  ));
}

}


/// Adds pattern-matching-related methods to [VaccinationData].
extension VaccinationDataPatterns on VaccinationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VaccinationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VaccinationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VaccinationData value)  $default,){
final _that = this;
switch (_that) {
case _VaccinationData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VaccinationData value)?  $default,){
final _that = this;
switch (_that) {
case _VaccinationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String area, @JsonKey(name: 'areaid')  String areaId, @SourceDateConverter()@JsonKey(name: 'referencedate')  SourceDate referenceDate, @JsonKey(name: 'daytotal')  int? dayTotal, @JsonKey(name: 'daydiff')  int? dayDiff, @JsonKey(name: 'totalvaccinations')  int? totalVaccinations, @JsonKey(name: 'totaldistinctpersons')  int? totalDistinctPersons, @JsonKey(name: 'dailydose1')  int? dailyDose1, @JsonKey(name: 'dailydose2')  int? dailyDose2, @JsonKey(name: 'dailydose3')  int? dailyDose3, @JsonKey(name: 'totaldose1')  int? totalDose1, @JsonKey(name: 'totaldose2')  int? totalDose2, @JsonKey(name: 'totaldose3')  int? totalDose3, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VaccinationData() when $default != null:
return $default(_that.area,_that.areaId,_that.referenceDate,_that.dayTotal,_that.dayDiff,_that.totalVaccinations,_that.totalDistinctPersons,_that.dailyDose1,_that.dailyDose2,_that.dailyDose3,_that.totalDose1,_that.totalDose2,_that.totalDose3,_that.raw,_that.provenance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String area, @JsonKey(name: 'areaid')  String areaId, @SourceDateConverter()@JsonKey(name: 'referencedate')  SourceDate referenceDate, @JsonKey(name: 'daytotal')  int? dayTotal, @JsonKey(name: 'daydiff')  int? dayDiff, @JsonKey(name: 'totalvaccinations')  int? totalVaccinations, @JsonKey(name: 'totaldistinctpersons')  int? totalDistinctPersons, @JsonKey(name: 'dailydose1')  int? dailyDose1, @JsonKey(name: 'dailydose2')  int? dailyDose2, @JsonKey(name: 'dailydose3')  int? dailyDose3, @JsonKey(name: 'totaldose1')  int? totalDose1, @JsonKey(name: 'totaldose2')  int? totalDose2, @JsonKey(name: 'totaldose3')  int? totalDose3, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)  $default,) {final _that = this;
switch (_that) {
case _VaccinationData():
return $default(_that.area,_that.areaId,_that.referenceDate,_that.dayTotal,_that.dayDiff,_that.totalVaccinations,_that.totalDistinctPersons,_that.dailyDose1,_that.dailyDose2,_that.dailyDose3,_that.totalDose1,_that.totalDose2,_that.totalDose3,_that.raw,_that.provenance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String area, @JsonKey(name: 'areaid')  String areaId, @SourceDateConverter()@JsonKey(name: 'referencedate')  SourceDate referenceDate, @JsonKey(name: 'daytotal')  int? dayTotal, @JsonKey(name: 'daydiff')  int? dayDiff, @JsonKey(name: 'totalvaccinations')  int? totalVaccinations, @JsonKey(name: 'totaldistinctpersons')  int? totalDistinctPersons, @JsonKey(name: 'dailydose1')  int? dailyDose1, @JsonKey(name: 'dailydose2')  int? dailyDose2, @JsonKey(name: 'dailydose3')  int? dailyDose3, @JsonKey(name: 'totaldose1')  int? totalDose1, @JsonKey(name: 'totaldose2')  int? totalDose2, @JsonKey(name: 'totaldose3')  int? totalDose3, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)?  $default,) {final _that = this;
switch (_that) {
case _VaccinationData() when $default != null:
return $default(_that.area,_that.areaId,_that.referenceDate,_that.dayTotal,_that.dayDiff,_that.totalVaccinations,_that.totalDistinctPersons,_that.dailyDose1,_that.dailyDose2,_that.dailyDose3,_that.totalDose1,_that.totalDose2,_that.totalDose3,_that.raw,_that.provenance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VaccinationData implements VaccinationData {
  const _VaccinationData({required this.area, @JsonKey(name: 'areaid') required this.areaId, @SourceDateConverter()@JsonKey(name: 'referencedate') required this.referenceDate, @JsonKey(name: 'daytotal') this.dayTotal, @JsonKey(name: 'daydiff') this.dayDiff, @JsonKey(name: 'totalvaccinations') this.totalVaccinations, @JsonKey(name: 'totaldistinctpersons') this.totalDistinctPersons, @JsonKey(name: 'dailydose1') this.dailyDose1, @JsonKey(name: 'dailydose2') this.dailyDose2, @JsonKey(name: 'dailydose3') this.dailyDose3, @JsonKey(name: 'totaldose1') this.totalDose1, @JsonKey(name: 'totaldose2') this.totalDose2, @JsonKey(name: 'totaldose3') this.totalDose3, @ImmutableSourceConverter() required final  JsonObject raw, @SourceProvenanceConverter() required this.provenance}): _raw = raw;
  factory _VaccinationData.fromJson(Map<String, dynamic> json) => _$VaccinationDataFromJson(json);

/// The published `area` value.
@override final  String area;
/// The published `areaid` value.
@override@JsonKey(name: 'areaid') final  String areaId;
/// The published `referencedate` value.
@override@SourceDateConverter()@JsonKey(name: 'referencedate') final  SourceDate referenceDate;
/// The published `daytotal` value.
@override@JsonKey(name: 'daytotal') final  int? dayTotal;
/// The published `daydiff` value.
@override@JsonKey(name: 'daydiff') final  int? dayDiff;
/// The published `totalvaccinations` value.
@override@JsonKey(name: 'totalvaccinations') final  int? totalVaccinations;
/// The published `totaldistinctpersons` value.
@override@JsonKey(name: 'totaldistinctpersons') final  int? totalDistinctPersons;
/// The published `dailydose1` value.
@override@JsonKey(name: 'dailydose1') final  int? dailyDose1;
/// The published `dailydose2` value.
@override@JsonKey(name: 'dailydose2') final  int? dailyDose2;
/// The published `dailydose3` value.
@override@JsonKey(name: 'dailydose3') final  int? dailyDose3;
/// The published `totaldose1` value.
@override@JsonKey(name: 'totaldose1') final  int? totalDose1;
/// The published `totaldose2` value.
@override@JsonKey(name: 'totaldose2') final  int? totalDose2;
/// The published `totaldose3` value.
@override@JsonKey(name: 'totaldose3') final  int? totalDose3;
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

/// Create a copy of VaccinationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VaccinationDataCopyWith<_VaccinationData> get copyWith => __$VaccinationDataCopyWithImpl<_VaccinationData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VaccinationDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VaccinationData&&(identical(other.area, area) || other.area == area)&&(identical(other.areaId, areaId) || other.areaId == areaId)&&(identical(other.referenceDate, referenceDate) || other.referenceDate == referenceDate)&&(identical(other.dayTotal, dayTotal) || other.dayTotal == dayTotal)&&(identical(other.dayDiff, dayDiff) || other.dayDiff == dayDiff)&&(identical(other.totalVaccinations, totalVaccinations) || other.totalVaccinations == totalVaccinations)&&(identical(other.totalDistinctPersons, totalDistinctPersons) || other.totalDistinctPersons == totalDistinctPersons)&&(identical(other.dailyDose1, dailyDose1) || other.dailyDose1 == dailyDose1)&&(identical(other.dailyDose2, dailyDose2) || other.dailyDose2 == dailyDose2)&&(identical(other.dailyDose3, dailyDose3) || other.dailyDose3 == dailyDose3)&&(identical(other.totalDose1, totalDose1) || other.totalDose1 == totalDose1)&&(identical(other.totalDose2, totalDose2) || other.totalDose2 == totalDose2)&&(identical(other.totalDose3, totalDose3) || other.totalDose3 == totalDose3)&&const DeepCollectionEquality().equals(other._raw, _raw)&&(identical(other.provenance, provenance) || other.provenance == provenance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,area,areaId,referenceDate,dayTotal,dayDiff,totalVaccinations,totalDistinctPersons,dailyDose1,dailyDose2,dailyDose3,totalDose1,totalDose2,totalDose3,const DeepCollectionEquality().hash(_raw),provenance);

@override
String toString() {
  return 'VaccinationData(area: $area, areaId: $areaId, referenceDate: $referenceDate, dayTotal: $dayTotal, dayDiff: $dayDiff, totalVaccinations: $totalVaccinations, totalDistinctPersons: $totalDistinctPersons, dailyDose1: $dailyDose1, dailyDose2: $dailyDose2, dailyDose3: $dailyDose3, totalDose1: $totalDose1, totalDose2: $totalDose2, totalDose3: $totalDose3, raw: $raw, provenance: $provenance)';
}


}

/// @nodoc
abstract mixin class _$VaccinationDataCopyWith<$Res> implements $VaccinationDataCopyWith<$Res> {
  factory _$VaccinationDataCopyWith(_VaccinationData value, $Res Function(_VaccinationData) _then) = __$VaccinationDataCopyWithImpl;
@override @useResult
$Res call({
 String area,@JsonKey(name: 'areaid') String areaId,@SourceDateConverter()@JsonKey(name: 'referencedate') SourceDate referenceDate,@JsonKey(name: 'daytotal') int? dayTotal,@JsonKey(name: 'daydiff') int? dayDiff,@JsonKey(name: 'totalvaccinations') int? totalVaccinations,@JsonKey(name: 'totaldistinctpersons') int? totalDistinctPersons,@JsonKey(name: 'dailydose1') int? dailyDose1,@JsonKey(name: 'dailydose2') int? dailyDose2,@JsonKey(name: 'dailydose3') int? dailyDose3,@JsonKey(name: 'totaldose1') int? totalDose1,@JsonKey(name: 'totaldose2') int? totalDose2,@JsonKey(name: 'totaldose3') int? totalDose3,@ImmutableSourceConverter() JsonObject raw,@SourceProvenanceConverter() SourceProvenance provenance
});




}
/// @nodoc
class __$VaccinationDataCopyWithImpl<$Res>
    implements _$VaccinationDataCopyWith<$Res> {
  __$VaccinationDataCopyWithImpl(this._self, this._then);

  final _VaccinationData _self;
  final $Res Function(_VaccinationData) _then;

/// Create a copy of VaccinationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? area = null,Object? areaId = null,Object? referenceDate = null,Object? dayTotal = freezed,Object? dayDiff = freezed,Object? totalVaccinations = freezed,Object? totalDistinctPersons = freezed,Object? dailyDose1 = freezed,Object? dailyDose2 = freezed,Object? dailyDose3 = freezed,Object? totalDose1 = freezed,Object? totalDose2 = freezed,Object? totalDose3 = freezed,Object? raw = null,Object? provenance = null,}) {
  return _then(_VaccinationData(
area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,areaId: null == areaId ? _self.areaId : areaId // ignore: cast_nullable_to_non_nullable
as String,referenceDate: null == referenceDate ? _self.referenceDate : referenceDate // ignore: cast_nullable_to_non_nullable
as SourceDate,dayTotal: freezed == dayTotal ? _self.dayTotal : dayTotal // ignore: cast_nullable_to_non_nullable
as int?,dayDiff: freezed == dayDiff ? _self.dayDiff : dayDiff // ignore: cast_nullable_to_non_nullable
as int?,totalVaccinations: freezed == totalVaccinations ? _self.totalVaccinations : totalVaccinations // ignore: cast_nullable_to_non_nullable
as int?,totalDistinctPersons: freezed == totalDistinctPersons ? _self.totalDistinctPersons : totalDistinctPersons // ignore: cast_nullable_to_non_nullable
as int?,dailyDose1: freezed == dailyDose1 ? _self.dailyDose1 : dailyDose1 // ignore: cast_nullable_to_non_nullable
as int?,dailyDose2: freezed == dailyDose2 ? _self.dailyDose2 : dailyDose2 // ignore: cast_nullable_to_non_nullable
as int?,dailyDose3: freezed == dailyDose3 ? _self.dailyDose3 : dailyDose3 // ignore: cast_nullable_to_non_nullable
as int?,totalDose1: freezed == totalDose1 ? _self.totalDose1 : totalDose1 // ignore: cast_nullable_to_non_nullable
as int?,totalDose2: freezed == totalDose2 ? _self.totalDose2 : totalDose2 // ignore: cast_nullable_to_non_nullable
as int?,totalDose3: freezed == totalDose3 ? _self.totalDose3 : totalDose3 // ignore: cast_nullable_to_non_nullable
as int?,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as JsonObject,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as SourceProvenance,
  ));
}


}

// dart format on
