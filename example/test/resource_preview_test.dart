import 'dart:async';
import 'dart:typed_data';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:dio/dio.dart';
import 'package:example/screens/resource_screen.dart';
import 'package:example/downloads/download.dart' show bufferBrowserDownload;
import 'package:example/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'catalog_flow_test.dart' hide main;

void main() {
  test(
    'browser save rejects over 16 MiB and cancels the remaining source',
    () async {
      var produced = 0;
      var stopped = false;
      Stream<List<int>> source() async* {
        final chunk = Uint8List(1024 * 1024);
        try {
          for (var i = 0; i < 100; i++) {
            produced++;
            yield chunk;
          }
        } finally {
          stopped = true;
        }
      }

      await expectLater(bufferBrowserDownload(source()), throwsStateError);
      expect(produced, 17);
      expect(stopped, isTrue);
    },
  );

  testWidgets(
    'successful preview shows completion time and clears it on configuration and resource replacement',
    (tester) async {
      final adapter = ScriptedAdapter([
        (_) async => ResponseBody.fromString('value\nsource\n', 200),
      ]);
      final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
      addTearDown(state.dispose);
      final metadata = ResourceMetadata.fromJson({
        ...resource('csv'),
        'last_modified': '2020-01-02',
      });
      await tester.pumpWidget(host(state, ResourceScreen(resource: metadata)));
      expect(find.textContaining('Preview completed (UTC):'), findsNothing);
      await tester.tap(find.text('Preview first 100 rows'));
      await settleSdk(tester);
      expect(find.textContaining('Preview completed (UTC):'), findsOneWidget);
      expect(find.text('Published modification: 2020-01-02'), findsOneWidget);
      state.applyConfiguration(
        actionBaseUrl: Uri.parse('https://proxy.test/api/3/action/'),
        demo: false,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Preview completed (UTC):'), findsNothing);
      await tester.pumpWidget(
        host(
          state,
          ResourceScreen(resource: ResourceMetadata.fromJson(resource('new'))),
        ),
      );
      expect(find.textContaining('Preview completed (UTC):'), findsNothing);
    },
  );

  testWidgets('preview stops at 100 rows and cancels the source', (
    tester,
  ) async {
    var chunksRead = 0;
    var cancelled = false;
    final chunks = Stream<Uint8List>.multi((controller) {
      var n = -1;
      Timer? timer;
      timer = Timer.periodic(const Duration(milliseconds: 1), (_) {
        if (n > 1000) {
          controller.close();
          timer!.cancel();
          return;
        }
        chunksRead++;
        controller.add(
          Uint8List.fromList((n++ < 0 ? 'value\n' : '$n\n').codeUnits),
        );
      });
      controller.onCancel = () {
        cancelled = true;
        timer?.cancel();
      };
    });
    final adapter = ScriptedAdapter([(_) async => ResponseBody(chunks, 200)]);
    final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        ResourceScreen(resource: ResourceMetadata.fromJson(resource('csv'))),
      ),
    );
    await tester.tap(find.text('Preview first 100 rows'));
    for (var i = 0; i < 110; i++) {
      await tester.pump(const Duration(milliseconds: 2));
    }
    expect(find.text('100 rows shown'), findsOneWidget);
    expect(chunksRead, lessThan(105));
    expect(cancelled, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsupported formats and publisher failures are honest', (
    tester,
  ) async {
    final adapter = ScriptedAdapter([
      (_) async => ResponseBody.fromString('Publisher unavailable', 503),
    ]);
    final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        ResourceScreen(
          resource: ResourceMetadata.fromJson(resource('pdf', format: 'PDF')),
        ),
      ),
    );
    await tester.tap(find.text('Preview first 100 rows'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Preview unavailable for PDF'), findsOneWidget);
    expect(adapter.requests, isEmpty);
    await tester.pumpWidget(
      host(
        state,
        ResourceScreen(resource: ResourceMetadata.fromJson(resource('csv'))),
      ),
    );
    await tester.tap(find.text('Preview first 100 rows'));
    await settleSdk(tester);
    expect(find.textContaining('503'), findsOneWidget);
  });

  testWidgets('stale_request_does_not_update_replaced_screen', (tester) async {
    final delayed = Completer<ResponseBody>();
    final adapter = ScriptedAdapter([(_) => delayed.future]);
    final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        ResourceScreen(resource: ResourceMetadata.fromJson(resource('old'))),
      ),
    );
    await tester.tap(find.text('Preview first 100 rows'));
    await startSdkRequest(tester, adapter);
    await tester.pumpWidget(
      host(
        state,
        ResourceScreen(resource: ResourceMetadata.fromJson(resource('new'))),
      ),
    );
    delayed.complete(ResponseBody.fromString('value\nstale\n', 200));
    await tester.pumpAndSettle();
    expect(find.textContaining('stale'), findsNothing);
    expect(find.text('0 rows shown'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'DataStore source requires a choice and stops after one preview page',
    (tester) async {
      final adapter = ScriptedAdapter([
        (request) async {
          expect(request.uri.queryParameters['resource_id'], 'selected');
          expect(request.uri.queryParameters['limit'], '100');
          return action({
            'records': [
              for (var i = 1; i <= 100; i++) {'_id': i, 'value': 'row $i'},
            ],
            'fields': [
              {'id': '_id', 'type': 'int'},
              {'id': 'value', 'type': 'text'},
            ],
            'offset': 0,
            'limit': 100,
            'total': 1000,
          });
        },
      ]);
      final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
      addTearDown(state.dispose);
      await tester.pumpWidget(
        host(
          state,
          ResourceScreen(
            resource: ResourceMetadata.fromJson(
              resource('selected', datastore: true),
            ),
          ),
        ),
      );
      final preview = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Preview first 100 rows'),
      );
      expect(preview.onPressed, isNull);
      expect(adapter.requests, isEmpty);
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DataStore table').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preview first 100 rows'));
      await settleSdk(tester);
      expect(find.text('100 rows shown'), findsOneWidget);
      expect(adapter.requests, hasLength(1));
    },
  );

  testWidgets('dispose cancels a request before its late completion', (
    tester,
  ) async {
    final delayed = Completer<ResponseBody>();
    final adapter = ScriptedAdapter([(_) => delayed.future]);
    final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        ResourceScreen(resource: ResourceMetadata.fromJson(resource('old'))),
      ),
    );
    await tester.tap(find.text('Preview first 100 rows'));
    await startSdkRequest(tester, adapter);
    await tester.pumpWidget(const SizedBox());
    expect(adapter.requests.single.cancelToken!.isCancelled, isTrue);
    delayed.complete(ResponseBody.fromString('value\nlate\n', 200));
    await settleSdk(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Apply cancels old preview while keeping the selected resource', (
    tester,
  ) async {
    final delayed = Completer<ResponseBody>();
    final oldAdapter = ScriptedAdapter([(_) => delayed.future]);
    final newAdapter = ScriptedAdapter([]);
    var creations = 0;
    final state = SDKState(
      clientFactory: (_, _) =>
          scriptedClient(creations++ == 0 ? oldAdapter : newAdapter),
    );
    addTearDown(state.dispose);
    final selected = ResourceMetadata.fromJson(resource('selected'));
    await tester.pumpWidget(host(state, ResourceScreen(resource: selected)));
    await tester.tap(find.text('Preview first 100 rows'));
    await startSdkRequest(tester, oldAdapter);
    state.applyConfiguration(
      actionBaseUrl: Uri.parse('https://proxy.test/api/3/action/'),
      demo: false,
    );
    await tester.pump();
    delayed.complete(ResponseBody.fromString('value\nstale\n', 200));
    await settleSdk(tester);
    expect(find.text('Source selected'), findsOneWidget);
    expect(find.text('0 rows shown'), findsOneWidget);
    expect(find.textContaining('stale'), findsNothing);
    expect(oldAdapter.closeCount, 1);
    expect(newAdapter.requests, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Demo remains labeled on a selected resource', (tester) async {
    final state = SDKState();
    addTearDown(state.dispose);
    state.applyConfiguration(actionBaseUrl: state.actionBaseUrl, demo: true);
    await tester.pumpWidget(
      host(
        state,
        ResourceScreen(
          resource: ResourceMetadata.fromJson(resource('selected')),
        ),
      ),
    );
    expect(find.text('Demo — synthetic data'), findsOneWidget);
  });

  testWidgets('long resource metadata remains usable on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = SDKState(clientFactory: (_, _) => createFixtureClient());
    addTearDown(state.dispose);
    final metadata = ResourceMetadata.fromJson({
      ...resource('long'),
      'name':
          'A long published resource title describing observations across many geographical regions',
      'url':
          'https://publisher.test/${List.filled(30, 'published-resource-path').join('/')}.csv',
    });
    await tester.pumpWidget(host(state, ResourceScreen(resource: metadata)));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Preview first 100 rows'));
    expect(tester.takeException(), isNull);
  });
}
