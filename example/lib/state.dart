import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart' show createFixtureClient;
import 'package:flutter/foundation.dart';

/// Owns one client for the applied configuration, including explicit demo mode.
class SDKState extends ChangeNotifier {
  /// Creates an anonymous real client unless a factory is supplied.
  SDKState({DataGovClient Function(DataGovConfig, bool demo)? clientFactory})
    : _clientFactory = clientFactory ?? _createClient {
    _client = _clientFactory(_configuration, _demo);
  }

  final DataGovClient Function(DataGovConfig, bool) _clientFactory;
  DataGovConfig _configuration = DataGovConfig();
  bool _demo = false;
  bool _disposed = false;
  late DataGovClient _client;

  /// The client owned by the applied configuration.
  DataGovClient get client => _client;

  /// Whether the applied configuration uses synthetic fixtures.
  bool get demo => _demo;

  /// The applied CKAN action directory.
  Uri get actionBaseUrl => _configuration.actionBaseUrl;

  /// The applied optional credential, retained only in memory.
  String? get apiKey => _configuration.apiKey;

  static DataGovClient _createClient(DataGovConfig config, bool demo) =>
      demo ? createFixtureClient() : DataGovClient(config: config);

  /// Applies validated drafts atomically, closing the previously active client.
  void applyConfiguration({
    required Uri actionBaseUrl,
    String? apiKey,
    required bool demo,
  }) {
    if (_disposed) throw StateError('Configuration is disposed.');
    final token = apiKey?.trim();
    final config = DataGovConfig(
      actionBaseUrl: actionBaseUrl,
      apiKey: token == null || token.isEmpty ? null : token,
    );
    final replacement = _clientFactory(config, demo);
    final previous = _client;
    _configuration = config;
    _demo = demo;
    _client = replacement;
    previous.close();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _client.close();
    super.dispose();
  }
}
