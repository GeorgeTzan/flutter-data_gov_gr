/// Explicit deterministic HTTP fixtures for testing the real v2 client.
///
/// No fixture data or scripted adapter is exported by the production library.
library;

export 'src/testing/fixture_client.dart' show createFixtureClient;
export 'src/testing/scripted_adapter.dart' show ScriptedAdapter, ScriptedStep;
