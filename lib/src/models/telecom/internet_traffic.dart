import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/raw_json.dart';
import '../shared/source_converters.dart';
import '../shared/source_date.dart';
import '../shared/source_provenance.dart';

part 'internet_traffic.freezed.dart';
part 'internet_traffic.g.dart';

/// Published telecom source values, retaining raw cells and source provenance.
///
/// Numeric units are retained as published and are not inferred or converted.
@freezed
abstract class InternetTraffic with _$InternetTraffic {
  /// Creates source values; optional cells remain nullable.
  const factory InternetTraffic({
    /// The published `date` value.
    @SourceDateConverter() required SourceDate date,

    /// The published `avg_in` value.
    @JsonKey(name: 'avg_in') num? avgIn,

    /// The published `avg_out` value.
    @JsonKey(name: 'avg_out') num? avgOut,

    /// The published `max_in` value.
    @JsonKey(name: 'max_in') num? maxIn,

    /// The published `max_out` value.
    @JsonKey(name: 'max_out') num? maxOut,

    /// Immutable original source cells, including unknown columns.
    @ImmutableSourceConverter() required JsonObject raw,

    /// Selected source identity and measured retrieval time.
    @SourceProvenanceConverter() required SourceProvenance provenance,
  }) = _InternetTraffic;

  /// Restores the serialized model and its explicit source metadata.
  factory InternetTraffic.fromJson(Map<String, dynamic> json) =>
      _$InternetTrafficFromJson(json);

  /// Decodes documented source columns with field and row error context.
  factory InternetTraffic.fromSourceRecord(
    JsonObject record, {
    required SourceProvenance provenance,
  }) {
    final source = SourceRecordDecoder(record, provenance);
    return InternetTraffic(
      date: source.date('date'),
      avgIn: source.number('avg_in'),
      avgOut: source.number('avg_out'),
      maxIn: source.number('max_in'),
      maxOut: source.number('max_out'),
      raw: freezeJson(record),
      provenance: provenance,
    );
  }
}
