import '../models/location.dart';
import '../models/weather.dart';
import '../services/open_meteo_service.dart';

/// Penghubung antara ViewModel dan sumber data (API).
/// ViewModel tidak perlu tahu URL atau cara parsing JSON.
class WeatherRepository {
  final OpenMeteoService _service;

  WeatherRepository(this._service);

  Future<List<Location>> searchCity(String name) =>
      _service.searchLocations(name.trim());

  Future<WeatherData> getWeather(Location location) =>
      _service.fetchWeather(location.latitude, location.longitude);
}
