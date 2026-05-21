/// An unofficial, type-safe, and modular Dart SDK for the Greek Government Open Data API (data.gov.gr).
library data_gov_gr;

export 'src/client/data_gov_client.dart';
export 'src/client/data_gov_mock_client.dart';
export 'src/exceptions/data_gov_exception.dart';

// Models
export 'src/models/shared/prefecture.dart';
export 'src/models/shared/rate_limit_status.dart';
export 'src/models/fuel/fuel_station.dart';
export 'src/models/fuel/fuel_type.dart';
export 'src/models/fuel/prefecture_fuel_price.dart';
export 'src/models/health/vaccination_data.dart';
export 'src/models/telecom/internet_traffic.dart';
export 'src/models/environment/forest_fire.dart';
export 'src/models/discovery/dataset_metadata.dart';
export 'src/models/procurement/procurement_decision.dart';

// Services
export 'src/services/fuel_service.dart';
export 'src/services/fuel_query_builder.dart';
export 'src/services/health_service.dart';
export 'src/services/telecom_service.dart';
export 'src/services/environment_service.dart';
export 'src/services/discovery_service.dart';
export 'src/services/generic_service.dart';
export 'src/services/procurement_service.dart';
export 'src/services/business_service.dart';
export 'src/services/justice_service.dart';
export 'src/services/education_service.dart';
export 'src/services/society_service.dart';
export 'src/services/technology_service.dart';
export 'src/services/transport_service.dart';

// Utils
export 'src/utils/mock_data.dart';
export 'src/utils/transliteration.dart';
