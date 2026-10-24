# Changelog

## [2.0.0] - 2026-10-24

General-purpose catalog and resource access with anonymous reads, streaming downloads, and verified source helpers.

- Replace required-token construction and mutable Dio access with anonymous `DataGovClient`, validated configuration, SDK cancellation, and idempotent `close()`.
- Replace legacy discovery/generic queries with catalog traversal, explicit resource selection, resource-specific DataStore queries, and file readers.
- Retain all entry kinds and resources, nullable metadata, unknown fields, original JSON types, and source date text.
- Add bounded byte-stream downloads, string-preserving CSV rows, bounded JSON reads, and explicit JSON row selection.
- Replace traffic, vaccination, and forest-fire helpers with verified schemas, streams, raw records, and provenance. Remove fabricated dates, zero measurements, traffic unit conversions, and unsupported fields.
- Remove unresolved business, justice, education, society, technology, and transport shortcuts, fuel/procurement fixture routing, the fuel DSL, and prefecture/transliteration utilities. Use catalog discovery or separately designed external provider adapters.
- Move fixtures to `package:data_gov_gr/testing.dart`; production has no fixture fallback.
- Use one transport policy for SDK exceptions, bounded retries/deadlines, cancellation, credential isolation, nullable quotas, and bounded metadata caching.
- Target Dart 3.8 with compatible generator dependencies. Document Flutter Web proxy and resource-host routing requirements.

## [1.0.1] - 2026-05-21

- Add API documentation to core classes, methods, and models.
- Upgrade dependencies in pubspec.yaml.
- Update repository and issue tracker URLs.

## [1.0.0] - 2026-05-21

- Initial release of the data_gov_gr Dart SDK.
