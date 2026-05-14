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
    {
      'area': 'ΘΕΣΣΑΛΟΝΙΚΗΣ',
      'areaid': 2,
      'dailydose1': 600,
      'dailydose2': 400,
      'daydiff': 20,
      'daytotal': 1000,
      'referencedate': '2024-05-13T00:00:00Z',
      'totaldose1': 200000,
      'totaldose2': 180000,
      'totalvaccinations': 380000,
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
}
