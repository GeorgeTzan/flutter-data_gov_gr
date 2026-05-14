import 'package:freezed_annotation/freezed_annotation.dart';

part 'forest_fire.freezed.dart';
part 'forest_fire.g.dart';

@freezed
class ForestFire with _$ForestFire {
  const factory ForestFire({
    required DateTime date,
    required double area,
    required String location,
    @JsonKey(name: 'fire_type') required String? fireType,
    required String? cause,
  }) = _ForestFire;

  factory ForestFire.fromJson(Map<String, dynamic> json) =>
      _$ForestFireFromJson(json);
}
