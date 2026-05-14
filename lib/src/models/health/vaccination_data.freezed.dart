// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vaccination_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VaccinationData _$VaccinationDataFromJson(Map<String, dynamic> json) {
  return _VaccinationData.fromJson(json);
}

/// @nodoc
mixin _$VaccinationData {
  String get area => throw _privateConstructorUsedError;
  @JsonKey(name: 'areaid')
  int get areaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'dailydose1')
  int get dailyDose1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'dailydose2')
  int get dailyDose2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'daydiff')
  int get dayDiff => throw _privateConstructorUsedError;
  @JsonKey(name: 'daytotal')
  int get dayTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'referencedate')
  DateTime get referenceDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'totaldose1')
  int get totalDose1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'totaldose2')
  int get totalDose2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalvaccinations')
  int get totalVaccinations => throw _privateConstructorUsedError;

  /// Serializes this VaccinationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VaccinationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VaccinationDataCopyWith<VaccinationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaccinationDataCopyWith<$Res> {
  factory $VaccinationDataCopyWith(
          VaccinationData value, $Res Function(VaccinationData) then) =
      _$VaccinationDataCopyWithImpl<$Res, VaccinationData>;
  @useResult
  $Res call(
      {String area,
      @JsonKey(name: 'areaid') int areaId,
      @JsonKey(name: 'dailydose1') int dailyDose1,
      @JsonKey(name: 'dailydose2') int dailyDose2,
      @JsonKey(name: 'daydiff') int dayDiff,
      @JsonKey(name: 'daytotal') int dayTotal,
      @JsonKey(name: 'referencedate') DateTime referenceDate,
      @JsonKey(name: 'totaldose1') int totalDose1,
      @JsonKey(name: 'totaldose2') int totalDose2,
      @JsonKey(name: 'totalvaccinations') int totalVaccinations});
}

