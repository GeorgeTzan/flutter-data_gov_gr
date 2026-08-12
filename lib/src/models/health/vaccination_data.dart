import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/raw_json.dart';
import '../shared/source_converters.dart';
import '../shared/source_date.dart';
import '../shared/source_provenance.dart';

part 'vaccination_data.freezed.dart';
part 'vaccination_data.g.dart';

/// Published health source values, retaining raw cells and source provenance.
///
/// Numeric units are retained as published and are not inferred or converted.
@freezed
abstract class VaccinationData with _$VaccinationData {
  /// Creates source values; optional cells remain nullable.
  const factory VaccinationData({
    /// The published `area` value.
    required String area,

    /// The published `areaid` value.
    @JsonKey(name: 'areaid') required String areaId,

    /// The published `referencedate` value.
    @SourceDateConverter()
    @JsonKey(name: 'referencedate')
    required SourceDate referenceDate,

    /// The published `daytotal` value.
    @JsonKey(name: 'daytotal') int? dayTotal,

    /// The published `daydiff` value.
    @JsonKey(name: 'daydiff') int? dayDiff,

    /// The published `totalvaccinations` value.
    @JsonKey(name: 'totalvaccinations') int? totalVaccinations,

    /// The published `totaldistinctpersons` value.
    @JsonKey(name: 'totaldistinctpersons') int? totalDistinctPersons,

    /// The published `dailydose1` value.
    @JsonKey(name: 'dailydose1') int? dailyDose1,

    /// The published `dailydose2` value.
    @JsonKey(name: 'dailydose2') int? dailyDose2,

    /// The published `dailydose3` value.
    @JsonKey(name: 'dailydose3') int? dailyDose3,

    /// The published `totaldose1` value.
    @JsonKey(name: 'totaldose1') int? totalDose1,

    /// The published `totaldose2` value.
    @JsonKey(name: 'totaldose2') int? totalDose2,

    /// The published `totaldose3` value.
    @JsonKey(name: 'totaldose3') int? totalDose3,

    /// Immutable original source cells, including unknown columns.
    @ImmutableSourceConverter() required JsonObject raw,

    /// Selected source identity and measured retrieval time.
    @SourceProvenanceConverter() required SourceProvenance provenance,
  }) = _VaccinationData;

  /// Restores the serialized model and its explicit source metadata.
  factory VaccinationData.fromJson(Map<String, dynamic> json) =>
      _$VaccinationDataFromJson(json);

  /// Decodes documented source columns with field and row error context.
  factory VaccinationData.fromSourceRecord(
    JsonObject record, {
    required SourceProvenance provenance,
  }) {
    final source = SourceRecordDecoder(record, provenance);
    return VaccinationData(
      area: source.string('area'),
      areaId: source.string('areaid'),
      referenceDate: source.date('referencedate'),
      dayTotal: source.integer('daytotal'),
      dayDiff: source.integer('daydiff'),
      totalVaccinations: source.integer('totalvaccinations'),
      totalDistinctPersons: source.integer('totaldistinctpersons'),
      dailyDose1: source.integer('dailydose1'),
      dailyDose2: source.integer('dailydose2'),
      dailyDose3: source.integer('dailydose3'),
      totalDose1: source.integer('totaldose1'),
      totalDose2: source.integer('totaldose2'),
      totalDose3: source.integer('totaldose3'),
      raw: freezeJson(record),
      provenance: provenance,
    );
  }
}
