import 'dart:convert';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:dio/dio.dart';
import 'package:example/screens/catalog_screen.dart';
import 'package:example/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

ResponseBody action(Object? result) => ResponseBody.fromString(
  jsonEncode({'success': true, 'result': result}),
  200,
  headers: {
    'content-type': ['application/json'],
  },
);
Map<String, Object?> resource(
  String id, {
  String format = 'CSV',
  bool datastore = false,
}) => {
  'id': id,
  'name': 'Source $id',
  'format': format,
  'url': 'https://publisher.test/$id',
  'datastore_active': datastore,
};
Map<String, Object?> entry(String id, List<Map<String, Object?>> resources) => {
  'id': id,
  'name': id,
  'title': 'Entry $id',
  'type': 'dataset',
  'resources': resources,
};
DataGovClient scriptedClient(ScriptedAdapter adapter) => DataGovClient(
  config: DataGovConfig(
    retry: RetryPolicy(maxAttempts: 1),
    disposeInjectedAdapter: true,
  ),
  adapter: adapter,
);
Widget host(SDKState state, Widget child) => ChangeNotifierProvider.value(
  value: state,
  child: MaterialApp(home: child),
);

Future<void> startSdkRequest(
  WidgetTester tester,
  ScriptedAdapter adapter,
) async {
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (adapter.requests.isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  });
  expect(adapter.requests, hasLength(1));
}

Future<void> settleSdk(WidgetTester tester) async {
  // Dio schedules stream cleanup outside the binding's fake frame clock.
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(const Duration(seconds: 3));
    do {
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    } while (tester.binding.hasScheduledFrame &&
        DateTime.now().isBefore(deadline));
  });
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'retains search Future and paginates with all resource metadata',
    (tester) async {
      final adapter = ScriptedAdapter([
        (r) async {
          expect(r.uri.queryParameters['start'], '0');
          return action({
            'count': 101,
            'results': [
              entry('one', [resource('csv'), resource('pdf', format: 'PDF')]),
            ],
            'search_facets': {},
          });
        },
        (r) async {
          expect(r.uri.queryParameters['start'], '1');
          return action({
            'count': 101,
            'results': [
              entry('two', [resource('json', format: 'JSON')]),
            ],
            'search_facets': {},
          });
        },
        (_) async => action(
          entry('one', [resource('csv'), resource('pdf', format: 'PDF')]),
        ),
      ]);
      final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
      addTearDown(state.dispose);
      await tester.pumpWidget(host(state, const CatalogScreen()));
      await settleSdk(tester);
      await tester.pumpWidget(host(state, const CatalogScreen()));
      await settleSdk(tester);
      expect(adapter.requests, hasLength(1));
      await tester.tap(find.text('Next page'));
      await settleSdk(tester);
      expect(find.text('Entry two'), findsOneWidget);
      await tester.tap(find.text('Previous page'));
      await settleSdk(tester);
      expect(adapter.requests, hasLength(2));
      await tester.tap(find.text('Entry one'));
      await settleSdk(tester);
      expect(find.textContaining('Source csv'), findsOneWidget);
      expect(find.textContaining('Source pdf'), findsOneWidget);
      expect(find.text('Preview first 100 rows'), findsNothing);
      await tester.tap(find.textContaining('Source pdf'));
      await settleSdk(tester);
      expect(find.textContaining('PDF'), findsWidgets);
      expect(adapter.requests, hasLength(3));
    },
  );
}
