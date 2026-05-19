// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procurement_decision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProcurementDecisionImpl _$$ProcurementDecisionImplFromJson(
        Map<String, dynamic> json) =>
    _$ProcurementDecisionImpl(
      ada: json['ada'] as String,
      adam: json['adam'] as String,
      subject: json['subject'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      organization: json['organization'] as String,
      organizationId: json['organization_id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      status: json['status'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$$ProcurementDecisionImplToJson(
        _$ProcurementDecisionImpl instance) =>
    <String, dynamic>{
      'ada': instance.ada,
      'adam': instance.adam,
      'subject': instance.subject,
      'amount': instance.amount,
      'currency': instance.currency,
      'organization': instance.organization,
      'organization_id': instance.organizationId,
      'date': instance.date.toIso8601String(),
      'type': instance.type,
      'status': instance.status,
      'url': instance.url,
    };
