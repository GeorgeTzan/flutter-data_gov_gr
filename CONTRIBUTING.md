# Contributing to data_gov_gr

Production data must come from the selected resource, missing values stay missing, and upstream failures remain visible. Read [README.md](README.md) and [SUPPORT.md](SUPPORT.md) before changing a public API.

## Setup

```bash
git clone https://github.com/GeorgeTzan/flutter-data_gov_gr.git
cd flutter-data_gov_gr
dart pub get
```

The SDK targets Dart 3.8 and current stable Dart. The Flutter example has a separate Dart 3.11 constraint; use a compatible Flutter SDK and run `flutter pub get` from `example/`.

The production library is pure Dart. Applications own file storage and proxy deployment. Keep fixtures/scripted adapters behind `package:data_gov_gr/testing.dart`; never return demo data for a failing production request.

## Changes and tests

Document public contracts with Dart docstrings, including source semantics, cancellation, bounds, and ownership. Keep ordinary inline comments sparse and reserve them for reasoning the code cannot express. Update the README, support table, and changelog when a public contract changes.

Add focused tests for meaningful behavior using deterministic fixtures and scripted responses. Cover source errors, pagination boundaries, cancellation, malformed inputs, and schema differences where relevant. Retain raw values and unmapped columns. Do not invent units, dates, identities, or missing quantities.

Run SDK checks from the repository root:

```bash
dart format --output=none --set-exit-if-changed lib test bin
dart analyze --fatal-infos --fatal-warnings
dart test --exclude-tags live
dart test --platform chrome test/v2/browser_transport_test.dart
```

Chrome must be available for the browser check. Verify dependency resolution, generation, analysis, and offline SDK tests with both Dart 3.8 and current stable before claiming minimum-version compatibility.

For generated model changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Check declarations/generated files agree and no removed model leaves stale parts. For release verification, record content hashes for all generated files, generate twice, and compare the results, including new files. A clean Git tree alone does not prove reproducibility.

Run the Flutter example checks from `example/`:

```bash
flutter test
flutter analyze
flutter build web
```

Validate browser behavior with the application's proxy and resource routing. A web build does not prove publisher CORS support.

## Opt-in live checks

Live checks are tagged `live` and require an explicit flag:

```bash
DATA_GOV_GR_LIVE=1 dart test test/live --tags live
```

Public reads need no token. Record actual source failures/outages; live checks must never fall back to fixtures. Keep checks small and bounded. Normal CI excludes live tests; the separate live workflow provides manual/scheduled checks.

A bounded catalog audit records observed entries/resources and completeness separately from parser/download success:

```bash
dart run bin/coverage_audit.dart --max-entries 500 --output /tmp/data-gov-coverage.json
```

Use `--full` only when full traversal is intended. A capped audit is incomplete and cannot establish full coverage. Do not download all publisher files automatically.

## Pull requests and release verification

Describe the concrete problem, resulting behavior, and validation performed. Keep changes focused and include source evidence for new provider mappings or units. External service clients need separate adapters/designs rather than guessed CKAN routes.

Before release, compile README/support examples against public imports, run `dart doc`, `dart pub publish --dry-run`, and `git diff --check`, and review packaging, generated files, removed exports, source boundaries, and live outcomes. A dry run does not publish a package. Report unavailable checks honestly.

