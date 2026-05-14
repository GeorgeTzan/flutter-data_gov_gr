# data_gov_gr

[![Pub Version](https://img.shields.io/pub/v/data_gov_gr?logo=dart)](https://pub.dev/packages/data_gov_gr)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

An unofficial, type-safe, and modular Dart SDK for the Greek Government Open Data API ([data.gov.gr](https://data.gov.gr)).

## Features

- **Full Coverage**: Access to **all 200+ datasets** via type-safe modules or the universal generic service.
- **Unified Authentication**: Simple API Token management.
- **Type-Safe Models**: Built with [Freezed](https://pub.dev/packages/freezed).
- **Fluent Query DSL**: Chainable filtering for popular datasets.
- **Reactive Rate Limiting**: Real-time status stream of your API usage.
- **Built-in Mocking**: Test your apps offline with `DataGovMockClient`.
- **Discovery**: Programmatically list and search datasets, topics, and providers.
- **Robust Networking**: Automatic retries, logging, and error mapping.

## Getting Started

### 1. Add dependency

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  data_gov_gr: ^1.0.0
```

### 2. Initialize the client

```dart
import 'package:data_gov_gr/data_gov_gr.dart';

final client = DataGovClient(apiKey: 'YOUR_API_TOKEN');
```

### 3. Usage Examples

#### Fetch Type-Safe Vaccination Data
```dart
final stats = await client.health.getVaccinationStatistics(
  from: DateTime(2023, 1, 1),
  area: 'ΑΘΗΝΩΝ',
);
```

#### Use the Query DSL for Fuel Prices
```dart
final stations = await client.fuel.query()
    .wherePrefecture(Prefecture.attica)
    .fetch();
```

#### Generic Access to Any Dataset
```dart
final results = await client.generic.query('mcp_forest_fires');
```

#### Discover New Datasets
```dart
final datasets = await client.discovery.listDatasets();
```

## Supported Type-Safe Modules

- [x] **Fuel**: `gas_price_per_station`
- [x] **Health**: `mdg_emvolio` (Vaccinations)
- [x] **Telecom**: `internet_traffic` (GR-IX)
- [x] **Environment**: `mcp_forest_fires`
- [x] **Discovery**: Metadata, Topics, Providers
- [x] **Generic**: Universal access to all endpoints

## License

MIT License - see LICENSE for details.
