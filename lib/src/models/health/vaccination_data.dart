import 'package:freezed_annotation/freezed_annotation.dart';

part 'vaccination_data.freezed.dart';
part 'vaccination_data.g.dart';

/// Represents daily and cumulative COVID-19 vaccination statistics for a specific area in Greece.
@freezed
class VaccinationData with _$VaccinationData {
  /// Creates a new [VaccinationData] instance.
  const factory VaccinationData({
    /// The name of the region or area.
    required String area,

    /// The unique identifier of the region/area.
    @JsonKey(name: 'areaid') required int areaId,

    /// Number of daily first doses administered.
    @JsonKey(name: 'dailydose1') required int dailyDose1,

    /// Number of daily second doses administered.
    @JsonKey(name: 'dailydose2') required int dailyDose2,

    /// Number of daily third (booster) doses administered, if any.
    @JsonKey(name: 'dailydose3') required int? dailyDose3,

    /// Number of daily fourth doses administered, if any.
    @JsonKey(name: 'dailydose4') required int? dailyDose4,

    /// The difference in total vaccinations compared to the previous day.
    @JsonKey(name: 'daydiff') required int dayDiff,

    /// The total vaccinations administered on the reference date.
    @JsonKey(name: 'daytotal') required int dayTotal,

    /// The date of reference for the statistics.
    @JsonKey(name: 'referencedate') required DateTime referenceDate,

    /// Cumulative count of first doses administered up to the reference date.
    @JsonKey(name: 'totaldose1') required int totalDose1,

    /// Cumulative count of second doses administered up to the reference date.
    @JsonKey(name: 'totaldose2') required int totalDose2,

    /// Cumulative count of third doses administered up to the reference date, if any.
    @JsonKey(name: 'totaldose3') required int? totalDose3,

    /// Cumulative count of fourth doses administered up to the reference date, if any.
    @JsonKey(name: 'totaldose4') required int? totalDose4,

    /// Total distinct persons who received at least one dose of vaccine, if tracked.
    @JsonKey(name: 'totaldistinctpersons') required int? totalDistinctPersons,

    /// The total vaccinations administered in the area up to the reference date.
    @JsonKey(name: 'totalvaccinations') required int totalVaccinations,
  }) = _VaccinationData;

  /// Creates a [VaccinationData] from a JSON map.
  factory VaccinationData.fromJson(Map<String, dynamic> json) =>
      _$VaccinationDataFromJson(json);
}
