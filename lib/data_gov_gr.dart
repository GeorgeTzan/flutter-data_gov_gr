/// Read-only catalog, DataStore, and resource APIs for a selected CKAN source.
///
/// Version 2 uses anonymous reads by default and never supplies fixture data.
/// Deterministic test clients are available separately in `testing.dart`.
library data_gov_gr;

export 'src/client/data_gov_client.dart';
export 'src/client/data_gov_config.dart';
export 'src/core/cancellation.dart';
export 'src/core/raw_json.dart' show JsonObject;
export 'src/exceptions/data_gov_exception.dart'
    show
        DataGovException,
        AuthenticationException,
        PermissionException,
        NotFoundException,
        ValidationException,
        CkanActionException,
        NetworkException,
        RequestTimeoutException,
        RateLimitException,
        UnsupportedFormatException,
        UnsupportedResourceException,
        DecodeException,
        ByteLimitException,
        PaginationException,
        CancelledException,
        ClientClosedException;
export 'src/models/catalog/catalog_entry.dart';
export 'src/models/catalog/catalog_page.dart';
export 'src/models/catalog/catalog_query.dart';
export 'src/models/catalog/organization.dart';
export 'src/models/catalog/resource_metadata.dart';
export 'src/models/catalog/theme.dart';
export 'src/models/datastore/datastore_page.dart';
export 'src/models/datastore/datastore_query.dart';
export 'src/models/resources/csv_options.dart';
export 'src/models/resources/download_options.dart';
export 'src/models/resources/json_options.dart';
export 'src/models/resources/resource_download.dart';
export 'src/models/shared/rate_limit_status.dart';
export 'src/models/shared/source_date.dart';
export 'src/models/shared/source_provenance.dart';
export 'src/services/catalog_service.dart';
export 'src/services/datastore_service.dart';
export 'src/services/resource_service.dart';
export 'src/models/telecom/internet_traffic.dart';
export 'src/models/health/vaccination_data.dart';
export 'src/models/environment/forest_fire.dart';
export 'src/services/telecom_service.dart';
export 'src/services/health_service.dart';
export 'src/services/environment_service.dart';
