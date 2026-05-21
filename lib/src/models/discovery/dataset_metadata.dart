import 'package:freezed_annotation/freezed_annotation.dart';

part 'dataset_metadata.freezed.dart';
part 'dataset_metadata.g.dart';

/// Represents the metadata of a dataset on data.gov.gr.
@freezed
class DatasetMetadata with _$DatasetMetadata {
  /// Creates a new [DatasetMetadata] instance.
  const factory DatasetMetadata({
    /// The unique identifier of the dataset (e.g., "mcp_forest_fires").
    required String identifier,

    /// The title/name of the dataset.
    required String title,

    /// The detailed description of the dataset contents.
    required String description,

    /// A list of keywords/tags associated with the dataset.
    required List<String> keyword,

    /// The date and time when the dataset was last updated/modified.
    required DateTime modified,

    /// The publishing organization or authority.
    required String publisher,

    /// The contact email or endpoint for the dataset.
    @JsonKey(name: 'contact_point') required String? contactPoint,

    /// The spatial/geographical coverage of the dataset.
    required String spatial,

    /// The temporal coverage of the dataset.
    required String temporal,

    /// The update frequency of the dataset.
    @JsonKey(name: 'accrual_periodicity') required String? accrualPeriodicity,
  }) = _DatasetMetadata;

  /// Creates a [DatasetMetadata] from a JSON map.
  factory DatasetMetadata.fromJson(Map<String, dynamic> json) =>
      _$DatasetMetadataFromJson(json);
}
