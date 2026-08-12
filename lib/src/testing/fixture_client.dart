import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../client/data_gov_client.dart';
import '../client/data_gov_config.dart';
import 'scripted_adapter.dart';

/// Creates the real v2 client with explicit, synthetic, single-use HTTP routes.
///
/// The entry `synthetic-traffic` contains `synthetic-traffic-csv`,
/// `synthetic-traffic-json`, and `synthetic-traffic-file`. Default catalog queries
/// and DataStore queries (default limit or limit 1) are supported. CSV/JSON and
/// binary downloads retain synthetic source identifiers. No network is used.
///
/// Each distinct registered request may be consumed once; cached metadata can
/// still be read repeatedly. Refreshing consumed metadata, repeating a file
/// download, or requesting an unregistered query raises a transport exception
/// whose original cause identifies the exhausted or missing fixture route.
/// Create a fresh fixture client for each independent scenario, and close it
/// after use. For custom requests or responses, inject a [ScriptedAdapter] into
/// [DataGovClient] instead.
DataGovClient createFixtureClient() {
  final routes = <String, ScriptedAdapter>{};
  void route(
    String path,
    Map<String, String> parameters,
    ResponseBody Function() response,
  ) {
    final uri = Uri.https(
      'fixtures.invalid',
      path,
      parameters.isEmpty ? null : parameters,
    );
    routes[_key(uri)] = ScriptedAdapter([(request) async => response()]);
  }

  void action(String name, Map<String, String> parameters, Object? result) {
    route(
      '/api/3/action/$name',
      parameters,
      () => ResponseBody.fromString(
        jsonEncode({'success': true, 'result': result}),
        200,
        headers: {
          'content-type': ['application/json'],
        },
      ),
    );
  }

  for (final size in [1, 100]) {
    for (final offset in [0, 1]) {
      action(
        'package_search',
        {'sort': 'id asc', 'start': '$offset', 'rows': '$size'},
        {
          'count': 1,
          'results': offset == 0 ? [_entry] : [],
          'search_facets': <String, Object?>{},
        },
      );
    }
  }
  action('package_show', {'id': 'synthetic-traffic'}, _entry);
  for (final resource in _resources) {
    action('resource_show', {'id': resource['id']! as String}, resource);
  }
  for (final limit in [1, 100]) {
    for (final offset in [0, 1, 2]) {
      action(
        'datastore_search',
        {
          'resource_id': 'synthetic-traffic-csv',
          'filters': '{}',
          'sort': '_id asc',
          'limit': '$limit',
          'offset': '$offset',
        },
        {
          'records': _records.skip(offset).take(limit).toList(),
          'fields': [
            {'id': '_id', 'type': 'int'},
            {'id': 'code', 'type': 'text'},
            {'id': 'value', 'type': 'int'},
          ],
          'offset': offset,
          'limit': limit,
          'total': 2,
          'total_was_estimated': false,
        },
      );
    }
  }
  route(
    '/files/traffic.csv',
    {},
    () => ResponseBody.fromString(
      'code,value\n00123,10\n00456,20\n',
      200,
      headers: {
        'content-type': ['text/csv; charset=utf-8'],
      },
    ),
  );
  route(
    '/files/traffic.json',
    {},
    () => ResponseBody.fromString(
      '[{"code":"00123","value":10},{"code":"00456","value":20}]',
      200,
      headers: {
        'content-type': ['application/json'],
      },
    ),
  );
  route(
    '/files/traffic.bin',
    {},
    () => ResponseBody(
      Stream.value(Uint8List.fromList([0, 1, 2, 255])),
      200,
      headers: {
        'content-type': ['application/octet-stream'],
        'content-length': ['4'],
      },
    ),
  );
  return DataGovClient(
    config: DataGovConfig(
      actionBaseUrl: Uri.parse('https://fixtures.invalid/api/3/action/'),
      retry: RetryPolicy(maxAttempts: 1),
      disposeInjectedAdapter: true,
    ),
    adapter: _FixtureAdapter(routes),
  );
}

const _resources = [
  {
    'id': 'synthetic-traffic-csv',
    'package_id': 'synthetic-traffic',
    'format': 'CSV',
    'url': 'https://fixtures.invalid/files/traffic.csv',
    'datastore_active': true,
  },
  {
    'id': 'synthetic-traffic-json',
    'package_id': 'synthetic-traffic',
    'format': 'JSON',
    'url': 'https://fixtures.invalid/files/traffic.json',
  },
  {
    'id': 'synthetic-traffic-file',
    'package_id': 'synthetic-traffic',
    'format': 'BIN',
    'url': 'https://fixtures.invalid/files/traffic.bin',
  },
];
const _entry = {
  'id': 'synthetic-traffic',
  'name': 'synthetic-traffic',
  'type': 'dataset',
  'title': 'Synthetic traffic fixture — not provider data',
  'resources': _resources,
};
const _records = [
  {'_id': 1, 'code': '00123', 'value': 10},
  {'_id': 2, 'code': '00456', 'value': 20},
];

String _key(Uri uri) {
  final names = uri.queryParametersAll.keys.toList()..sort();
  return uri
      .replace(
        queryParameters: names.isEmpty
            ? null
            : {for (final name in names) name: uri.queryParametersAll[name]!},
      )
      .toString();
}

final class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this._routes);
  final Map<String, ScriptedAdapter> _routes;
  final _consumed = <String>{};
  bool _closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (_closed) throw StateError('Fixture adapter is closed.');
    final key = _key(options.uri);
    final route = options.method == 'GET' ? _routes[key] : null;
    if (route == null) {
      throw StateError('No fixture route: ${options.method} $key');
    }
    if (!_consumed.add(key)) throw StateError('Fixture route exhausted: $key');
    return route.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    if (_closed) return;
    _closed = true;
    for (final route in _routes.values) {
      route.close(force: force);
    }
  }
}
