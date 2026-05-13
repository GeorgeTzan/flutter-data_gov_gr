import 'package:data_gov_gr/src/models/fuel/fuel_type.dart';
import 'package:data_gov_gr/src/models/shared/prefecture.dart';
import 'package:test/test.dart';

void main() {
  group('Prefecture', () {
    const converter = PrefectureConverter();

    test('maps raw Greek name correctly', () {
      expect(converter.fromJson('ΑΤΤΙΚΗΣ'), Prefecture.attica);
      expect(converter.fromJson('ΘΕΣΣΑΛΟΝΙΚΗΣ'), Prefecture.thessaloniki);
    });

    test('is case-insensitive during mapping', () {
      expect(converter.fromJson('αττικής'), Prefecture.attica);
    });

    test('throws ArgumentError for unknown prefecture', () {
      expect(() => converter.fromJson('NOT_A_PREFECTURE'), throwsArgumentError);
    });

    test('provides English names via extension', () {
      expect(Prefecture.attica.englishName, 'Attica');
      expect(Prefecture.achaia.englishName, 'Achaia');
    });
  });

  group('FuelType', () {
    const converter = FuelTypeConverter();

    test('maps raw Greek label correctly', () {
      expect(converter.fromJson('Αμόλυβδη 95'), FuelType.unleaded95);
      expect(converter.fromJson('Πετρέλαιο Κίνησης'), FuelType.diesel);
    });

    test('defaults to .unknown for unrecognized strings', () {
      expect(converter.fromJson('New Fuel Type'), FuelType.unknown);
    });

    test('provides localized names via extension', () {
      expect(FuelType.unleaded95.englishName, 'Unleaded 95');
      expect(FuelType.diesel.greekName, 'Πετρέλαιο Κίνησης');
    });
  });
}
