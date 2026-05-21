import 'package:freezed_annotation/freezed_annotation.dart';

part 'forest_fire.freezed.dart';
part 'forest_fire.g.dart';

/// Represents details of a recorded forest fire incident in Greece.
@freezed
class ForestFire with _$ForestFire {
  /// Creates a new [ForestFire] instance.
  const factory ForestFire({
    /// The date when the fire was reported or occurred.
    required DateTime date,

    /// The total area burned (in square meters or hectares).
    required double area,

    /// The geographical location/region of the fire.
    required String location,

    /// The type of forest fire or vegetation burned.
    @JsonKey(name: 'fire_type') required String? fireType,

    /// The suspected or confirmed cause of the fire.
    required String? cause,
  }) = _ForestFire;

  /// Creates a [ForestFire] from a JSON map.
  factory ForestFire.fromJson(Map<String, dynamic> json) =>
      _$ForestFireFromJson(json);
}
