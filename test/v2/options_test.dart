import 'dart:convert';

import 'package:data_gov_gr/src/client/data_gov_config.dart';
import 'package:data_gov_gr/src/models/catalog/catalog_query.dart';
import 'package:data_gov_gr/src/models/catalog/organization.dart';
import 'package:data_gov_gr/src/models/datastore/datastore_query.dart';
import 'package:data_gov_gr/src/models/resources/csv_options.dart';
import 'package:data_gov_gr/src/models/resources/download_options.dart';
import 'package:data_gov_gr/src/models/resources/json_options.dart';
import 'package:test/test.dart';

void main() {
  test('rejects_invalid_paging_and_byte_limits', () {
    expect(CatalogQuery().pageSize, 100);
    expect(CatalogQuery().sort, 'id asc');
    expect(DataStoreQuery().limit, 100);
    for (final create in <void Function()>[
      () => CatalogQuery(offset: -1),
      () => CatalogQuery(pageSize: 0),
      () => DataStoreQuery(offset: -1),
      () => DataStoreQuery(limit: 0),
      () => OrganizationQuery(offset: -1),
      () => OrganizationQuery(pageSize: -1),
      () => DownloadOptions(maxBytes: 0),
      () => DownloadOptions(maxBytes: -1),
      () => JsonOptions(maxBytes: 0),
      () => JsonOptions(maxBytes: -1),
    ]) {
      expect(create, throwsArgumentError);
    }
    expect(DownloadOptions(maxBytes: null).maxBytes, isNull);
    expect(JsonOptions(maxBytes: null).maxBytes, isNull);
    expect(DownloadOptions().maxBytes, 67108864);
    expect(JsonOptions().maxBytes, 8388608);
  });

  test('validates_delimiters_and_positive_deadlines', () {
    for (final delimiter in ['', '::', '\n', '\r', '"']) {
      expect(() => CsvOptions(delimiter: delimiter), throwsArgumentError);
    }
    expect(CsvOptions(delimiter: ';', encoding: latin1).delimiter, ';');
    expect(CsvOptions().encoding, utf8);
    expect(() => DownloadOptions(deadline: Duration.zero), throwsArgumentError);
    expect(
      () => JsonOptions(deadline: const Duration(seconds: -1)),
      throwsArgumentError,
    );
  });

  test('validates_action_urls_and_policy_bounds', () {
    final config = DataGovConfig();
    expect(
      config.actionBaseUrl,
      Uri.parse('https://data.gov.gr/api/3/action/'),
    );
    expect(config.requestTimeout, const Duration(seconds: 30));
    expect(config.retry.maxAttempts, 3);
    expect(config.retry.deadline, const Duration(seconds: 60));
    expect(config.metadataCache.ttl, const Duration(minutes: 5));
    for (final url in [
      'relative',
      'ftp://example.org/api/',
      'https://',
      'https://user:secret@example.org/api/',
      'https://example.org/api/?secret=x',
      'https://example.org/api/#x',
      'https://example.org/api',
    ]) {
      expect(
        () => DataGovConfig(actionBaseUrl: Uri.parse(url)),
        throwsArgumentError,
      );
    }
    for (final create in <void Function()>[
      () => DataGovConfig(requestTimeout: Duration.zero),
      () => RetryPolicy(maxAttempts: 0),
      () => RetryPolicy(initialBackoff: const Duration(seconds: -1)),
      () => RetryPolicy(maxBackoff: Duration.zero),
      () => RetryPolicy(initialBackoff: const Duration(seconds: 3)),
      () => RetryPolicy(deadline: Duration.zero),
      () => MetadataCachePolicy(ttl: const Duration(seconds: -1)),
      () => MetadataCachePolicy(maxEntries: 0),
      () => MetadataCachePolicy(maxBytes: 0),
    ]) {
      expect(create, throwsArgumentError);
    }
    expect(
      RetryPolicy(initialBackoff: Duration.zero).initialBackoff,
      Duration.zero,
    );
    expect(RetryPolicy(maxAttempts: 4).maxAttempts, 4);
    expect(MetadataCachePolicy(ttl: Duration.zero).ttl, Duration.zero);
  });

  test('query_collections_are_detached_and_copy_with_retains_intent', () {
    final filters = <String, Object?>{
      'code': <Object?>['01', null],
    };
    final fields = <String>['code'];
    final sorts = <DataStoreSort>[DataStoreSort('code', descending: true)];
    final query = DataStoreQuery(
      filters: filters,
      fields: fields,
      sort: sorts,
      text: 'term',
      offset: 3,
      limit: 2,
    );
    (filters['code'] as List).clear();
    fields.clear();
    sorts.clear();
    final next = query.copyWith(offset: 5, limit: 100);
    expect(next.filters, {
      'code': ['01', null],
    });
    expect(next.fields, ['code']);
    expect(next.sort.single.field, 'code');
    expect(next.sort.single.descending, isTrue);
    expect(next.text, 'term');
    expect(next.offset, 5);
    expect(next.limit, 100);
    expect(query.offset, 3);
    expect(() => next.copyWith(limit: 0), throwsArgumentError);
    expect(() => DataStoreSort(' '), throwsArgumentError);
    final catalogFilters = ['type:dataset'];
    final facets = ['theme'];
    final catalog = CatalogQuery(filters: catalogFilters, facets: facets);
    catalogFilters.clear();
    facets.clear();
    expect(catalog.filters, ['type:dataset']);
    expect(catalog.facets, ['theme']);
    expect(() => catalog.filters.clear(), throwsUnsupportedError);
    expect(() => CatalogQuery(sort: ' '), throwsArgumentError);
  });
}
