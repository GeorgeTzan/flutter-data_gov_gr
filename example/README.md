# data.gov.gr Flutter example

The example opens in **Real data** mode with anonymous access. Native Flutter can read the portal directly; no token is needed for public catalog reads. It preserves published metadata and lets you choose a resource and its DataStore or file source before previewing up to 100 rows. Downloads and previews report publisher/network errors without substituting sample records.

Use Flutter compatible with Dart **3.11 or later** (the example's existing minimum). From this directory:

```sh
flutter pub get
flutter run -d linux
```

In **System**, edit the action directory URL (absolute HTTP(S), ending with `/`) and optional token, then press **Apply**. Typing only edits a draft. Apply closes the previous connection and reloads screens with the new configuration, cancelling previous work. App disposal closes the remaining connection. Configuration is held only in memory; restarting returns to anonymous real access. Quota remains **Unavailable** until the selected server publishes quota headers.

**Demo** is an explicit, visibly labeled choice using `package:data_gov_gr/testing.dart`. Its synthetic catalog/files are unrelated to provider observations; the verified monitor does not substitute fixtures. The deterministic demo supports a single run of each file/query. Apply again to restart it. Demo mode does not contact the selected action URL or send the optional token.

## Flutter Web and your backend

The audited portal does not permit browser cross-origin access. Deploy an application backend or same-origin proxy separately from this package, then enter its action directory in System, for example `https://your-app.example/ckan/api/3/action/`, and Apply. The SDK's browser transport supplies supported request headers; the app does not set forbidden browser headers.

The backend must restrict forwarding to the configured portal/action paths, handle preflight where needed, forward relevant response headers/status, and stream bodies with size and time bounds. Keep secret credentials on the server; never embed a private token in a web build or enter one into a public/shared browser. The optional token field is for a source you control and a credential you intend to expose to that running client.

Changing the action directory only routes catalog/DataStore calls. Published resource URLs still refer to publisher hosts. For each resource you intend to use, configure a resource-host allowlist on your backend and explicitly route downloads through that backend, for example by rewriting returned resource URLs to your same-origin resource route. Reject unlisted targets and redirects to unlisted hosts; do not operate an open proxy. Otherwise a resource needs its own publisher CORS support and browser access may fail. Resource metadata in the SDK remains as received from your selected source. Proxy deployment/hosting is an application responsibility.

## Previews and saving

Select a catalog result, inspect all resources and their published metadata, and select one before opening a preview. If both DataStore and a file are available, choose the source explicitly. CSV/DataStore previews cancel after 100 rows. JSON previews show at most 100 object rows after reading a document capped at 8 MiB; JSON document parsing is bounded rather than incremental. Other formats remain downloadable without claiming parser support.

Native saves stream into a file in the platform Downloads directory, falling back to application documents when Downloads is unavailable. Filenames are reduced to a safe basename; saving replaces that filename. On browsers the save uses a Blob with an explicit **16 MiB in-memory limit**, after which it fails and cancels the transfer. Browsers may need additional Blob memory. The Save button shows this limit; use a native build for larger files. Leaving a resource or changing configuration cancels its active transfer.

The monitor loads bounded samples from the verified internet traffic and vaccination helpers. It lists `mcp_forest_fires` resources and requires you to select a published file for the fire sample. Source dates, raw values and provenance are shown without invented units, missing dates, or incident identifiers. These samples are historical source observations, not current emergency or live operational reports.

```sh
flutter test
flutter analyze
flutter build web
```
