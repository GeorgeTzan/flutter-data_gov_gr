import 'package:freezed_annotation/freezed_annotation.dart';

part 'vaccination_data.freezed.dart';
part 'vaccination_data.g.dart';

@freezed
class VaccinationData with _$VaccinationData {
  const factory VaccinationData({
    required String area,
    @JsonKey(name: 'areaid') required int areaId,
    @JsonKey(name: 'dailydose1') required int dailyDose1,
    @JsonKey(name: 'dailydose2') required int dailyDose2,
    @JsonKey(name: 'daydiff') required int dayDiff,
    @JsonKey(name: 'daytotal') required int dayTotal,
    @JsonKey(name: 'referencedate') required DateTime referenceDate,
    @JsonKey(name: 'totaldose1') required int totalDose1,
    @JsonKey(name: 'totaldose2') required int totalDose2,
    @JsonKey(name: 'totalvaccinations') required int totalVaccinations,
  }) = _VaccinationData;

  factory VaccinationData.fromJson(Map<String, dynamic> json) =>
      _$VaccinationDataFromJson(json);
}
