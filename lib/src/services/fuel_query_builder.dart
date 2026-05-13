import '../models/fuel/fuel_station.dart';
import '../models/fuel/fuel_type.dart';
import '../models/shared/prefecture.dart';
import 'fuel_service.dart';

/// A fluent builder for creating and executing fuel data queries.
class FuelQueryBuilder {
  final FuelService _service;
  
  DateTime? _date;
  Prefecture? _prefecture;
  FuelType? _fuelType;

  FuelQueryBuilder(this._service);

  /// Filters results for a specific [date].
  FuelQueryBuilder atDate(DateTime date) {
    _date = date;
    return this;
  }

  /// Filters results by [prefecture].
  FuelQueryBuilder wherePrefecture(Prefecture prefecture) {
    _prefecture = prefecture;
    return this;
  }

  /// Filters results by [fuelType].
  FuelQueryBuilder whereFuelType(FuelType fuelType) {
    _fuelType = fuelType;
    return this;
  }

  /// Executes the query and returns a list of [FuelStation]s.
  Future<List<FuelStation>> fetch() {
    return _service.getGasPricesPerStation(
      date: _date,
      prefecture: _prefecture,
      fuelType: _fuelType,
    );
  }
}