/// @nodoc
class _$VaccinationDataCopyWithImpl<$Res, $Val extends VaccinationData>
    implements $VaccinationDataCopyWith<$Res> {
  _$VaccinationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VaccinationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? area = null,
    Object? areaId = null,
    Object? dailyDose1 = null,
    Object? dailyDose2 = null,
    Object? dayDiff = null,
    Object? dayTotal = null,
    Object? referenceDate = null,
    Object? totalDose1 = null,
    Object? totalDose2 = null,
    Object? totalVaccinations = null,
  }) {
    return _then(_value.copyWith(
      area: null == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as int,
      dailyDose1: null == dailyDose1
          ? _value.dailyDose1
          : dailyDose1 // ignore: cast_nullable_to_non_nullable
              as int,
      dailyDose2: null == dailyDose2
          ? _value.dailyDose2
          : dailyDose2 // ignore: cast_nullable_to_non_nullable
              as int,
      dayDiff: null == dayDiff
          ? _value.dayDiff
          : dayDiff // ignore: cast_nullable_to_non_nullable
              as int,
      dayTotal: null == dayTotal
          ? _value.dayTotal
          : dayTotal // ignore: cast_nullable_to_non_nullable
              as int,
      referenceDate: null == referenceDate
          ? _value.referenceDate
          : referenceDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalDose1: null == totalDose1
          ? _value.totalDose1
          : totalDose1 // ignore: cast_nullable_to_non_nullable
              as int,
      totalDose2: null == totalDose2
          ? _value.totalDose2
          : totalDose2 // ignore: cast_nullable_to_non_nullable
              as int,
      totalVaccinations: null == totalVaccinations
          ? _value.totalVaccinations
          : totalVaccinations // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VaccinationDataImplCopyWith<$Res>
    implements $VaccinationDataCopyWith<$Res> {
  factory _$$VaccinationDataImplCopyWith(_$VaccinationDataImpl value,
          $Res Function(_$VaccinationDataImpl) then) =
      __$$VaccinationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String area,
      @JsonKey(name: 'areaid') int areaId,
      @JsonKey(name: 'dailydose1') int dailyDose1,
      @JsonKey(name: 'dailydose2') int dailyDose2,
      @JsonKey(name: 'daydiff') int dayDiff,
      @JsonKey(name: 'daytotal') int dayTotal,
      @JsonKey(name: 'referencedate') DateTime referenceDate,
      @JsonKey(name: 'totaldose1') int totalDose1,
      @JsonKey(name: 'totaldose2') int totalDose2,
      @JsonKey(name: 'totalvaccinations') int totalVaccinations});
}

/// @nodoc
class __$$VaccinationDataImplCopyWithImpl<$Res>
    extends _$VaccinationDataCopyWithImpl<$Res, _$VaccinationDataImpl>
    implements _$$VaccinationDataImplCopyWith<$Res> {
  __$$VaccinationDataImplCopyWithImpl(
      _$VaccinationDataImpl _value, $Res Function(_$VaccinationDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of VaccinationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? area = null,
    Object? areaId = null,
    Object? dailyDose1 = null,
    Object? dailyDose2 = null,
    Object? dayDiff = null,
    Object? dayTotal = null,
    Object? referenceDate = null,
    Object? totalDose1 = null,
    Object? totalDose2 = null,
    Object? totalVaccinations = null,
  }) {
    return _then(_$VaccinationDataImpl(
      area: null == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as int,
      dailyDose1: null == dailyDose1
          ? _value.dailyDose1
          : dailyDose1 // ignore: cast_nullable_to_non_nullable
              as int,
      dailyDose2: null == dailyDose2
          ? _value.dailyDose2
          : dailyDose2 // ignore: cast_nullable_to_non_nullable
              as int,
      dayDiff: null == dayDiff
          ? _value.dayDiff
          : dayDiff // ignore: cast_nullable_to_non_nullable
              as int,
      dayTotal: null == dayTotal
          ? _value.dayTotal
          : dayTotal // ignore: cast_nullable_to_non_nullable
              as int,
      referenceDate: null == referenceDate
          ? _value.referenceDate
          : referenceDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalDose1: null == totalDose1
          ? _value.totalDose1
          : totalDose1 // ignore: cast_nullable_to_non_nullable
              as int,
      totalDose2: null == totalDose2
          ? _value.totalDose2
          : totalDose2 // ignore: cast_nullable_to_non_nullable
              as int,
      totalVaccinations: null == totalVaccinations
          ? _value.totalVaccinations
          : totalVaccinations // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VaccinationDataImpl implements _VaccinationData {
  const _$VaccinationDataImpl(
      {required this.area,
      @JsonKey(name: 'areaid') required this.areaId,
      @JsonKey(name: 'dailydose1') required this.dailyDose1,
      @JsonKey(name: 'dailydose2') required this.dailyDose2,
      @JsonKey(name: 'daydiff') required this.dayDiff,
      @JsonKey(name: 'daytotal') required this.dayTotal,
      @JsonKey(name: 'referencedate') required this.referenceDate,
      @JsonKey(name: 'totaldose1') required this.totalDose1,
      @JsonKey(name: 'totaldose2') required this.totalDose2,
      @JsonKey(name: 'totalvaccinations') required this.totalVaccinations});

  factory _$VaccinationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$VaccinationDataImplFromJson(json);

  @override
  final String area;
  @override
  @JsonKey(name: 'areaid')
  final int areaId;
  @override
  @JsonKey(name: 'dailydose1')
  final int dailyDose1;
  @override
  @JsonKey(name: 'dailydose2')
  final int dailyDose2;
  @override
  @JsonKey(name: 'daydiff')
  final int dayDiff;
  @override
  @JsonKey(name: 'daytotal')
  final int dayTotal;
  @override
  @JsonKey(name: 'referencedate')
  final DateTime referenceDate;
  @override
  @JsonKey(name: 'totaldose1')
  final int totalDose1;
  @override
  @JsonKey(name: 'totaldose2')
  final int totalDose2;
  @override
  @JsonKey(name: 'totalvaccinations')
  final int totalVaccinations;

  @override
  String toString() {
    return 'VaccinationData(area: $area, areaId: $areaId, dailyDose1: $dailyDose1, dailyDose2: $dailyDose2, dayDiff: $dayDiff, dayTotal: $dayTotal, referenceDate: $referenceDate, totalDose1: $totalDose1, totalDose2: $totalDose2, totalVaccinations: $totalVaccinations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaccinationDataImpl &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.dailyDose1, dailyDose1) ||
                other.dailyDose1 == dailyDose1) &&
            (identical(other.dailyDose2, dailyDose2) ||
                other.dailyDose2 == dailyDose2) &&
            (identical(other.dayDiff, dayDiff) || other.dayDiff == dayDiff) &&
            (identical(other.dayTotal, dayTotal) ||
                other.dayTotal == dayTotal) &&
            (identical(other.referenceDate, referenceDate) ||
                other.referenceDate == referenceDate) &&
            (identical(other.totalDose1, totalDose1) ||
                other.totalDose1 == totalDose1) &&
            (identical(other.totalDose2, totalDose2) ||
                other.totalDose2 == totalDose2) &&
            (identical(other.totalVaccinations, totalVaccinations) ||
                other.totalVaccinations == totalVaccinations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      area,
      areaId,
      dailyDose1,
      dailyDose2,
      dayDiff,
      dayTotal,
      referenceDate,
      totalDose1,
      totalDose2,
      totalVaccinations);

  /// Create a copy of VaccinationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VaccinationDataImplCopyWith<_$VaccinationDataImpl> get copyWith =>
      __$$VaccinationDataImplCopyWithImpl<_$VaccinationDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VaccinationDataImplToJson(
      this,
    );
  }
}

abstract class _VaccinationData implements VaccinationData {
  const factory _VaccinationData(
      {required final String area,
      @JsonKey(name: 'areaid') required final int areaId,
      @JsonKey(name: 'dailydose1') required final int dailyDose1,
      @JsonKey(name: 'dailydose2') required final int dailyDose2,
      @JsonKey(name: 'daydiff') required final int dayDiff,
      @JsonKey(name: 'daytotal') required final int dayTotal,
      @JsonKey(name: 'referencedate') required final DateTime referenceDate,
      @JsonKey(name: 'totaldose1') required final int totalDose1,
      @JsonKey(name: 'totaldose2') required final int totalDose2,
      @JsonKey(name: 'totalvaccinations')
      required final int totalVaccinations}) = _$VaccinationDataImpl;

  factory _VaccinationData.fromJson(Map<String, dynamic> json) =
      _$VaccinationDataImpl.fromJson;

  @override
  String get area;
  @override
  @JsonKey(name: 'areaid')
  int get areaId;
  @override
  @JsonKey(name: 'dailydose1')
  int get dailyDose1;
  @override
  @JsonKey(name: 'dailydose2')
  int get dailyDose2;
  @override
  @JsonKey(name: 'daydiff')
  int get dayDiff;
  @override
  @JsonKey(name: 'daytotal')
  int get dayTotal;
  @override
  @JsonKey(name: 'referencedate')
  DateTime get referenceDate;
  @override
  @JsonKey(name: 'totaldose1')
  int get totalDose1;
  @override
  @JsonKey(name: 'totaldose2')
  int get totalDose2;
  @override
  @JsonKey(name: 'totalvaccinations')
  int get totalVaccinations;

  /// Create a copy of VaccinationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VaccinationDataImplCopyWith<_$VaccinationDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
