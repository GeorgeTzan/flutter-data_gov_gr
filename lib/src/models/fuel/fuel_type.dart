import 'package:json_annotation/json_annotation.dart';

/// Represents the various types of fuel available in Greece.
enum FuelType {
  /// Standard unleaded 95 octane gasoline.
  unleaded95('Αμόλυβδη 95'),

  /// Premium unleaded 100 octane gasoline.
  unleaded100('Αμόλυβδη 100'),

  /// Super unleaded/leaded gasoline.
  superUnleaded('Super'),

  /// Standard automotive diesel.
  diesel('Πετρέλαιο Κίνησης'),

  /// Premium automotive diesel.
  dieselPremium('Πετρέλαιο Κίνησης Ενισχυμένο'),

  /// Liquefied Petroleum Gas for automotive use.
  lpg('Υγραέριο Κίνησης (LPG)'),

  /// Compressed Natural Gas for automotive use.
  cng('Φυσικό Αέριο Κίνησης (CNG)'),

  /// Heating diesel for home deliveries.
  heatingDiesel('Πετρέλαιο Θέρμανσης Κατ\'οίκον'),

  /// Unknown fuel type fallback.
  unknown('Unknown');

  /// The raw Greek label/name as used in the API.
  final String rawGreekLabel;

  /// Creates a new [FuelType] instance.
  const FuelType(this.rawGreekLabel);
}

/// Extension methods for [FuelType].
extension FuelTypeX on FuelType {
  /// Returns the Greek label/name of the fuel type.
  String get greekName => rawGreekLabel;

  /// Returns the English name of the fuel type.
  String get englishName {
    switch (this) {
      case FuelType.unleaded95:
        return 'Unleaded 95';
      case FuelType.unleaded100:
        return 'Unleaded 100';
      case FuelType.superUnleaded:
        return 'Super';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.dieselPremium:
        return 'Premium Diesel';
      case FuelType.lpg:
        return 'LPG';
      case FuelType.cng:
        return 'CNG';
      case FuelType.heatingDiesel:
        return 'Heating Diesel';
      case FuelType.unknown:
        return 'Unknown';
    }
  }
}

/// A JSON converter for mapping fuel type labels to [FuelType] enum values.
class FuelTypeConverter implements JsonConverter<FuelType, String> {
  /// Creates a new [FuelTypeConverter] instance.
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
