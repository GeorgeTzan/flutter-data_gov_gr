# data_gov_gr

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![pub package](https://img.shields.io/pub/v/data_gov_gr.svg)](https://pub.dev/packages/data_gov_gr)

An unofficial, pure Dart SDK for the Greek Government Open Data catalog at [data.gov.gr](https://data.gov.gr). Use it from Dart or Flutter to discover entries, select published resources, query supported DataStore tables, and read or download files.

See [SUPPORT.md](SUPPORT.md) for supported operations and source limitations. The SDK targets Dart 3.8 or later; the Flutter example has its own Dart 3.11 requirement.

## Coverage

Catalog discovery retains datasets, services, decisions, unknown entry types, and every published resource. Downloads require usable published HTTP(S) file URLs. DataStore queries require source support. CSV and JSON have built-in readers; other files can be downloaded for your application to parse.

This scope does not guarantee healthy publisher links, structured queries for every resource, or CKAN compatibility for external service APIs. Production requests return data from the selected source and report failures explicitly. See the [official portal API guide](https://data-gov-gr.gitbook.io/guides/texnika-egxeiridia/data.gov.gr/metadedomena/tekmiriosi-api).

## Anonymous quick start

Add the package:

```yaml
dependencies:
  data_gov_gr: ^2.0.0
```

Public reads do not require a token. Inspect the resource list and select by ID rather than taking the first resource:

```dart
import 'package:data_gov_gr/data_gov_gr.dart';

Future<void> main() async {
  final client = DataGovClient();
  try {
    final page = await client.catalog.search(
      CatalogQuery(text: 'traffic', pageSize: 20),
    );
    for (final entry in page.entries) {
      print('${entry.name}: ${entry.title ?? entry.id}');
    }

    final entry = await client.catalog.getEntry('internet_traffic');
    for (final resource in entry.resources) {
      print('${resource.id}: ${resource.format} ${resource.url}');
    }
    final resource = entry.resources.singleWhere(
      (resource) => resource.id == '14560622-570b-479a-a05f-659afc3d92d8',
    );
    final records = await client.datastore.search(
      resource.id,
      DataStoreQuery(limit: 20, sort: [DataStoreSort('_id')]),
    );
    for (final row in records.records) {
      print(row);
    }
  } finally {
    client.close();
  }
}
```

This is an audited traffic resource selection, not a promise of permanent availability or recent observations. Inspect current metadata and handle source/schema failures.

## Pagination and server queries

`catalog.search` and `datastore.search` return one page. `catalog.entries`, `datastore.pages`, and `datastore.records` traverse pages on demand. Default catalog page size and DataStore limit are 100. Traversal advances by actual returned count, including server-clamped pages. Offset traversal is not a snapshot: source records can change while it runs.

```dart
import 'package:data_gov_gr/data_gov_gr.dart';

Future<void> previewTraffic(DataGovClient client) async {
  final rows = client.datastore.records(
    '14560622-570b-479a-a05f-659afc3d92d8',
    DataStoreQuery(
      fields: ['_id', 'date', 'avg_in', 'avg_out'],
      sort: [DataStoreSort('_id')],
      limit: 100,
    ),
  );
  await for (final row in rows.take(20)) {
    print(row);
  }
}
```

`DataStoreQuery` accepts exact `filters`, full-text `text`, projected `fields`, ordered `sort`, `limit`, and `offset`. These run on the server. File readers do not accept DataStore filters. The audited portal does not expose a supported SQL action.

## Files and typed helpers

Choose a resource from its entry before reading it. CSV cells remain strings, including leading zeros and empty values:

```dart
import 'package:data_gov_gr/data_gov_gr.dart';

Future<void> previewVaccinations(DataGovClient client) async {
  final entry = await client.catalog.getEntry('mdg_emvolio');
  final resource = entry.resources.singleWhere(
    (resource) => resource.id == 'd0c5e369-461d-4110-8930-f4b656c119d5',
  );
  await for (final row in client.resources.csvRows(resource).take(5)) {
    print(row);
  }
}
```

`resources.download(resource)` returns a `ResourceDownload` with a single-subscription `bytes` stream and provenance. Your application chooses storage. `resources.readJson(resource)` preserves JSON shape; `resources.jsonObjectRows(document, select: ...)` selects object rows explicitly. CSV defaults to UTF-8 and comma delimiters; use `CsvOptions` for another supported encoding or delimiter.

Typed streams are `client.telecom.internetTraffic()`, `client.health.vaccinations()`, and `client.environment.forestFires(resourceId: selectedId)`. Forest fires require explicit resource selection. Models retain `raw` source values and `provenance`; missing optional measurements remain null. Traffic has no derived-unit conversion, and burned-area units remain unspecified.

## Errors, cancellation, and lifecycle

Catch SDK exceptions around both initial calls and returned stream consumption. The application owns the cancellation controller:

```dart
import 'package:data_gov_gr/data_gov_gr.dart';

Future<void> loadCatalogPreview(
  DataGovClient client,
  CancellationSignal cancellation,
) async {
  try {
    await for (final entry in client.catalog.entries(
      CatalogQuery(pageSize: 20),
      cancellation: cancellation,
    ).take(20)) {
      print(entry.name);
    }
  } on CancelledException {
    return;
  } on DataGovException catch (error) {
    print('${error.action}: ${error.message}');
  }
}
```

Create a `CancellationController`, pass its `signal`, and call `cancel('Screen closed')` when work is replaced or abandoned. Stream cancellation stops active requests and future pages. Keep one client per active configuration and call `close()` when finished. Closing is idempotent, cancels work, and rejects new calls. Injected adapters remain caller-owned unless `DataGovConfig(disposeInjectedAdapter: true)` transfers disposal to the client.

Downloads and CSV reads default to 64 MiB of decoded bytes; JSON defaults to 8 MiB. Options can raise the limit or disable it explicitly with `maxBytes: null`. Networking defaults to three attempts including the first, a 30-second request timeout, and a 60-second operation deadline per page or complete file transfer. Downloads do not retry after emitting bytes.

Metadata lookups use a client-local cache with a five-minute TTL, up to 128 entries and 8 MiB of JSON payload. Use `refresh: true` on supported metadata calls or `client.catalog.clearCache()`. Search results, tables, and files are not cached by default. Check `client.currentRateLimitStatus.available`; nullable quotas are distinct from zero.

## Flutter Web and optional credentials

Flutter Web needs an application backend or same-origin proxy for portal requests under the audited CORS policy. Configure `DataGovConfig(actionBaseUrl: Uri.parse('https://your-app.example/ckan/api/3/action/'))` to use your deployed CKAN proxy.

That setting only changes CKAN requests. Resource URLs remain intact in SDK metadata. Downloads also need publisher CORS support or explicit routing through an allowlisted resource-host proxy. Your backend can return resource links rewritten to its own proxy URLs, or your application can inject a routing adapter. Configure portal/resource-host allowlists, preflight handling, and response streaming. See [browser setup](SUPPORT.md#browser-setup).

If your deployment needs an API key, use `DataGovConfig(apiKey: ...)` on a trusted server. Keep secrets server-side; browser bundles cannot keep them private. CKAN credentials are not forwarded to external resource origins or redirect destinations.

## Explicit offline fixtures

Fixtures are available only through the testing library:

```dart
import 'package:data_gov_gr/testing.dart';

void main() {
  final client = createFixtureClient();
  client.close();
}
```

Use `createFixtureClient()` or `ScriptedAdapter` for offline tests and visibly labelled demos. Production never falls back to fixtures.

See [CONTRIBUTING.md](CONTRIBUTING.md) for development and validation commands. Licensed under [MIT](LICENSE).
