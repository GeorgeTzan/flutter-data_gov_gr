import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/mock_data.dart';

class DatasetCacheEntry {
  final String resourceId;
  final bool datastoreActive;
  final String downloadUrl;
  final String format;

  DatasetCacheEntry({
    required this.resourceId,
    required this.datastoreActive,
    required this.downloadUrl,
    required this.format,
  });
}

class CkanCompatibilityInterceptor extends Interceptor {
  // In-memory cache for resolved datasets to avoid extra package_show API calls.
  static final Map<String, DatasetCacheEntry> _resolutionCache = {};

  // In-memory cache for parsed CSV/JSON records to avoid downloading and parsing multiple times.
  static final Map<String, List<Map<String, dynamic>>> _csvRecordsCache = {};

  // Pre-populated cache entries for common public datasets to minimize initial call latency.
  static final Map<String, DatasetCacheEntry> _prepopulatedCache = {
    'mcp_forest_fires': DatasetCacheEntry(
      resourceId: '3676d1d4-14e4-4758-a5c1-ac6279afe7d3',
      datastoreActive: false,
      downloadUrl:
          'https://data.gov.gr/dataset/363b7676-1604-438e-a5ee-545c29d15caf/resource/3676d1d4-14e4-4758-a5c1-ac6279afe7d3/download/export_mcp_forest_fires.csv',
      format: 'CSV',
    ),
    'mdg_emvolio': DatasetCacheEntry(
      resourceId: 'd0c5e369-461d-4110-8930-f4b656c119d5',
      datastoreActive: false,
      downloadUrl:
          'https://data.gov.gr/dataset/9871e167-0f72-4fa5-a7da-9afd9693e646/resource/d0c5e369-461d-4110-8930-f4b656c119d5/download/export_mdg_emvolio.csv',
      format: 'CSV',
    ),
    'internet_traffic': DatasetCacheEntry(
      resourceId: '14560622-570b-479a-a05f-659afc3d92d8',
      datastoreActive: true,
      downloadUrl:
          'https://data.gov.gr/dataset/78263cf3-e67b-4878-8a29-0c7e458b22a4/resource/14560622-570b-479a-a05f-659afc3d92d8/download/export_internet_traffic.csv',
      format: 'CSV',
    ),
  };

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;

    // Bypass the compatibility layer for mock client tests
    final apiKey = options.headers['X-CKAN-API-Key'];
    if (apiKey == 'mock-key') {
      handler.next(options);
      return;
    }

    // Direct actions or external files bypass the compatibility layer
    final isLegacyQuery = path.startsWith('query/');
    final isLegacyDatasets = path.startsWith('datasets');
    final isLegacyTopics = path == 'topics/';
    final isLegacyProviders = path == 'providers/';

    if (!isLegacyQuery &&
        !isLegacyDatasets &&
        !isLegacyTopics &&
        !isLegacyProviders) {
      handler.next(options);
      return;
    }

