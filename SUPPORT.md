# Support and source boundaries

`data_gov_gr` is an unofficial SDK for the [data.gov.gr catalog](https://data.gov.gr). The default [CKAN action directory](https://data.gov.gr/api/3/action/) and [official API guide](https://data-gov-gr.gitbook.io/guides/texnika-egxeiridia/data.gov.gr/metadedomena/tekmiriosi-api) describe the portal surface.

## Operations

| Source or format | Discovery and metadata | Download | Structured access |
| --- | --- | --- | --- |
| Public entries of any kind | Search/traversal, entry/resource metadata, organizations, themes | Depends on each resource | Depends on each resource |
| Supported CKAN DataStore resource | Retained | Only with a usable file URL | Resource-specific server query, page/record streams |
| CSV file | Retained | Usable HTTP(S) file URL required | Streaming rows; string cells; explicit delimiter/encoding |
| JSON or GeoJSON file | Retained | Usable HTTP(S) file URL required | Bounded JSON; explicit object-row/features selection |
| XML, PDF, ZIP, XLS/XLSX, SHAPE-ZIP, KML, images, other files | Retained | Usable HTTP(S) file URL required | Application parsing; no built-in parser |
| Service-only entry or external provider API | Endpoints/resources retained | Service endpoints are not treated as files | Separate provider adapter/design required |
| Broken, missing, malformed, or non-HTTP(S) URL | Resource remains discoverable | Explicit failure | No fabricated replacement |

Full catalog scope means retaining all entry kinds and resource metadata and traversing beyond the first page. It does not guarantee publisher uptime, parsing every format, or CKAN compatibility for external APIs. CSV/JSON support does not make DataStore filters apply to files. The audited portal does not support `datastore_search_sql`; exact native filters are available where DataStore itself is supported.

Downloads do not extract archives or write files to disk. Applications select storage and additional parsers. Format labels do not prove valid content. Production never falls back to fixtures or silently substitutes another resource.

## Typed helpers

| Helper | Catalog entry | Selected source |
| --- | --- | --- |
| `telecom.internetTraffic()` | `internet_traffic` | Audited DataStore default `14560622-570b-479a-a05f-659afc3d92d8`; explicit override allowed |
| `health.vaccinations()` | `mdg_emvolio` | Audited CSV default `d0c5e369-461d-4110-8930-f4b656c119d5`; explicit override allowed |
| `environment.forestFires(resourceId: ...)` | `mcp_forest_fires` | Explicit CSV selection required; audited IDs include `3676d1d4-14e4-4758-a5c1-ac6279afe7d3` and `92018a96-be9a-49df-82a2-7eafc39a82d1` |

Helpers resolve metadata and validate the selected resource. IDs/schemas can change. Required-field failures are errors with context. Models retain `raw` and `provenance`; optional values remain null. Traffic averages/maxima retain source values without unit conversion. Burned-area categories retain source values with unspecified units. Retrieval time is not observation time and does not establish measurement freshness.

Fuel/procurement APIs and other external services have no built-in provider client. Discover actual catalog resources or integrate an explicitly chosen external provider through a separate adapter. This does not assert those subjects lack public data.

## Bounds and consistency

| Setting | Default |
| --- | --- |
| Catalog page size / DataStore limit | 100 / 100 |
| Catalog traversal order | `id asc` |
| DataStore order without explicit sort | `_id asc`; source support required |
| Download/CSV decoded-byte ceiling | 64 MiB (67,108,864 bytes) |
| JSON decoded-byte ceiling | 8 MiB (8,388,608 bytes) |
| Request timeout / operation deadline | 30 seconds / 60 seconds |
| Attempts including initial request | At most three |
| Backoff | Starts at 250 ms with jitter; capped at 2 seconds |
| Metadata cache | Five-minute TTL, 128 entries, 8 MiB retained JSON |

Options/policies validate their configuration. Byte ceilings may be raised or disabled explicitly with `maxBytes: null`. Actual decoded bytes count even without accurate content length. JSON buffers within its limit; downloads/CSV stream under consumer demand.

The deadline includes retries and applies to each action/page or complete file transfer. Traversal starts a new deadline per page. Retry policy handles transient failures and valid `Retry-After` timing; it does not retry decoding, authorization, cancellation, or downloads after bytes were emitted.

Traversal advances by returned count and stops on an empty page or reliable total. A short page alone does not prove completion. Offset traversal cannot offer snapshot consistency while data changes; nonprogress raises a pagination failure. An audit records count changes, duplicates, failures, and traversal completeness separately from file parsing/download success.

Successful entry/resource lookups, organization pages, and themes are cached by default. Search results, records, and files are not cached; failures do not trigger stale-data fallback. Quotas require usable response headers: unknown limits, remaining counts, and reset times stay null rather than becoming zero.

## Browser setup

Audited portal CORS behavior requires a backend or same-origin proxy for Flutter Web portal access. Proxy deployment is the application's responsibility; the package provides no hosted proxy.

Configure an absolute action directory ending in `/`:

```dart
import 'package:data_gov_gr/data_gov_gr.dart';

void main() {
  final client = DataGovClient(
    config: DataGovConfig(
      actionBaseUrl: Uri.parse('https://your-app.example/ckan/api/3/action/'),
    ),
  );
  client.close();
}
```

Forward allowlisted portal actions with their methods, parameters, envelopes, relevant headers, and cancellation/streaming behavior. Handle preflight where required and keep optional credentials on the backend.

Changing `actionBaseUrl` only routes CKAN requests. The SDK preserves resource URLs from received metadata. Downloads need publisher CORS permission or explicit resource-host proxy routing. A backend may return links rewritten to allowlisted same-origin download routes, or the application may inject a routing adapter. Configure allowed resource hosts and validate redirects; do not expose an unrestricted URL-fetch proxy. A portal-only proxy does not automatically make downloads work.

Native applications still depend on publisher availability and valid URLs.

## Reporting problems

Open an issue in the [repository tracker](https://github.com/GeorgeTzan/flutter-data_gov_gr/issues) with SDK/runtime version, operation, entry/resource ID, platform, sanitized error, and a small reproduction. For web requests include the proxy route and affected resource host. Omit credentials/private headers.

Distinguish SDK failures from outages or unsupported APIs. Include actual live evidence when available and label fixtures explicitly. See [CONTRIBUTING.md](CONTRIBUTING.md) for live checks and bounded auditing.
