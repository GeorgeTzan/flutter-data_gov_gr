import 'package:flutter/material.dart';
import 'package:data_gov_gr/data_gov_gr.dart';

class SDKState extends ChangeNotifier {
  bool _useMock = true;
  String _apiKey = '';
  
  late DataGovClient _client;

  SDKState() {
    _initClient();
  }

  bool get useMock => _useMock;
  DataGovClient get client => _client;

  void toggleMock(bool value) {
    _useMock = value;
    _initClient();
    notifyListeners();
  }

  void updateApiKey(String key) {
    _apiKey = key;
    if (!_useMock) {
      _initClient();
      notifyListeners();
    }
  }

  void _initClient() {
    if (_useMock) {
      _client = DataGovMockClient();
    } else {
      _client = DataGovClient(apiKey: _apiKey);
    }
  }
}
