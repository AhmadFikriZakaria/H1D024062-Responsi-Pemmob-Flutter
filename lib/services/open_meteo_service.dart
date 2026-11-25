import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../models/weather.dart';

/// Error yang sudah diberi pesan ramah untuk ditampilkan ke pengguna.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Lapisan jaringan: semua HTTP request ke Open-Meteo ada di sini.
/// Metode yang dipakai hanya GET.
class OpenMeteoService {
  static const _geocodingHost = 'geocoding-api.open-meteo.com';
  static const _forecastHost = 'api.open-meteo.com';

  final http.Client _client;

  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  /// Geocoding API: cari kota berdasarkan nama.
  /// Kalau tidak ada hasil, API tidak mengirim field `results` -> list kosong.
  Future<List<Location>> searchLocations(String name) async {
    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': name,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });
    final json = await _getJson(uri);
    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((e) => Location.fromGeocodingJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Forecast API: cuaca terkini + prakiraan 7 hari untuk satu koordinat.
  Future<WeatherData> fetchWeather(double latitude, double longitude) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'precipitation,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final json = await _getJson(uri);
    try {
      return WeatherData.fromJson(json);
    } on FormatException catch (e) {
      throw ApiException(e.message);
    } on TypeError {
      throw const ApiException('Format data cuaca dari server tidak dikenali.');
    }
  }

  /// HTTP GET + decode JSON + terjemahkan error jadi [ApiException].
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw ApiException(
            'Server mengembalikan kode ${response.statusCode}. Coba lagi nanti.');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Respons server tidak sesuai format JSON.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Koneksi terlalu lama. Periksa internet Anda.');
    } on FormatException {
      throw const ApiException('Respons server bukan JSON yang valid.');
    } catch (_) {
      // Mis. tidak ada internet (SocketException / ClientException).
      throw const ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
  }

  void dispose() => _client.close();
}
