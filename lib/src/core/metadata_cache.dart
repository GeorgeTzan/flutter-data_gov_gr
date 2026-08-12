import '../client/data_gov_config.dart';
import 'raw_json.dart';

/// Retains successful metadata within TTL and JSON payload capacity bounds.
final class MetadataCache {
  /// Creates one client-owned cache with an optional clock for expiry.
  MetadataCache(MetadataCachePolicy policy, {DateTime Function()? now})
    : _policy = policy,
      _now = now ?? DateTime.now;

  final MetadataCachePolicy _policy;
  final DateTime Function() _now;
  final _entries = <String, _Entry>{};
  int _jsonBytes = 0;

  /// Returns live metadata for [key], or null when it is absent or expired.
  /// A successful read updates recency without extending the original TTL.
  Object? get(String key) {
    final entry = _entries[key];
    if (entry == null) {
      return null;
    }
    if (!_now().isBefore(entry.expiresAt)) {
      remove(key);
      return null;
    }
    _entries.remove(key);
    _entries[key] = entry;
    return entry.value;
  }

  /// Stores successful metadata using its UTF-8 JSON payload byte count.
  ///
  /// Maps and lists are copied and frozen; other values must already be
  /// immutable. Capacity accounts for JSON payload bytes, not Dart heap usage.
  /// An oversized replacement removes its old value without retaining the new
  /// one. A zero TTL disables retention. Negative [jsonBytes] are rejected.
  void put(String key, Object value, {required int jsonBytes}) {
    if (jsonBytes < 0) {
      throw ArgumentError.value(jsonBytes, 'jsonBytes', 'Must be nonnegative');
    }
    final now = _now();
    final expired = _entries.entries
        .where((entry) => !now.isBefore(entry.value.expiresAt))
        .map((entry) => entry.key)
        .toList();
    for (final expiredKey in expired) {
      remove(expiredKey);
    }
    remove(key);
    if (_policy.ttl == Duration.zero || jsonBytes > _policy.maxBytes) {
      return;
    }
    _entries[key] = _Entry(
      _freezeValue(value)!,
      jsonBytes,
      now.add(_policy.ttl),
    );
    _jsonBytes += jsonBytes;
    while (_entries.length > _policy.maxEntries ||
        _jsonBytes > _policy.maxBytes) {
      remove(_entries.keys.first);
    }
  }

  /// Removes metadata for [key].
  void remove(String key) {
    final entry = _entries.remove(key);
    if (entry != null) {
      _jsonBytes -= entry.jsonBytes;
    }
  }

  /// Removes retained metadata whose cache keys match [predicate].
  void removeWhere(bool Function(String key) predicate) {
    final keys = _entries.keys.where(predicate).toList();
    for (final key in keys) {
      remove(key);
    }
  }

  /// Removes all retained metadata.
  void clear() {
    _entries.clear();
    _jsonBytes = 0;
  }
}

Object? _freezeValue(Object? value) {
  if (value is Map) {
    return freezeJson(Map<String, Object?>.from(value));
  }
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_freezeValue));
  }
  return value;
}

final class _Entry {
  const _Entry(this.value, this.jsonBytes, this.expiresAt);

  final Object value;
  final int jsonBytes;
  final DateTime expiresAt;
}
