/// Unofficial Dart SDK for Greek Government Open Data (data.gov.gr).
///
/// This SDK provides a type-safe, modular, and developer-friendly wrapper
/// around the official Greek government APIs.
library data_gov_gr;

// Core Client
export 'src/client/data_gov_client.dart';
export 'src/client/data_gov_mock_client.dart';

// Exceptions
export 'src/exceptions/data_gov_exception.dart';

// Models
export 'src/models/shared/prefecture.dart';
export 'src/models/shared/rate_limit_status.dart';
export 'src/models/fuel/fuel_station.dart';
export 'src/models/fuel/fuel_type.dart';

// Services
export 'src/services/fuel_service.dart';
export 'src/services/fuel_query_builder.dart';

// Utils
export 'src/utils/mock_data.dart';
