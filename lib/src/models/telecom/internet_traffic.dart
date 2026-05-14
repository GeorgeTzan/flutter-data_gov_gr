import 'package:freezed_annotation/freezed_annotation.dart';

part 'internet_traffic.freezed.dart';
part 'internet_traffic.g.dart';

@freezed
class InternetTraffic with _$InternetTraffic {
  const factory InternetTraffic({
    required DateTime date,
    required double inbound,
    required double outbound,
    @JsonKey(name: 'total_traffic') required double totalTraffic,
  }) = _InternetTraffic;

  factory InternetTraffic.fromJson(Map<String, dynamic> json) =>
      _$InternetTrafficFromJson(json);
}
