import '../client/data_gov_client.dart';
import '../models/procurement/procurement_decision.dart';

class ProcurementService {
  final DataGovClient _client;

  ProcurementService(this._client);

  Future<List<ProcurementDecision>> getKimdisDecisions({
    DateTime? from,
    DateTime? to,
    String? organizationId,
  }) async {
    final params = <String, dynamic>{};
    if (from != null)
      params['date_from'] = from.toIso8601String().split('T').first;
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    if (organizationId != null) params['organization_id'] = organizationId;

    final response = await _client.dio.get(
      'query/khmdhs_decisions',
      queryParameters: params,
    );

    final data = response.data as List;
    return data.map((json) => ProcurementDecision.fromJson(json)).toList();
  }
}
