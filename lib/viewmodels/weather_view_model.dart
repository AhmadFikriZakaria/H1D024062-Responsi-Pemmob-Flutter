import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../models/weather.dart';
import '../repositories/weather_repository.dart';
import '../services/local_storage.dart';
import '../services/open_meteo_service.dart';
import 'load_status.dart';

/// ViewModel layar cuaca: menyimpan kota terpilih, data cuaca, dan status
/// loading/error. View hanya membaca state ini lewat Provider.
class WeatherViewModel extends ChangeNotifier {
  /// Kota awal saat aplikasi pertama kali dibuka (belum ada lokasi tersimpan).
  static const defaultLocation = Location(
    name: 'Purwokerto',
    admin1: 'Jawa Tengah',
    country: 'Indonesia',
    latitude: -7.4214,
    longitude: 109.2342,
  );

  final WeatherRepository _repository;
  final LocalStorage _storage;

  WeatherViewModel(this._repository, this._storage) {
    _location = _storage.loadLastLocation() ?? defaultLocation;
  }

  late Location _location;
  WeatherData? _data;
  LoadStatus _status = LoadStatus.idle;
  String _errorMessage = '';
  int _requestId = 0; // mencegah respons lama menimpa respons yang lebih baru

  Location get location => _location;
  WeatherData? get data => _data;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;

  /// Mengambil cuaca untuk lokasi yang sedang dipilih (request GET ke API).
  Future<void> loadWeather() async {
    final id = ++_requestId;
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final result = await _repository.getWeather(_location);
      if (id != _requestId) return;
      _data = result;
      _status = result.daily.isEmpty ? LoadStatus.empty : LoadStatus.success;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _errorMessage = e.message;
      _status = LoadStatus.error;
    } catch (_) {
      if (id != _requestId) return;
      _errorMessage = 'Terjadi kesalahan tak terduga.';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Dipanggil saat pengguna memilih kota dari layar pencarian/favorit.
  Future<void> selectLocation(Location location) async {
    _location = location;
    _data = null;
    await _storage.saveLastLocation(location);
    await loadWeather();
  }
}
