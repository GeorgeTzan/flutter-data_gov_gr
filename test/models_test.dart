import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:test/test.dart';

void main() {
  test(
    'catalog metadata retains unknown source fields and translated shapes',
    () {
      final source = <String, Object?>{
        'id': 'catalog-id',
        'name': 'entry-name',
        'type': 'future-kind',
        'title_translated': {'el': 'Δεδομένα'},
        'future': {
          'values': [1, '00123'],
        },
        'resources': [
          {'id': 'file', 'format': 'FUTURE', 'url': 'dummy'},
        ],
      };
      final entry = CatalogEntry.fromJson(source);
      source['id'] = 'mutated';
      expect(entry.id, 'catalog-id');
      expect(entry.name, 'entry-name');
      expect(entry.kind, 'future-kind');
      expect(entry.titleTranslated['el'], 'Δεδομένα');
      expect(entry.raw['future'], {
        'values': [1, '00123'],
      });
      expect(entry.resources.single.format, 'FUTURE');
      expect(entry.resources.single.fileUri, isNull);
      expect(entry.metadataModified, isNull);
      expect(
        () => (entry.raw['future'] as Map)['extra'] = true,
        throwsUnsupportedError,
      );
    },
  );

  test('source dates preserve malformed and unqualified published values', () {
    const malformed = SourceDate('not published as ISO');
    expect(malformed.raw, 'not published as ISO');
    expect(malformed.isParseable, isFalse);
    expect(malformed.utcValue, isNull);
    expect(const SourceDate('2024-01-01T12:00:00').utcValue, isNull);
    expect(
      const SourceDate('2024-01-01T12:00:00+02:00').utcValue,
      DateTime.utc(2024, 1, 1, 10),
    );
  });

  test('unpublished quota fields stay absent instead of becoming zero', () {
    expect(RateLimitStatus.initial().remaining, isNull);
    expect(RateLimitStatus.initial().available, isFalse);
    expect(const RateLimitStatus(remaining: 0).available, isTrue);
  });

  test(
    'resource URL roles retain source values without inventing file URLs',
    () {
      final resource = ResourceMetadata.fromJson({
        'id': 'service',
        'url': 'https://api.test/query',
        'url_type': 'api',
        'download_url': 'https://catalog.test/page',
        'last_modified': 'unparseable',
      });
      expect(resource.fileUri, isNull);
      expect(resource.url, 'https://api.test/query');
      expect(resource.downloadUrl, 'https://catalog.test/page');
      expect(resource.modified!.raw, 'unparseable');
    },
  );
}
