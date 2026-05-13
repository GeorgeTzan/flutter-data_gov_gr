# data_gov_gr

[![Pub Version](https://img.shields.io/pub/v/data_gov_gr?logo=dart)](https://pub.dev/packages/data_gov_gr)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

An unofficial, type-safe, and modular Dart SDK for the Greek Government Open Data API ([data.gov.gr](https://data.gov.gr)).

## Features

- **Unified Authentication**: Simple API Token management.
- **Type-Safe Models**: Built with [Freezed](https://pub.dev/packages/freezed) and [JsonSerializable](https://pub.dev/packages/json_serializable).
- **Fluent Query DSL**: Chainable filtering for better readability.
- **Reactive Rate Limiting**: Real-time status stream of your API usage.
- **Built-in Mocking**: Test your apps offline with `DataGovMockClient`.
- **Localization**: Native support for Greek and English names for categories (Prefectures, Fuel Types).
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

### 3. Fetch Data

#### Using Query DSL (Recommended)
```dart
final stations = await client.fuel
    .query()
    .wherePrefecture(Prefecture.attica)
    .whereFuelType(FuelType.unleaded95)
    .fetch();
```

#### Monitoring Rate Limits
```dart
client.rateLimitStatus.listen((status) {
  print('Remaining requests: ${status.remaining}/${status.limit}');
});
```

## Testing

Use the built-in mock client for your unit and UI tests:

```dart
final mockClient = DataGovMockClient();
// Returns realistic mock data instantly without hitting the API
final stations = await mockClient.fuel.query().fetch();
```

## Supported Datasets

- [x] **Liquid Fuel Prices**: `gas_price_per_station`
- [ ] More coming soon...

## License

This project is licensed under the MIT License - see the LICENSE file for details.
