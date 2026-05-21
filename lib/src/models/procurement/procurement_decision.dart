import 'package:freezed_annotation/freezed_annotation.dart';

part 'procurement_decision.freezed.dart';
part 'procurement_decision.g.dart';

/// Represents a procurement decision published on KIMDIS (Greek Government Procurement Portal).
@freezed
class ProcurementDecision with _$ProcurementDecision {
  /// Creates a new [ProcurementDecision] instance.
  const factory ProcurementDecision({
    /// The unique reference code (ADA) of the decision.
    required String ada,

    /// The unique record code (ADAM) of the decision/contract.
    required String adam,

    /// The subject or description of the procurement.
    required String subject,

    /// The budget or contract amount.
    required double amount,

    /// The currency of the amount (typically EUR).
    required String currency,

    /// The organization that issued the decision.
    required String organization,

    /// The unique identifier of the issuing organization.
    @JsonKey(name: 'organization_id') required String organizationId,

    /// The date when the decision was published/signed.
    required DateTime date,

    /// The type of procurement decision (e.g. approval, contract).
    required String type,

    /// The current status of the decision (e.g. active, draft).
    required String status,

    /// The direct URL link to the official document PDF.
    required String url,
  }) = _ProcurementDecision;

  /// Creates a [ProcurementDecision] from a JSON map.
  factory ProcurementDecision.fromJson(Map<String, dynamic> json) =>
      _$ProcurementDecisionFromJson(json);
}
