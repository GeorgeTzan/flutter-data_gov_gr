import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:example/screens/system_screen.dart';
import 'package:example/screens/monitor_screen.dart';
import 'package:example/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  test('initial mode is real and anonymous; apply and dispose close once', () {
    final adapters = <ScriptedAdapter>[];
    final configs = <DataGovConfig>[];
    final modes = <bool>[];
    final state = SDKState(
      clientFactory: (config, demo) {
        configs.add(config);
        modes.add(demo);
        final adapter = ScriptedAdapter([]);
        adapters.add(adapter);
        return DataGovClient(
          config: DataGovConfig(
            actionBaseUrl: config.actionBaseUrl,
            apiKey: config.apiKey,
            disposeInjectedAdapter: true,
          ),
          adapter: adapter,
        );
      },
    );
    expect(state.demo, isFalse);
    expect(configs.single.apiKey, isNull);
    state.applyConfiguration(
      actionBaseUrl: Uri.parse('https://proxy.test/api/3/action/'),
      apiKey: '  token  ',
      demo: true,
    );
    expect(adapters.first.closeCount, 1);
    expect(configs.last.apiKey, 'token');
    expect(modes, [false, true]);
    state.dispose();
    expect(adapters.map((a) => a.closeCount), [1, 1]);
  });

  testWidgets('typing is a draft, Apply replaces once, quota is unavailable', (
    tester,
  ) async {
    var creations = 0;
    final state = SDKState(
      clientFactory: (_, _) {
        creations++;
        return createFixtureClient();
      },
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: SystemScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unavailable'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('endpoint')),
      'https://proxy.test/api/3/action/',
    );
    await tester.enterText(find.byKey(const Key('token')), 'optional');
    expect(creations, 1);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(creations, 2);
    expect(state.actionBaseUrl.host, 'proxy.test');
  });

  testWidgets('Demo is explicit and visibly labeled', (tester) async {
    final state = SDKState();
    addTearDown(state.dispose);
    state.applyConfiguration(actionBaseUrl: state.actionBaseUrl, demo: true);
    final page = (await tester.runAsync(
      () => state.client.catalog.search(CatalogQuery()),
    ))!;
    expect(page.entries.single.title, contains('Synthetic'));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: SystemScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Demo — synthetic'), findsOneWidget);
  });

  testWidgets('demo monitor separates synthetic mode from provider samples', (
    tester,
  ) async {
    final state = SDKState();
    addTearDown(state.dispose);
    state.applyConfiguration(actionBaseUrl: state.actionBaseUrl, demo: true);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: MonitorScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Provider samples are unavailable in Demo'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('invalid Apply keeps the active client usable', () async {
    final state = SDKState(clientFactory: (_, _) => createFixtureClient());
    addTearDown(state.dispose);
    final client = state.client;
    expect(
      () => state.applyConfiguration(
        actionBaseUrl: Uri.parse('file:///bad/'),
        demo: false,
      ),
      throwsArgumentError,
    );
    expect(state.client, same(client));
    expect((await client.catalog.search(CatalogQuery())).entries, hasLength(1));
  });
}
