# flutter-data_gov_gr

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![pub package](https://img.shields.io/pub/v/data_gov_gr.svg)](https://pub.dev/packages/data_gov_gr)

An unofficial, type-safe, and modular Dart SDK for the Greek Government Open Data API ([data.gov.gr](https://data.gov.gr)).

## Features

- **Full Coverage**: Access to **all 200+ datasets** via type-safe modules or the universal generic service.
- **Unified Authentication**: Simple API Token management.
- **Type-Safe Models**: Built with [Freezed](https://pub.dev/packages/freezed) for robust data handling.
- **Fluent Query DSL**: Chainable filtering for fuel prices and more.
- **Reactive Rate Limiting**: Real-time status stream of your API usage.
- **Built-in Mocking**: Test your apps offline with `DataGovMockClient` and realistic stubs.
- **Discovery**: Programmatically list and search datasets, topics, and providers.
- **Robust Networking**: Automatic retries, logging, and error mapping.

## Getting Started

### 1. Add dependency

Add `data_gov_gr` to your project using the command line:

```bash
dart pub add data_gov_gr
```

Or add it directly to your `pubspec.yaml` dependencies:

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

#### Fetch Procurement Data (KIMDIS)
```dart
final decisions = await client.procurement.getKimdisDecisions(
  organizationId: '99200827',
);
```

#### Generic Access to Any Dataset
```dart
final results = await client.generic.query('mcp_forest_fires');
```

## Testing & Verification

### Unit & Mock Tests
Run the standard test suite:
```bash
dart test
```

### Integration Tests (Live API)
To verify the SDK against the real Greek government servers, provide your API token as an environment variable:
```bash
DATA_GOV_GR_TOKEN=your_token_here dart test test/integration_test.dart
```

### Flutter Example App
Explore the interactive dashboard:
```bash
cd example
# For Web (handles CORS)
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## Supported Type-Safe Modules

- [x] **Fuel**: Detailed Station Prices & Prefecture Min/Max
- [x] **Health**: COVID-19 Vaccinations & Ministry Statistics
- [x] **Procurement**: KIMDIS Decisions (`khmdhs_decisions`)
- [x] **Telecom**: GR-IX Internet Traffic
- [x] **Environment**: Forest Fire Statistics
- [x] **Business & Economy**: Debt, Budget, and Revenue Data
- [x] **Crime & Justice**: Road Accident Statistics
- [x] **Education**: University & Training Data
- [x] **Society**: Employment & Labor Market Metrics
- [x] **Technology**: Digital Adoption & Internet Usage
- [x] **Transport**: Public Transport & Airport Traffic
- [x] **Discovery**: Datasets, Topics, Providers
- [x] **Generic**: Universal access to all endpoints with auto-pagination

## Related Projects

- **Python**: [pydatagovgr](https://github.com/ilias-ant/pydatagovgr)
- **Go**: [go-data-gov-gr-sdk](https://github.com/ppapapetrou76/go-data-gov-gr-sdk)
- **R**: [datagovgR](https://github.com/elenigvasilaki/datagovgR)

## API Compatibility & Architecture

```mermaid
graph TD
    App[User's Application] --> Client[DataGovClient]
    
    subgraph SDK Client Architecture
        Client --> Services[Type-Safe Services]
        Client --> Generic[GenericService]
        Client --> Interceptors[Interceptors Pipeline]
        
        Services --> Fuel[FuelService / Query DSL]
        Services --> Health[HealthService]
        Services --> Telecom[TelecomService]
        Services --> Others[Other Services...]
        
        Interceptors --> Ckan[CkanCompatibilityInterceptor]
        Interceptors --> Error[ErrorInterceptor]
        Interceptors --> RateLimit[RateLimitInterceptor]
        Interceptors --> Retry[RetryInterceptor]
    end
    
    Interceptors --> Dio[Dio Network Client]
    Dio --> API[data.gov.gr CKAN API v3]
```

The SDK targets the modern **`data.gov.gr` CKAN Action API v3** (`https://data.gov.gr/api/3/action/`).

To prevent breaking existing applications, a built-in `CkanCompatibilityInterceptor` automatically intercepts legacy REST-style endpoints (e.g., vaccine, fuel, and traffic paths) and translates them on-the-fly into CKAN action queries (like `datastore_search`). This ensures 100% backward compatibility for all API methods.

## License

MIT License - see [LICENSE](LICENSE) for details.
