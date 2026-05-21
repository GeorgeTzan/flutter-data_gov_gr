import '../client/data_gov_client.dart';

/// A service for fetching business and financial data (debts, budget, revenue) from data.gov.gr.
class BusinessService {
  final DataGovClient _client;

  /// Creates a new [BusinessService] instance.
  BusinessService(this._client);

  /// Fetches national debt statistics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getDebtStatistics(
      {DateTime? from, DateTime? to}) {
    return _client.generic
        .query('minfin_debt', parameters: _buildDateParams(from, to));
  }

  /// Fetches state budget execution statistics, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getBudgetExecution(
      {DateTime? from, DateTime? to}) {
    return _client.generic
        .query('minfin_budget', parameters: _buildDateParams(from, to));
  }

  /// Fetches state revenue data, optionally filtered by a date range.
  Future<List<Map<String, dynamic>>> getRevenueData(
      {DateTime? from, DateTime? to}) {
    return _client.generic
        .query('minfin_revenue', parameters: _buildDateParams(from, to));
  }

  Map<String, dynamic>? _buildDateParams(DateTime? from, DateTime? to) {
    if (from == null && to == null) return null;
    final params = <String, dynamic>{};
    if (from != null) {
      params['date_from'] = from.toIso8601String().split('T').first;
    }
    if (to != null) params['date_to'] = to.toIso8601String().split('T').first;
    return params;
  }
}