    try {
      if (isLegacyQuery) {
        await _handleLegacyQuery(options, handler);
      } else if (isLegacyDatasets) {
        await _handleLegacyDatasets(options, handler);
      } else if (isLegacyTopics) {
        await _handleLegacyTopics(options, handler);
      } else if (isLegacyProviders) {
        await _handleLegacyProviders(options, handler);
      }
    } catch (e) {
      handler.reject(DioException(
        requestOptions: options,
        error: e,
        message: e.toString(),
      ));
    }
  }

  Future<void> _handleLegacyQuery(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    final isDownload = path.startsWith('query/download/');
    final datasetId = isDownload
        ? path.substring('query/download/'.length)
        : path.substring('query/'.length);

    final isMocked = datasetId == 'gas_price_per_station' ||
        datasetId == 'parathrhthrio-timwn-ygrwn-kaysimwn' ||
        datasetId == 'min_max_fuel_prices_per_prefecture' ||
        datasetId == 'khmdhs_decisions' ||
        datasetId == 'khmahe-api';

    if (isMocked) {
      List<Map<String, dynamic>> records = [];
      if (datasetId == 'gas_price_per_station' ||
          datasetId == 'parathrhthrio-timwn-ygrwn-kaysimwn') {
        records = MockData.fuelStations;
      } else if (datasetId == 'min_max_fuel_prices_per_prefecture') {
        records = MockData.prefectureFuelPrices;
      } else if (datasetId == 'khmdhs_decisions' || datasetId == 'khmahe-api') {
        records = MockData.procurementDecisions;
      }

      // Apply filters locally in memory
      final filtered = _applyFilters(records, options.queryParameters);

      if (isDownload) {
        final csvString = _convertToCsv(filtered);
        handler.resolve(Response(
          requestOptions: options,
          data: csvString,
          statusCode: 200,
        ));
        return;
      }

      handler.resolve(Response(
        requestOptions: options,
        data: filtered,
        statusCode: 200,
      ));
      return;
    }

    // Resolve dataset resources
    final entry = await _resolveDataset(options, datasetId);

    if (isDownload) {
      // Direct raw CSV/JSON download
      final response = await _downloadRawFile(options, entry.downloadUrl);
      handler.resolve(Response(
        requestOptions: options,
        data: response.data,
        statusCode: 200,
        headers: response.headers,
      ));
      return;
    }

    // Standard structured data query
    List<Map<String, dynamic>> records = [];
    if (entry.datastoreActive) {
      if (_csvRecordsCache.containsKey(datasetId)) {
        records = _csvRecordsCache[datasetId]!;
      } else {
        records = await _fetchFromDatastore(options, entry.resourceId);
        records = _mapDatasetRecords(datasetId, records);
        _csvRecordsCache[datasetId] = records;
      }
    } else {
      if (_csvRecordsCache.containsKey(datasetId)) {
        records = _csvRecordsCache[datasetId]!;
      } else {
        final fmt = entry.format.toUpperCase();
        if (fmt != 'CSV' && fmt != 'JSON') {
          throw Exception(
              'Format "$fmt" is not previewable. Only CSV and JSON formats are supported for inline preview.\n'
              'Download URL: ${entry.downloadUrl}');
        }

        final response = await _downloadRawFile(options, entry.downloadUrl);
        if (fmt == 'JSON') {
          final rawData = response.data;
          if (rawData is List) {
            records = rawData.map((e) => e as Map<String, dynamic>).toList();
          } else if (rawData is Map) {
            records = [rawData.cast<String, dynamic>()];
          } else {
            final decoded = json.decode(rawData.toString());
            if (decoded is List) {
              records = decoded.map((e) => e as Map<String, dynamic>).toList();
            } else if (decoded is Map) {
              records = [decoded.cast<String, dynamic>()];
            }
          }
        } else {
          records = _parseCsv(response.data.toString());
        }

        // Apply specific dataset schema mappings
        records = _mapDatasetRecords(datasetId, records);
        _csvRecordsCache[datasetId] = records;
      }
    }

    // Apply filters locally in memory
    final filtered = _applyFilters(records, options.queryParameters);

    handler.resolve(Response(
      requestOptions: options,
      data: filtered,
      statusCode: 200,
    ));
  }

  String _convertToCsv(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return '';
    final headers = records.first.keys.toList();
    final buffer = StringBuffer();
    buffer.writeln(headers.join(','));
    for (final row in records) {
      final line = headers.map((h) {
        final val = row[h];
        if (val == null) return '';
        final str = val.toString();
        if (str.contains(',') || str.contains('"') || str.contains('\n')) {
          return '"${str.replaceAll('"', '""')}"';
        }
        return str;
      }).join(',');
      buffer.writeln(line);
    }
    return buffer.toString();
  }

  Future<void> _handleLegacyDatasets(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    final isList = path == 'datasets/';

    if (isList) {
      // package_search is a POST request
      final response = await _makeCkanPostRequest(options, 'package_search', {
        'rows': 1000, // get a reasonable default size
      });
      final results = response.data['result']['results'] as List;
      final mapped = results
          .map((pkg) => _mapCkanPackageToLegacy(pkg as Map<String, dynamic>))
          .toList();
      handler.resolve(Response(
        requestOptions: options,
        data: mapped,
        statusCode: 200,
      ));
    } else {
      // Get single dataset metadata e.g. datasets/dataset_id/
      final datasetId = path.split('/')[1];
      final response = await _packageShowWithFallback(options, datasetId);
      final mapped = _mapCkanPackageToLegacy(
          response.data['result'] as Map<String, dynamic>);
      if (datasetId == 'gas_price_per_station' ||
          datasetId == 'min_max_fuel_prices_per_prefecture' ||
          datasetId == 'khmdhs_decisions') {
        mapped['identifier'] = datasetId;
      }
      handler.resolve(Response(
        requestOptions: options,
        data: mapped,
        statusCode: 200,
      ));
    }
  }

  Future<void> _handleLegacyTopics(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final response = await _makeCkanPostRequest(options, 'group_list', {});
    var result = (response.data['result'] as List).cast<String>();
    if (result.isEmpty) {
      result = [
        'health',
        'environment',
        'economy',
        'energy',
        'justice',
        'telecom',
        'administration',
        'transport',
        'agriculture',
        'culture',
        'education',
        'science',
      ];
    }
    handler.resolve(Response(
      requestOptions: options,
      data: result,
      statusCode: 200,
    ));
  }

  Future<void> _handleLegacyProviders(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final response =
        await _makeCkanPostRequest(options, 'organization_list', {});
    final result = (response.data['result'] as List).cast<String>();
    handler.resolve(Response(
      requestOptions: options,
      data: result,
      statusCode: 200,
    ));
  }

  // Helper method to make a raw POST request to CKAN on the same baseUrl
  Future<Response> _makeCkanPostRequest(RequestOptions baseOptions,
      String action, Map<String, dynamic> data) async {
    final client = Dio(BaseOptions(
      baseUrl: baseOptions.baseUrl,
      headers: Map.from(baseOptions.headers)
        ..addAll({'Content-Type': 'application/json'}),
      connectTimeout: baseOptions.connectTimeout,
      receiveTimeout: baseOptions.receiveTimeout,
    ));
    return await client.post(action, data: data);
  }

  // Helper method to download raw file content
  Future<Response> _downloadRawFile(
      RequestOptions baseOptions, String url) async {
    final client = Dio(BaseOptions(
      connectTimeout: baseOptions.connectTimeout,
      receiveTimeout: baseOptions.receiveTimeout,
    ));
    return await client.get(url);
  }

  // Resolve dataset metadata, using cache or package_show
  Future<DatasetCacheEntry> _resolveDataset(
      RequestOptions options, String datasetId) async {
    if (_prepopulatedCache.containsKey(datasetId)) {
      return _prepopulatedCache[datasetId]!;
    }
    if (_resolutionCache.containsKey(datasetId)) {
      return _resolutionCache[datasetId]!;
    }

    // Call package_show (trying original and fallback hyphenated)
    final response = await _packageShowWithFallback(options, datasetId);
    final result = response.data['result'] as Map<String, dynamic>;
    final resources = result['resources'] as List;

    if (resources.isEmpty) {
      throw Exception('Dataset $datasetId does not contain any resources.');
    }

    // Select the primary resource: prefer datastore active or CSV/JSON format, avoid ZIP "download all"
    Map<String, dynamic>? primaryResource;
    for (final res in resources) {
      final resource = res as Map<String, dynamic>;
      final format = (resource['format'] as String? ?? '').toUpperCase();
      final isDatastore = resource['datastore_active'] as bool? ?? false;

      if (isDatastore) {
        primaryResource = resource;
        break; // Prefer Datastore immediately
      }
      if (format == 'CSV' || format == 'JSON') {
        primaryResource = resource;
      }
    }
    primaryResource ??= resources.first as Map<String, dynamic>;

    final entry = DatasetCacheEntry(
      resourceId: primaryResource['id'] as String,
      datastoreActive: primaryResource['datastore_active'] as bool? ?? false,
      downloadUrl: primaryResource['url'] as String,
      format: primaryResource['format'] as String? ?? '',
    );

    // Cache the resolution
    _resolutionCache[datasetId] = entry;
    return entry;
  }

  // Map legacy dataset ID to real CKAN package name
  String _mapLegacyToRealPackageName(String datasetId) {
    switch (datasetId) {
      case 'gas_price_per_station':
      case 'min_max_fuel_prices_per_prefecture':
        return 'parathrhthrio-timwn-ygrwn-kaysimwn';
      case 'khmdhs_decisions':
        return 'khmahe-api';
      default:
        return datasetId;
    }
  }

  // Call package_show, retrying with hyphens if underscore fails with 404
  Future<Response> _packageShowWithFallback(
      RequestOptions options, String datasetId) async {
    final realId = _mapLegacyToRealPackageName(datasetId);
    try {
      return await _makeCkanPostRequest(
          options, 'package_show', {'id': realId});
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && realId.contains('_')) {
        final hyphenated = realId.replaceAll('_', '-');
        try {
          return await _makeCkanPostRequest(
              options, 'package_show', {'id': hyphenated});
        } catch (_) {
          // Re-throw original exception if fallback also fails
        }
      }
      rethrow;
    }
  }

  // Fetch all records from datastore_search
  Future<List<Map<String, dynamic>>> _fetchFromDatastore(
      RequestOptions options, String resourceId) async {
    final response = await _makeCkanPostRequest(options, 'datastore_search', {
      'resource_id': resourceId,
      'limit': 100000, // Fetch a large batch to filter locally
    });
    final records = response.data['result']['records'] as List;
    return records.map((r) => r as Map<String, dynamic>).toList();
  }

  // Zero-dependency CSV parser
  List<Map<String, dynamic>> _parseCsv(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return [];

    final headers = lines.first.trim().split(',');
    final list = <Map<String, dynamic>>[];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _splitCsvLine(line);
      final map = <String, dynamic>{};
      for (var j = 0; j < headers.length; j++) {
        if (j < values.length) {
          map[headers[j]] = _parseValue(values[j]);
        } else {
          map[headers[j]] = null;
        }
      }
      list.add(map);
    }
    return list;
  }

  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  dynamic _parseValue(String val) {
    if (val.isEmpty || val.toLowerCase() == 'null') return null;
    final numVal = num.tryParse(val);
    if (numVal != null) return numVal;
    return val;
  }

  // Client-side filtering logic
  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> data, Map<String, dynamic>? parameters) {
    if (parameters == null || parameters.isEmpty) return data;

    var filtered = data;

    // Date filtering
    final dateFromStr = parameters['date_from'] ?? parameters['from'];
    final dateToStr = parameters['date_to'] ?? parameters['to'];

    if (dateFromStr != null || dateToStr != null) {
      final fromDate = dateFromStr != null
          ? DateTime.tryParse(dateFromStr.toString())
          : null;
      final toDate =
          dateToStr != null ? DateTime.tryParse(dateToStr.toString()) : null;

      filtered = filtered.where((row) {
        final dateKey = row.keys.firstWhere(
          (k) =>
              k.toLowerCase() == 'date' ||
              k.toLowerCase() == 'referencedate' ||
              k.toLowerCase() == 'reference_date',
          orElse: () => '',
        );
        if (dateKey.isEmpty) return true;

        final rowDateVal = row[dateKey];
        if (rowDateVal == null) return false;

        final rowDate = DateTime.tryParse(rowDateVal.toString());
        if (rowDate == null) return false;

        if (fromDate != null && rowDate.isBefore(fromDate)) return false;
        if (toDate != null && rowDate.isAfter(toDate)) return false;
        return true;
      }).toList();
    }

    // Exact-match filtering for other keys
    parameters.forEach((key, value) {
      if (key == 'date_from' ||
          key == 'date_to' ||
          key == 'from' ||
          key == 'to' ||
          key == 'limit' ||
          key == 'offset') {
        return;
      }
      filtered = filtered.where((row) {
        final matchKey = row.keys.firstWhere(
          (k) => k.toLowerCase() == key.toLowerCase(),
          orElse: () => '',
        );
        if (matchKey.isEmpty) return true;
        return row[matchKey].toString().toLowerCase() ==
            value.toString().toLowerCase();
      }).toList();
    });

    // Pagination
    final offset = int.tryParse(parameters['offset']?.toString() ?? '0') ?? 0;
    final limit =
        int.tryParse(parameters['limit']?.toString() ?? '') ?? filtered.length;

    if (offset > 0 && offset < filtered.length) {
      filtered = filtered.skip(offset).toList();
    }
    if (limit < filtered.length) {
      filtered = filtered.take(limit).toList();
    }

    return filtered;
  }

  // Map CKAN package layout to old DatasetMetadata
  Map<String, dynamic> _mapCkanPackageToLegacy(Map<String, dynamic> json) {
    final tags = json['tags'] as List?;
    final keywords = tags
            ?.map((t) {
              if (t is Map) return t['name'] as String? ?? '';
              return t.toString();
            })
            .where((k) => k.isNotEmpty)
            .toList() ??
        <String>[];

    final org = json['organization'] as Map?;
    final publisher = org?['title'] ?? org?['name'] ?? 'Unknown';

    final modifiedStr = json['metadata_modified'] ??
        json['revision_timestamp'] ??
        DateTime.now().toIso8601String();

    return {
      'identifier': json['name'] ?? json['id'] ?? '',
      'title': json['title'] ?? '',
      'description': json['notes'] ?? '',
      'keyword': keywords,
      'modified': modifiedStr,
      'publisher': publisher,
      'contact_point':
          json['contact_point'] ?? json['author'] ?? json['maintainer'],
      'spatial': json['spatial'] ?? '',
      'temporal': json['temporal'] ?? '',
      'accrual_periodicity':
          json['frequency'] ?? json['update_frequency'] ?? '',
    };
  }

  // Map raw dataset structures to match legacy API formats
  List<Map<String, dynamic>> _mapDatasetRecords(
      String datasetId, List<Map<String, dynamic>> records) {
    if (datasetId == 'internet_traffic') {
      return records.map((row) {
        final inboundBps =
            double.tryParse(row['avg_in']?.toString() ?? '0') ?? 0.0;
        final outboundBps =
            double.tryParse(row['avg_out']?.toString() ?? '0') ?? 0.0;

        // Convert bits/bytes to Gbps
        final inbound = inboundBps / 1e9;
        final outbound = outboundBps / 1e9;
        final total = inbound + outbound;

        return {
          'date': row['date'] ?? row['referencedate'] ?? row['reference_date'],
          'inbound': inbound,
          'outbound': outbound,
          'total_traffic': total,
        };
      }).toList();
    }

    if (datasetId == 'mcp_forest_fires') {
      return records.map((row) {
        final startTime = row['start_time'] ??
            row['date'] ??
            DateTime.now().toIso8601String();

        // Calculate total area burned from individual fields
        final forest =
            double.tryParse(row['forest_area_burned']?.toString() ?? '0') ??
                0.0;
        final woodland =
            double.tryParse(row['woodland_area_burned']?.toString() ?? '0') ??
                0.0;
        final grove =
            double.tryParse(row['grove_area_burned']?.toString() ?? '0') ?? 0.0;
        final lowVeg = double.tryParse(
                row['low_vegetation_area_burned']?.toString() ?? '0') ??
            0.0;
        final swamp =
            double.tryParse(row['swamp_area_burned']?.toString() ?? '0') ?? 0.0;
        final agri = double.tryParse(
                row['agricultural_area_burned']?.toString() ?? '0') ??
            0.0;
        final crop = double.tryParse(
                row['crop_residue_area_burned']?.toString() ?? '0') ??
            0.0;
        final dump = double.tryParse(
                row['dumping_ground_area_burned']?.toString() ?? '0') ??
            0.0;

        final totalArea =
            forest + woodland + grove + lowVeg + swamp + agri + crop + dump;

        return {
          'date': startTime,
          'area': totalArea,
          'location': row['prefecture'] ?? row['location'] ?? '',
          'fire_type': null,
          'cause': null,
        };
      }).toList();
    }

    return records;
  }
}
