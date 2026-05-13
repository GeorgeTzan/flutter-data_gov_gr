import 'package:json_annotation/json_annotation.dart';

/// Types of fuel available at Greek gas stations.
enum FuelType {
  unleaded95('Αμόλυβδη 95'),
  unleaded100('Αμόλυβδη 100'),
  superUnleaded('Super'),
  diesel('Πετρέλαιο Κίνησης'),
  dieselPremium('Πετρέλαιο Κίνησης Ενισχυμένο'),
  lpg('Υγραέριο Κίνησης (LPG)'),
  cng('Φυσικό Αέριο Κίνησης (CNG)'),
  heatingDiesel('Πετρέλαιο Θέρμανσης Κατ\'οίκον'),
  unknown('Unknown');

  /// The raw Greek label as returned by the API.
  final String rawGreekLabel;

  const FuelType(this.rawGreekLabel);
}

/// Helper extension for [FuelType] to provide localized names.
extension FuelTypeX on FuelType {
  /// Returns the label in Greek.
  String get greekName => rawGreekLabel;

  /// Returns a pretty English name for the fuel type.
  String get englishName {
    switch (this) {
      case FuelType.unleaded95: return 'Unleaded 95';
      case FuelType.unleaded100: return 'Unleaded 100';
      case FuelType.superUnleaded: return 'Super';
      case FuelType.diesel: return 'Diesel';
      case FuelType.dieselPremium: return 'Premium Diesel';
      case FuelType.lpg: return 'LPG';
      case FuelType.cng: return 'CNG';
      case FuelType.heatingDiesel: return 'Heating Diesel';
      case FuelType.unknown: return 'Unknown';
    }
  }
}

/// Converter to map between API strings and [FuelType] enum.
class FuelTypeConverter implements JsonConverter<FuelType, String> {
  const FuelTypeConverter();

  @override
  FuelType fromJson(String json) {
    final normalizedInput = _normalize(json);
    return FuelType.values.firstWhere(
      (e) => _normalize(e.rawGreekLabel) == normalizedInput,
      orElse: () => FuelType.unknown,
    );
  }

  @override
  String toJson(FuelType object) => object.rawGreekLabel;

  /// Removes accents and converts to uppercase for robust comparison.
  String _normalize(String input) {
    return input
        .toUpperCase()
        .replaceAll('Ά', 'Α')
        .replaceAll('Έ', 'Ε')
        .replaceAll('Ή', 'Η')
        .replaceAll('Ί', 'Ι')
        .replaceAll('Ό', 'Ο')
        .replaceAll('Ύ', 'Υ')
        .replaceAll('Ώ', 'Ω')
        .replaceAll('Ϊ', 'Ι')
        .replaceAll('Ϋ', 'Υ');
  }
}
