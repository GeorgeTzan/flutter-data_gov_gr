import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/core/metadata_cache.dart';
import 'package:data_gov_gr/src/models/catalog/resource_metadata.dart';
import 'package:test/test.dart';

void main() {
  late _Clock clock;
  late MetadataCache cache;

  setUp(() {
    clock = _Clock();
    cache = MetadataCache(MetadataCachePolicy.defaults, now: clock.now);
  });

  test('expires at five minutes without extending TTL on a read', () {
    cache.put('entry', 'value', jsonBytes: 7);
    clock.advance(const Duration(minutes: 4, seconds: 59));
    expect(cache.get('entry'), 'value');
    clock.advance(const Duration(seconds: 1));
    expect(cache.get('entry'), isNull);
  });

  test('evicts the least recently used entry after the 129th insert', () {
    for (var index = 0; index < 128; index++) {
      cache.put('entry-$index', index, jsonBytes: 3);
    }
    expect(cache.get('entry-0'), 0);
    cache.put('entry-128', 128, jsonBytes: 3);
    expect(cache.get('entry-1'), isNull);
    expect(cache.get('entry-0'), 0);
    for (var index = 2; index <= 128; index++) {
      expect(cache.get('entry-$index'), index);
    }
  });

  test('retains exactly eight MiB and evicts when payload bytes exceed it', () {
    cache.put('first', 'first', jsonBytes: 4194304);
    cache.put('second', 'second', jsonBytes: 4194304);
    expect(cache.get('first'), 'first');
    expect(cache.get('second'), 'second');
    cache.put('third', 'third', jsonBytes: 1);
    expect(cache.get('first'), isNull);
    expect(cache.get('second'), 'second');
    expect(cache.get('third'), 'third');
  });

  test('skips oversized entries without evicting other metadata', () {
    cache.put('small', 'small', jsonBytes: 10);
    cache.put('large', 'large', jsonBytes: 8388609);
    expect(cache.get('large'), isNull);
    expect(cache.get('small'), 'small');
  });

  test('oversized refresh removes the previous value', () {
    cache.put('entry', 'old', jsonBytes: 5);
    cache.put('entry', 'new', jsonBytes: 8388609);
    expect(cache.get('entry'), isNull);
  });

  test('replacement refreshes the TTL', () {
    cache.put('entry', 'old', jsonBytes: 5);
    clock.advance(const Duration(minutes: 4));
    cache.put('entry', 'new', jsonBytes: 5);
    clock.advance(const Duration(minutes: 1));
    expect(cache.get('entry'), 'new');
    clock.advance(const Duration(minutes: 4));
    expect(cache.get('entry'), isNull);
  });

  test('replacement becomes most recently used', () {
    cache = MetadataCache(MetadataCachePolicy(maxEntries: 2), now: clock.now);
    cache.put('first', 'old', jsonBytes: 5);
    cache.put('second', 'second', jsonBytes: 8);
    cache.put('first', 'new', jsonBytes: 5);
    cache.put('third', 'third', jsonBytes: 7);
    expect(cache.get('first'), 'new');
    expect(cache.get('second'), isNull);
    expect(cache.get('third'), 'third');
  });

  test('replacement subtracts the old payload size', () {
    cache = MetadataCache(MetadataCachePolicy(maxBytes: 10), now: clock.now);
    cache.put('first', 'old', jsonBytes: 8);
    cache.put('first', 'new', jsonBytes: 3);
    cache.put('second', 'second', jsonBytes: 7);
    expect(cache.get('first'), 'new');
    expect(cache.get('second'), 'second');
  });

  test('byte eviction removes as many LRU entries as necessary', () {
    cache = MetadataCache(MetadataCachePolicy(maxBytes: 10), now: clock.now);
    cache.put('first', 'first', jsonBytes: 4);
    cache.put('second', 'second', jsonBytes: 4);
    cache.put('third', 'third', jsonBytes: 9);
    expect(cache.get('first'), isNull);
    expect(cache.get('second'), isNull);
    expect(cache.get('third'), 'third');
  });

  test('discards expired entries before evicting live metadata', () {
    cache = MetadataCache(MetadataCachePolicy(maxEntries: 2), now: clock.now);
    cache.put('expired', 'expired', jsonBytes: 9);
    clock.advance(const Duration(minutes: 4));
    cache.put('live', 'live', jsonBytes: 6);
    expect(cache.get('expired'), 'expired');
    clock.advance(const Duration(minutes: 1));
    cache.put('new', 'new', jsonBytes: 5);
    expect(cache.get('expired'), isNull);
    expect(cache.get('live'), 'live');
    expect(cache.get('new'), 'new');
  });

  test('remove releases retained byte capacity', () {
    cache = MetadataCache(MetadataCachePolicy(maxBytes: 10), now: clock.now);
    cache.put('first', 'first', jsonBytes: 8);
    cache.remove('first');
    cache.remove('missing');
    cache.put('second', 'second', jsonBytes: 8);
    cache.put('third', 'third', jsonBytes: 2);
    expect(cache.get('first'), isNull);
    expect(cache.get('second'), 'second');
    expect(cache.get('third'), 'third');
  });

  test('clear removes all entries and releases byte capacity', () {
    cache = MetadataCache(MetadataCachePolicy(maxBytes: 10), now: clock.now);
    cache.put('first', 'first', jsonBytes: 8);
    cache.put('second', 'second', jsonBytes: 2);
    cache.clear();
    cache.put('third', 'third', jsonBytes: 10);
    expect(cache.get('first'), isNull);
    expect(cache.get('second'), isNull);
    expect(cache.get('third'), 'third');
  });

  test('separate client-owned caches isolate values and clearing', () {
    final other = MetadataCache(MetadataCachePolicy.defaults, now: clock.now);
    cache.put('shared-key', 'client-one', jsonBytes: 12);
    expect(other.get('shared-key'), isNull);
    other.put('shared-key', 'client-two', jsonBytes: 12);
    expect(cache.get('shared-key'), 'client-one');
    cache.clear();
    expect(other.get('shared-key'), 'client-two');
  });

  test('zero TTL disables retention', () {
    cache = MetadataCache(
      MetadataCachePolicy(ttl: Duration.zero),
      now: clock.now,
    );
    cache.put('entry', 'value', jsonBytes: 7);
    expect(cache.get('entry'), isNull);
  });

  test('null values cannot be retained', () {
    final dynamic nullable = null;
    expect(
      () => cache.put('entry', nullable, jsonBytes: 4),
      throwsA(isA<TypeError>()),
    );
    expect(cache.get('entry'), isNull);
  });

  test('rejects negative byte accounting before replacing metadata', () {
    cache.put('entry', 'old', jsonBytes: 5);
    expect(() => cache.put('entry', 'new', jsonBytes: -1), throwsArgumentError);
    expect(cache.get('entry'), 'old');
  });

  test('copies and recursively freezes JSON maps', () {
    final source = <String, Object?>{
      'nested': <Object?>[
        <String, Object?>{'name': 'published'},
        null,
      ],
    };
    cache.put('entry', source, jsonBytes: 38);
    final sourceList = source['nested']! as List<Object?>;
    (sourceList.first! as Map<String, Object?>)['name'] = 'changed';
    sourceList.add('extra');
    source.clear();
    final retained = cache.get('entry')! as Map<String, Object?>;
    expect(retained, {
      'nested': [
        {'name': 'published'},
        null,
      ],
    });
    final retainedList = retained['nested']! as List<Object?>;
    expect(() => retained.clear(), throwsUnsupportedError);
    expect(() => retainedList.add('extra'), throwsUnsupportedError);
    expect(
      () => (retainedList.first! as Map<String, Object?>).clear(),
      throwsUnsupportedError,
    );
  });

  test('copies and recursively freezes top-level JSON lists', () {
    final source = <Object?>[
      <Object?>['published'],
      <String, Object?>{'active': true},
      null,
    ];
    cache.put('entry', source, jsonBytes: 38);
    (source.first! as List<Object?>).clear();
    (source[1]! as Map<String, Object?>).clear();
    source.clear();
    final retained = cache.get('entry')! as List<Object?>;
    expect(retained, [
      ['published'],
      {'active': true},
      null,
    ]);
    expect(() => retained.clear(), throwsUnsupportedError);
    expect(
      () => (retained.first! as List<Object?>).clear(),
      throwsUnsupportedError,
    );
    expect(
      () => (retained[1]! as Map<String, Object?>).clear(),
      throwsUnsupportedError,
    );
  });

  test('retains already immutable metadata objects', () {
    final metadata = ResourceMetadata.fromJson({'id': 'resource'});
    cache.put('entry', metadata, jsonBytes: 17);
    expect(cache.get('entry'), same(metadata));
  });
}

final class _Clock {
  DateTime _value = DateTime.utc(2026, 10, 11);

  DateTime now() => _value;

  void advance(Duration duration) => _value = _value.add(duration);
}
