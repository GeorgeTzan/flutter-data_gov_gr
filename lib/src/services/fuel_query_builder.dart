import '../models/fuel/fuel_station.dart';
import '../models/fuel/fuel_type.dart';
import '../models/shared/prefecture.dart';
import 'fuel_service.dart';

/// A builder class for constructing and executing fuel price queries with filters.
class FuelQueryBuilder {
  final FuelService _service;

  DateTime? _date;
  Prefecture? _prefecture;
  FuelType? _fuelType;

  /// Creates a new [FuelQueryBuilder] instance.
  FuelQueryBuilder(this._service);

  /// Filters results by the specific [date].
  FuelQueryBuilder atDate(DateTime date) {
    _date = date;
    return this;
  }

  /// Filters results by the specific [prefecture] (region).
  FuelQueryBuilder wherePrefecture(Prefecture prefecture) {
    _prefecture = prefecture;
    return this;
  }

  /// Filters results by the specific [fuelType].
  FuelQueryBuilder whereFuelType(FuelType fuelType) {
    _fuelType = fuelType;
    return this;
  }

  /// Executes the query and fetches the list of matching [FuelStation] records.
  Future<List<FuelStation>> fetch() {
    return _service.getGasPricesPerStation(
      date: _date,
      prefecture: _prefecture,
      fuelType: _fuelType,
    );
  }
}
