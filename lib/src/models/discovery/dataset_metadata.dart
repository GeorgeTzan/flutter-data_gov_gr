import 'package:freezed_annotation/freezed_annotation.dart';

part 'dataset_metadata.freezed.dart';
part 'dataset_metadata.g.dart';

@freezed
class DatasetMetadata with _$DatasetMetadata {
  const factory DatasetMetadata({
    required String identifier,
    required String title,
    required String description,
    required List<String> keyword,
    required DateTime modified,
    required String publisher,
    @JsonKey(name: 'contact_point') required String? contactPoint,
    required String spatial,
    required String temporal,
    @JsonKey(name: 'accrual_periodicity') required String? accrualPeriodicity,
  }) = _DatasetMetadata;

  factory DatasetMetadata.fromJson(Map<String, dynamic> json) =>
      _$DatasetMetadataFromJson(json);
}
