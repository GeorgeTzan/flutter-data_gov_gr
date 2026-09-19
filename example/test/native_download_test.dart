import 'dart:io';
import 'dart:async';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:example/downloads/download_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:example/screens/resource_screen.dart';
import 'package:example/state.dart';
import 'catalog_flow_test.dart' hide main;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('download-regression-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => directory.path);
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await directory.delete(recursive: true);
  });
  for (final existing in [false, true]) {
    for (final cancelled in [false, true]) {
      test(
        'failed save existing=$existing cancelled=$cancelled preserves completed output',
        () async {
          final destination = File('${directory.path}/resource.csv');
          if (existing) await destination.writeAsString('completed original');
          Stream<List<int>> source() async* {
            yield 'partial replacement'.codeUnits;
            if (cancelled) throw CancelledException('cancelled transfer');
            throw StateError('publisher connection lost');
          }

          Object? failure;
          try {
            await saveDownload('resource.csv', source());
          } catch (error) {
            failure = error;
          }
          if (existing) {
            expect(await destination.readAsString(), 'completed original');
          } else {
            expect(await destination.exists(), isFalse);
          }
          expect(await directory.list().length, existing ? 1 : 0);
          expect(
            failure,
            cancelled ? isA<CancelledException>() : isA<StateError>(),
          );
        },
      );
    }
  }
  test(
    'successful save promotes complete bytes and replaces an existing destination',
    () async {
      final destination = File('${directory.path}/resource.csv');
      await destination.writeAsString('old');
      await saveDownload(
        'resource.csv',
        Stream.fromIterable(['complete '.codeUnits, 'replacement'.codeUnits]),
      );
      expect(await destination.readAsString(), 'complete replacement');
      expect(await directory.list().length, 1);
    },
  );
  testWidgets(
    'saved file displays response retrieval time before transfer completion',
    (tester) async {
      DateTime? firstByteAt;
      final first = Completer<void>();
      final finish = Completer<void>();
      Stream<Uint8List> bytes() async* {
        firstByteAt = DateTime.now().toUtc();
        first.complete();
        yield Uint8List.fromList('first'.codeUnits);
        await finish.future;
        yield Uint8List.fromList('last'.codeUnits);
      }

      final adapter = ScriptedAdapter([
        (_) async => ResponseBody(bytes(), 200),
      ]);
      final state = SDKState(clientFactory: (_, _) => scriptedClient(adapter));
      addTearDown(state.dispose);
      final selected = ResourceMetadata.fromJson(resource('selected'));
      await tester.pumpWidget(host(state, ResourceScreen(resource: selected)));
      await tester.tap(find.text('Save file'));
      await tester.runAsync(() async {
        final deadline = DateTime.now().add(const Duration(seconds: 3));
        while (!first.isCompleted && DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 1));
          await Future<void>.delayed(const Duration(milliseconds: 1));
        }
        expect(first.isCompleted, isTrue);
        await Future<void>.delayed(const Duration(milliseconds: 30));
        finish.complete();
        final destination = File('${directory.path}/selected.csv');
        for (var i = 0; i < 100 && !await destination.exists(); i++) {
          await tester.pump(const Duration(milliseconds: 1));
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(await destination.readAsString(), 'firstlast');
      });
      await settleSdk(tester);
      expect(find.text('File saved'), findsOneWidget);
      final text = tester
          .widget<Text>(find.textContaining('Retrieved (UTC):'))
          .data!;
      final observed = DateTime.parse(
        text.substring('Retrieved (UTC): '.length),
      );
      expect(observed.isAfter(firstByteAt!), isFalse);
      await tester.pumpWidget(
        host(
          state,
          ResourceScreen(resource: ResourceMetadata.fromJson(resource('new'))),
        ),
      );
      expect(find.textContaining('Retrieved (UTC):'), findsNothing);
    },
  );
}
