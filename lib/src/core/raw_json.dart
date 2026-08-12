/// A JSON object retaining source keys and value types.
typedef JsonObject = Map<String, Object?>;

/// Copies a JSON object and recursively freezes its maps and lists.
///
/// Values outside the JSON data model and non-string map keys are rejected.
JsonObject freezeJson(JsonObject source) => Map<String, Object?>.unmodifiable(
  source.map((key, value) => MapEntry(key, _freezeValue(value))),
);

Object? _freezeValue(Object? value) {
  if (value is Map) {
    return freezeJson(Map<String, Object?>.from(value));
  }
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_freezeValue));
  }
  if (value == null || value is String || value is bool || value is num) {
    return value;
  }
  throw ArgumentError.value(value, 'source', 'Expected a JSON value');
}
