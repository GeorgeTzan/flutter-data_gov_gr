class MockData {
  static const List<Map<String, dynamic>> fuelStations = [
    {
      'station_id': '1001',
      'brand': 'EKO',
      'address': 'ΛΕΩΦ. ΚΗΦΙΣΙΑΣ 100',
      'municipality': 'ΜΑΡΟΥΣΙ',
      'prefecture': 'ΑΤΤΙΚΗΣ',
      'latitude': 38.0333,
      'longitude': 23.8167,
      'fuel_type': 'Αμόλυβδη 95',
      'fuel_price': 1.899,
      'date': '2024-05-13T09:00:00Z',
    },
  ];

  static const List<Map<String, dynamic>> prefectureFuelPrices = [
    {
      'prefecture': 'ΑΤΤΙΚΗΣ',
      'fuel_type': 'Αμόλυβδη 95',
      'min_price': 1.845,
      'max_price': 2.099,
      'avg_price': 1.882,
      'date': '2024-05-13',
    }
  ];

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
