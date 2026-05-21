import '../client/data_gov_client.dart';
import '../models/procurement/procurement_decision.dart';

/// A service for fetching government procurement and contract decisions (KIMDIS) from data.gov.gr.
class ProcurementService {
  final DataGovClient _client;

  /// Creates a new [ProcurementService] instance.
  ProcurementService(this._client);

  /// Fetches KIMDIS procurement decisions, optionally filtered by a date range and issuing organization ID.
  Future<List<ProcurementDecision>> getKimdisDecisions({
    DateTime? from,
    DateTime? to,
    String? organizationId,
  }) async {
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
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
