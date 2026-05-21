import '../models/shared/prefecture.dart';

class MockData {
  static final List<Map<String, dynamic>> fuelStations = _generateFuelStations();
  static final List<Map<String, dynamic>> prefectureFuelPrices = _generatePrefectureFuelPrices();

  static List<Map<String, dynamic>> _generateFuelStations() {
    final list = <Map<String, dynamic>>[];
    for (final pref in Prefecture.values) {
      final name = pref.rawGreekName;
      final code = name.hashCode.abs();
      list.addAll([
        {
          'station_id': '${(1000 + code % 1000)}_1',
          'brand': 'EKO',
          'address': 'ΚΕΝΤΡΙΚΗ ΟΔΟΣ 1',
          'municipality': 'ΧΩΡΑ',
          'prefecture': name,
          'latitude': 38.0 + (code % 100) / 100.0,
          'longitude': 23.0 + (code % 100) / 100.0,
          'fuel_type': 'Αμόλυβδη 95',
          'fuel_price': 1.85 + (code % 10) / 100.0,
          'date': '2024-05-13T09:00:00Z',
        },
        {
          'station_id': '${(1000 + code % 1000)}_2',
          'brand': 'BP',
          'address': 'ΛΕΩΦΟΡΟΣ ΔΗΜΟΚΡΑΤΙΑΣ 12',
          'municipality': 'ΚΕΝΤΡΟ',
          'prefecture': name,
          'latitude': 38.05 + (code % 100) / 100.0,
          'longitude': 23.05 + (code % 100) / 100.0,
          'fuel_type': 'Αμόλυβδη 95',
          'fuel_price': 1.88 + (code % 10) / 100.0,
          'date': '2024-05-13T09:30:00Z',
        },
        {
          'station_id': '${(1000 + code % 1000)}_3',
          'brand': 'Shell',
          'address': 'ΕΘΝΙΚΗ ΟΔΟΣ 50',
          'municipality': 'ΠΡΟΑΣΤΙΟ',
          'prefecture': name,
          'latitude': 38.1 + (code % 100) / 100.0,
          'longitude': 23.1 + (code % 100) / 100.0,
          'fuel_type': 'Αμόλυβδη 95',
          'fuel_price': 1.92 + (code % 10) / 100.0,
          'date': '2024-05-13T10:00:00Z',
        },
      ]);
    }
    return list;
  }

  static List<Map<String, dynamic>> _generatePrefectureFuelPrices() {
    final list = <Map<String, dynamic>>[];
    for (final pref in Prefecture.values) {
      final name = pref.rawGreekName;
      final code = name.hashCode.abs();
      final basePrice = 1.85 + (code % 10) / 100.0;
      list.add({
        'prefecture': name,
        'fuel_type': 'Αμόλυβδη 95',
        'min_price': basePrice,
        'max_price': basePrice + 0.15,
        'avg_price': basePrice + 0.05,
        'date': '2024-05-13',
      });
    }
    return list;
  }


  static const List<Map<String, dynamic>> vaccinations = [
    {
      'area': 'ΑΘΗΝΩΝ',
      'areaid': 1,
      'dailydose1': 1200,
      'dailydose2': 800,
      'daydiff': 50,
      'daytotal': 2000,
      'referencedate': '2024-05-13T00:00:00Z',
      'totaldose1': 500000,
      'totaldose2': 450000,
      'totalvaccinations': 950000,
    },
  ];

  static const List<Map<String, dynamic>> internetTraffic = [
    {
      'date': '2024-05-13T00:00:00Z',
      'inbound': 450.5,
      'outbound': 420.2,
      'total_traffic': 870.7,
    },
  ];

  static const List<Map<String, dynamic>> forestFires = [
    {
      'date': '2024-05-13T00:00:00Z',
      'area': 12.5,
      'location': 'ΕΥΒΟΙΑ',
      'fire_type': 'Δασική',
      'cause': 'Άγνωστη',
    },
  ];

  static const List<Map<String, dynamic>> procurementDecisions = [
    {
      'ada': '6Ψ8Ω46ΜΤΛ6-Ξ0Β',
      'adam': '23SYMV012345678',
      'subject': 'Προμήθεια ειδών γραφικής ύλης',
      'amount': 12500.50,
      'currency': 'EUR',
      'organization': 'ΔΗΜΟΣ ΑΘΗΝΑΙΩΝ',
      'organization_id': '99200827',
      'date': '2024-05-13T10:30:00Z',
      'type': 'ΣΥΜΒΑΣΗ',
      'status': 'ΟΛΟΚΛΗΡΩΜΕΝΗ',
      'url': 'https://example.com/procurement/1',
    },
  ];
}
