import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/testing.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

const fixtures = 'test/fixtures/v2/domains';
const trafficId = '14560622-570b-479a-a05f-659afc3d92d8';
const vaccineId = 'd0c5e369-461d-4110-8930-f4b656c119d5';
const fireId = '3676d1d4-14e4-4758-a5c1-ac6279afe7d3';
final retrieved = DateTime.utc(2026, 10, 12, 14, 35, 50);
SourceProvenance provenance([int row = 2]) => SourceProvenance(
  resourceId: 'selected',
  sourceUrl: 'https://files.test/original.csv',
  retrievedAt: retrieved,
  sourceRow: row,
);
ResponseBody envelope(Object? value) => ResponseBody.fromString(
  jsonEncode({'success': true, 'result': value}),
  200,
);
JsonObject metadata(String name) => Map<String, Object?>.from(
  (jsonDecode(File('$fixtures/$name.metadata.json').readAsStringSync())
          as Map)['result']
      as Map,
);
DataGovClient clientFor(ScriptedAdapter adapter) {
  final client = DataGovClient(
    config: DataGovConfig(
      actionBaseUrl: Uri.parse('https://selected.test/api/3/action/'),
      retry: RetryPolicy(maxAttempts: 1),
    ),
    adapter: adapter,
  );
  addTearDown(client.close);
  return client;
}

