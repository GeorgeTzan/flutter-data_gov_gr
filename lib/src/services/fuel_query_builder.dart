import '../models/fuel/fuel_station.dart';
import '../models/fuel/fuel_type.dart';
import '../models/shared/prefecture.dart';
import 'fuel_service.dart';

class FuelQueryBuilder {
  final FuelService _service;

  DateTime? _date;
  Prefecture? _prefecture;
  FuelType? _fuelType;

  FuelQueryBuilder(this._service);

  FuelQueryBuilder atDate(DateTime date) {
    _date = date;
    return this;
  }

  FuelQueryBuilder wherePrefecture(Prefecture prefecture) {
    _prefecture = prefecture;
    return this;
  }

  FuelQueryBuilder whereFuelType(FuelType fuelType) {
    _fuelType = fuelType;
    return this;
  }

  Future<List<FuelStation>> fetch() {
    return _service.getGasPricesPerStation(
      date: _date,
      prefecture: _prefecture,
      fuelType: _fuelType,
    );
  }
}
