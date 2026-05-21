import 'package:freezed_annotation/freezed_annotation.dart';

part 'internet_traffic.freezed.dart';
part 'internet_traffic.g.dart';

/// Represents GR-IX internet traffic volume statistics for a specific date.
@freezed
class InternetTraffic with _$InternetTraffic {
  /// Creates a new [InternetTraffic] instance.
  const factory InternetTraffic({
    /// The date when the traffic metrics were recorded.
    required DateTime date,

    /// The inbound traffic volume in gigabits or terabytes.
    required double inbound,

    /// The outbound traffic volume in gigabits or terabytes.
    required double outbound,

    /// The total combined internet traffic (inbound + outbound).
    @JsonKey(name: 'total_traffic') required double totalTraffic,
  }) = _InternetTraffic;

  /// Creates an [InternetTraffic] from a JSON map.
  factory InternetTraffic.fromJson(Map<String, dynamic> json) =>
      _$InternetTrafficFromJson(json);
}