void main() {
  test('traffic maps unchanged source numbers without unit conversion', () {
    final record = <String, Object?>{
      'date': '2025-08-29T00:00:00',
      'avg_in': 1000000000,
      'avg_out': '12.5',
      'max_in': null,
      'extra_source_column': ['retained'],
    };
    final value = InternetTraffic.fromSourceRecord(
      record,
      provenance: provenance(),
    );
    expect(value.avgIn, 1000000000);
    expect(value.avgOut, 12.5);
    expect(value.maxIn, isNull);
    expect(value.maxOut, isNull);
    expect(value.date.raw, record['date']);
    record['avg_in'] = 0;
    expect(value.raw['avg_in'], 1000000000);
    expect(
      () => (value.raw['extra_source_column'] as List).add('mutate'),
      throwsUnsupportedError,
    );
    final restored = InternetTraffic.fromJson(value.toJson());
    expect(restored.date.raw, value.date.raw);
    expect(restored.provenance.toJson(), value.provenance.toJson());
    expect(restored.raw, value.raw);
  });
  test('vaccination maps thirteen columns and retains string identity', () {
    final row = <String, Object?>{
      'area': 'Test area',
      'areaid': '001',
      'referencedate': '2023-12-05 00:00:00',
      'daytotal': '1',
      'daydiff': '-2',
      'totalvaccinations': '3',
      'totaldistinctpersons': '4',
      'dailydose1': '5',
      'dailydose2': '6',
      'dailydose3': '7',
      'totaldose1': '8',
      'totaldose2': '9',
      'totaldose3': '10',
      'extra': 'kept',
    };
    final value = VaccinationData.fromSourceRecord(
      row,
      provenance: provenance(),
    );
    expect(value.areaId, '001');
    expect(value.raw['areaid'], '001');
    expect(
      [
        value.dayTotal,
        value.dayDiff,
        value.totalVaccinations,
        value.totalDistinctPersons,
        value.dailyDose1,
        value.dailyDose2,
        value.dailyDose3,
        value.totalDose1,
        value.totalDose2,
        value.totalDose3,
      ],
      [1, -2, 3, 4, 5, 6, 7, 8, 9, 10],
    );
    expect(value.raw['extra'], 'kept');
    final sparse = VaccinationData.fromSourceRecord({
      'area': 'A',
      'areaid': '001',
      'referencedate': '2023-12-05',
      'dailydose1': ' ',
    }, provenance: provenance());
    expect(sparse.dailyDose1, isNull);
    expect(sparse.totalDistinctPersons, isNull);
    expect(
      VaccinationData.fromJson(value.toJson()).referenceDate.raw,
      value.referenceDate.raw,
    );
  });
  test('forest maps thirty source columns with absent end time nullable', () {
    const areas = [
      'forest_area_burned',
      'woodland_area_burned',
      'grove_area_burned',
      'low_vegetation_area_burned',
      'swamp_area_burned',
      'agricultural_area_burned',
      'crop_residue_area_burned',
      'dumping_ground_area_burned',
    ];
    const counts = [
      'firefighters',
      'wildland_crew',
      'volunteers',
      'army',
      'other_firefighters',
      'fire_trucks',
      'local_authorities_vehicles',
      'water_tank_trucks',
      'machinery',
      'helicopters',
      'airplanes_cl415',
      'airplanes_cl215',
      'airplanes_pzl',
      'airplanes_gru',
    ];
    final row = <String, Object?>{
      'start_time': '2014-01-02 11:33:00',
      'end_time': '',
      'fire_station': 'station',
      'prefecture': 'prefecture',
      'forestry': 'forestry',
      'municipality': 'municipality',
      'location': 'location',
      'address': 'address',
      for (var i = 0; i < areas.length; i++) areas[i]: '${i + 1}.5',
      for (var i = 0; i < counts.length; i++) counts[i]: '${i + 1}',
      'extra_source_column': 'preserved',
    };
    final fire = ForestFire.fromSourceRecord(row, provenance: provenance(9));
    expect(fire.endTime, isNull);
    expect(fire.provenance.sourceRow, 9);
    expect(
      [
        fire.fireStation,
        fire.prefecture,
        fire.forestry,
        fire.municipality,
        fire.location,
        fire.address,
      ],
      [
        'station',
        'prefecture',
        'forestry',
        'municipality',
        'location',
        'address',
      ],
    );
    expect(
      [
        fire.forestAreaBurned,
        fire.woodlandAreaBurned,
        fire.groveAreaBurned,
        fire.lowVegetationAreaBurned,
        fire.swampAreaBurned,
        fire.agriculturalAreaBurned,
        fire.cropResidueAreaBurned,
        fire.dumpingGroundAreaBurned,
      ],
      [1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5],
    );
    expect([
      fire.firefighters,
      fire.wildlandCrew,
      fire.volunteers,
      fire.army,
      fire.otherFirefighters,
      fire.fireTrucks,
      fire.localAuthoritiesVehicles,
      fire.waterTankTrucks,
      fire.machinery,
      fire.helicopters,
      fire.airplanesCl415,
      fire.airplanesCl215,
      fire.airplanesPzl,
      fire.airplanesGru,
    ], List.generate(14, (i) => i + 1));
    expect(fire.raw['extra_source_column'], 'preserved');
    expect(
      ForestFire.fromJson(fire.toJson()).startTime.raw,
      fire.startTime.raw,
    );
    expect(
      ForestFire.fromSourceRecord({
        'start_time': '2014-01-02',
      }, provenance: provenance()).firefighters,
      isNull,
    );
  });
  test(
    'missing, malformed dates and nonblank invalid numbers report field and row',
    () {
      for (final date in [null, '', 'bad date', '2025-02-30']) {
        expect(
          () => InternetTraffic.fromSourceRecord({
            'date': date,
          }, provenance: provenance(7)),
          throwsA(
            isA<DecodeException>()
                .having(
                  (e) => e.details,
                  'details',
                  containsPair('field', 'date'),
                )
                .having(
                  (e) => e.details,
                  'details',
                  containsPair('sourceRow', 7),
                ),
          ),
        );
      }
      expect(
        () => VaccinationData.fromSourceRecord({
          'area': 'A',
          'referencedate': '2023-12-05',
        }, provenance: provenance()),
        throwsA(isA<DecodeException>()),
      );
      expect(
        () => VaccinationData.fromSourceRecord({
          'area': 'A',
          'areaid': '1',
          'referencedate': '2023-12-05',
          'daytotal': '1.2',
        }, provenance: provenance()),
        throwsA(
          isA<DecodeException>().having(
            (e) => e.details,
            'details',
            containsPair('field', 'daytotal'),
          ),
        ),
      );
      expect(
        () => ForestFire.fromSourceRecord({
          'start_time': '2014-01-02',
          'forest_area_burned': 'NaN',
        }, provenance: provenance()),
        throwsA(isA<DecodeException>()),
      );
    },
  );
  final sourceDateDecoders = <String, SourceDate Function(String)>{
    'date': (value) => InternetTraffic.fromSourceRecord({
      'date': value,
    }, provenance: provenance(7)).date,
    'referencedate': (value) => VaccinationData.fromSourceRecord({
      'area': 'A',
      'areaid': '001',
      'referencedate': value,
    }, provenance: provenance(7)).referenceDate,
    'start_time': (value) => ForestFire.fromSourceRecord({
      'start_time': value,
    }, provenance: provenance(7)).startTime,
    'end_time': (value) => ForestFire.fromSourceRecord({
      'start_time': '2025-01-01',
      'end_time': value,
    }, provenance: provenance(7)).endTime!,
  };
  for (final offset in [
    '+99:99',
    '+01:99',
    '-99:99',
    '-01:99',
    '+2400',
    '-2400',
    '+0160',
    '-0160',
    '+24',
    '-24',
  ]) {
    test(
      'source dates reject overflowing timezone offset $offset with context',
      () {
        for (final decoder in sourceDateDecoders.entries) {
          expect(
            () => decoder.value('2025-01-01T00:00:00$offset'),
            throwsA(
              isA<DecodeException>()
                  .having(
                    (error) => error.details,
                    'details',
                    containsPair('field', decoder.key),
                  )
                  .having(
                    (error) => error.details,
                    'details',
                    containsPair('sourceRow', 7),
                  ),
            ),
            reason: 'Source date column ${decoder.key} must reject $offset',
          );
        }
      },
    );
  }
  test(
    'source dates retain valid timezone offset boundaries and accepted formats',
    () {
      for (final value in [
        '2025-01-01T00:00:00+23:59',
        '2025-01-01T00:00:00-23:59',
        '2025-01-01T00:00:00+2359',
        '2025-01-01T00:00:00-2359',
        '2025-01-01T00:00:00+23',
        '2025-01-01T00:00:00-23',
        '2025-01-01T00:00:00+00:00',
        '2025-01-01T00:00:00-00:00',
        '2025-01-01T00:00:00Z',
        '2025-01-01T00:00:00z',
        '2025-01-01 00:00:00.123+01:30',
        '2025-01-01T00:00+01',
        '2025-01-01 00:00:00',
        '2025-01-01',
      ]) {
        for (final decoder in sourceDateDecoders.values) {
          expect(decoder(value).raw, value);
        }
        final source = provenance(7);
        final model = InternetTraffic.fromSourceRecord({
          'date': value,
        }, provenance: source);
        expect(model.raw['date'], value);
        expect(model.provenance, same(source));
      }
    },
  );
  test(
    'public telecom resolves audited entry and composes selected DataStore query',
    () async {
      final entry = metadata('internet_traffic');
      final sample =
          jsonDecode(File('$fixtures/traffic.json').readAsStringSync()) as Map;
      final page = Map<String, Object?>.from(sample['result'] as Map)
        ..['total'] = 2;
      final adapter = ScriptedAdapter([
        (r) async => envelope(entry),
        (r) async => envelope(page),
      ]);
      final client = clientFor(adapter);
      TelecomService service = client.telecom;
      final values = await service
          .internetTraffic(
            query: DataStoreQuery(limit: 2, filters: {'date': 'source-filter'}),
          )
          .toList();
      expect(values.map((v) => v.avgIn), [213417606696, 207043717600]);
      expect(values.first.provenance.entryId, entry['id']);
      expect(values.first.provenance.sourceRow, 1);
      expect(
        values.first.provenance.sourceUrl,
        (entry['resources'] as List).first['url'],
      );
      expect(
        adapter.requests.first.uri.queryParameters['id'],
        'internet_traffic',
      );
      expect(
        adapter.requests.last.uri.queryParameters['resource_id'],
        trafficId,
      );
      expect(
        adapter.requests.last.uri.queryParameters['filters'],
        jsonEncode({'date': 'source-filter'}),
      );
      expect(adapter.requests.last.uri.host, 'selected.test');
    },
  );
  test('public health streams unchanged official vaccination cells', () async {
    final entry = metadata('mdg_emvolio');
    final adapter = ScriptedAdapter([
      (r) async => envelope(entry),
      (r) async => ResponseBody.fromString(
        File('$fixtures/vaccination.csv').readAsStringSync(),
        200,
      )..extra['dataGovFinalUrl'] = 'https://cdn.test/final-vaccination.csv',
    ]);
    HealthService service = clientFor(adapter).health;
    final before = DateTime.now().toUtc();
    final values = await service.vaccinations().toList();
    expect(values, hasLength(2));
    expect(values.first.areaId, '701');
    expect(values.first.dayDiff, -87);
    expect(values.first.totalDose3, 109759);
    expect(values.first.provenance.retrievedAt.isBefore(before), isFalse);
    expect(values.first.provenance.sourceRow, 2);
    expect(values.first.provenance.resourceId, vaccineId);
    expect(
      values.first.provenance.sourceUrl,
      (entry['resources'] as List).first['url'],
    );
    expect(
      values.first.provenance.sourceUrl,
      isNot('https://cdn.test/final-vaccination.csv'),
    );
    expect(
      values.first.provenance.publishedModified?.raw,
      (entry['resources'] as List).first['last_modified'],
    );
    expect(adapter.requests.first.uri.queryParameters['id'], 'mdg_emvolio');
  });
  test(
    'public environment requires selected member of two-resource fire entry',
    () async {
      final entry = metadata('mcp_forest_fires');
      final csvResources = (entry['resources'] as List)
          .where((r) => r['format'] == 'CSV')
          .toList();
      expect(csvResources, hasLength(2));
      final selected = csvResources.last as Map;
      final adapter = ScriptedAdapter([
        (r) async => envelope(entry),
        (r) async => ResponseBody.fromString(
          File('$fixtures/forest_fires.csv').readAsStringSync(),
          200,
        ),
      ]);
      EnvironmentService service = clientFor(adapter).environment;
      final values = await service
          .forestFires(resourceId: selected['id'] as String)
          .toList();
      expect(values.first.startTime.raw, '2014-01-02 11:33:00');
      expect(values.first.lowVegetationAreaBurned, 1);
      expect(values.first.firefighters, 3);
      expect(values.first.provenance.sourceUrl, selected['url']);
      expect(adapter.requests.last.uri.toString(), selected['url']);
      expect(
        adapter.requests.first.uri.queryParameters['id'],
        'mcp_forest_fires',
      );
    },
  );
  test(
    'all services reject resource IDs outside audited entry before data request',
    () async {
      for (final name in [
        'internet_traffic',
        'mdg_emvolio',
        'mcp_forest_fires',
      ]) {
        final adapter = ScriptedAdapter([
          (r) async => envelope(metadata(name)),
        ]);
        final client = clientFor(adapter);
        final operation = switch (name) {
          'internet_traffic' =>
            client.telecom.internetTraffic(resourceId: 'wrong').toList(),
          'mdg_emvolio' =>
            client.health.vaccinations(resourceId: 'wrong').toList(),
          _ => client.environment.forestFires(resourceId: 'wrong').toList(),
        };
        await expectLater(
          operation,
          throwsA(isA<UnsupportedResourceException>()),
        );
        expect(adapter.requests, hasLength(1));
      }
    },
  );
  test(
    'traffic validates its required source schema even for an empty page',
    () async {
      final adapter = ScriptedAdapter([
        (r) async => envelope(metadata('internet_traffic')),
        (r) async => envelope({
          'records': [],
          'fields': [
            {'id': 'avg_in'},
          ],
          'total': 0,
        }),
      ]);
      await expectLater(
        clientFor(adapter).telecom.internetTraffic().toList(),
        throwsA(
          isA<DecodeException>().having(
            (e) => e.details,
            'details',
            containsPair('field', 'date'),
          ),
        ),
      );
    },
  );
  test(
    'traffic rejects missing published source URL instead of inventing provenance',
    () async {
      final entry = metadata('internet_traffic');
      final resources = (entry['resources'] as List)
          .map((r) => Map<String, Object?>.from(r as Map))
          .toList();
      resources.first.remove('url');
      entry['resources'] = resources;
      final adapter = ScriptedAdapter([(r) async => envelope(entry)]);
      await expectLater(
        clientFor(adapter).telecom.internetTraffic().toList(),
        throwsA(isA<UnsupportedResourceException>()),
      );
      expect(adapter.requests, hasLength(1));
    },
  );
  test('telecom subscription cancellation aborts pending metadata', () async {
    final opened = Completer<RequestOptions>();
    final pending = Completer<ResponseBody>();
    final adapter = ScriptedAdapter([
      (r) {
        opened.complete(r);
        return pending.future;
      },
    ]);
    final client = clientFor(adapter);
    final subscription = client.telecom.internetTraffic().listen(
      (_) {},
      onError: (Object _) {},
    );
    final request = await opened.future;
    await subscription.cancel().timeout(const Duration(seconds: 2));
    await request.cancelToken!.whenCancel.timeout(const Duration(seconds: 2));
    expect(request.cancelToken!.isCancelled, isTrue);
  });
  for (final health in [true, false]) {
    for (final pendingMetadata in [true, false]) {
      test(
        '${health ? 'health' : 'environment'} subscription cancellation aborts pending ${pendingMetadata ? 'metadata' : 'download'}',
        () async {
          final opened = Completer<RequestOptions>();
          final pending = Completer<ResponseBody>();
          final adapter = ScriptedAdapter([
            if (!pendingMetadata)
              (r) async => envelope(
                metadata(health ? 'mdg_emvolio' : 'mcp_forest_fires'),
              ),
            (r) {
              opened.complete(r);
              return pending.future;
            },
          ]);
          final client = clientFor(adapter);
          final stream = health
              ? client.health.vaccinations()
              : client.environment.forestFires(resourceId: fireId);
          final subscription = stream.listen((_) {}, onError: (Object _) {});
          final request = await opened.future;
          await subscription.cancel().timeout(const Duration(seconds: 2));
          await request.cancelToken!.whenCancel.timeout(
            const Duration(seconds: 2),
          );
          expect(request.cancelToken!.isCancelled, isTrue);
        },
      );
    }
  }
  test(
    'CSV helpers validate required headers even when header is the only row',
    () async {
      for (final health in [true, false]) {
        final name = health ? 'mdg_emvolio' : 'mcp_forest_fires';
        final entry = metadata(name);
        final adapter = ScriptedAdapter([
          (r) async => envelope(entry),
          (r) async => ResponseBody.fromString(
            health ? 'area,areaid\n' : 'end_time\n',
            200,
          ),
        ]);
        final client = clientFor(adapter);
        await expectLater(
          health
              ? client.health.vaccinations().toList()
              : client.environment.forestFires(resourceId: fireId).toList(),
          throwsA(
            isA<DecodeException>().having(
              (e) => e.details,
              'details',
              containsPair('sourceRow', 1),
            ),
          ),
        );
      }
    },
  );
  test(
    'CSV helpers accept absent optional columns without inventing values',
    () async {
      for (final health in [true, false]) {
        final adapter = ScriptedAdapter([
          (r) async =>
              envelope(metadata(health ? 'mdg_emvolio' : 'mcp_forest_fires')),
          (r) async => ResponseBody.fromString(
            health
                ? 'area,areaid,referencedate\nA,001,2023-12-05\n'
                : 'start_time,end_time\n2014-01-02,\n',
            200,
          ),
        ]);
        final client = clientFor(adapter);
        if (health) {
          final value = (await client.health.vaccinations().toList()).single;
          expect(value.areaId, '001');
          expect(value.dailyDose1, isNull);
          expect(value.dayTotal, isNull);
          expect(value.totalDistinctPersons, isNull);
        } else {
          final value =
              (await client.environment
                      .forestFires(resourceId: fireId)
                      .toList())
                  .single;
          expect(value.endTime, isNull);
          expect(value.fireStation, isNull);
          expect(value.forestAreaBurned, isNull);
          expect(value.firefighters, isNull);
        }
      }
    },
  );
}
