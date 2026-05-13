/// Static realistic mock data for testing the data.gov.gr SDK.
class MockData {
  /// Realistic JSON response for gas stations.
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
    {
      'station_id': '1002',
      'brand': 'SHELL',
      'address': 'ΛΕΩΦ. ΠΟΣΕΙΔΩΝΟΣ 50',
      'municipality': 'ΓΛΥΦΑΔΑ',
      'prefecture': 'ΑΤΤΙΚΗΣ',
      'latitude': 37.8667,
      'longitude': 23.7500,
      'fuel_type': 'Αμόλυβδη 100',
      'fuel_price': 2.059,
      'date': '2024-05-13T10:30:00Z',
    },
    {
      'station_id': '2001',
      'brand': 'BP',
      'address': 'ΕΓΝΑΤΙΑ 1',
      'municipality': 'ΘΕΣΣΑΛΟΝΙΚΗ',
      'prefecture': 'ΘΕΣΣΑΛΟΝΙΚΗΣ',
      'latitude': 40.6333,
      'longitude': 22.9500,
      'fuel_type': 'Πετρέλαιο Κίνησης',
      'fuel_price': 1.659,
      'date': '2024-05-13T08:15:00Z',
    },
  ];
}
