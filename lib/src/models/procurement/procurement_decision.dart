import 'package:freezed_annotation/freezed_annotation.dart';

part 'procurement_decision.freezed.dart';
part 'procurement_decision.g.dart';

@freezed
class ProcurementDecision with _$ProcurementDecision {
  const factory ProcurementDecision({
    required String ada,
    required String adam,
    required String subject,
    required double amount,
    required String currency,
    required String organization,
    @JsonKey(name: 'organization_id') required String organizationId,
    required DateTime date,
    required String type,
    required String status,
    required String url,
  }) = _ProcurementDecision;

  factory ProcurementDecision.fromJson(Map<String, dynamic> json) =>
      _$ProcurementDecisionFromJson(json);
}
