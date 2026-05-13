import 'package:json_annotation/json_annotation.dart';

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

  final String rawGreekLabel;
  const FuelType(this.rawGreekLabel);
}

extension FuelTypeX on FuelType {
  String get greekName => rawGreekLabel;

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
