import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_cuaca/core/weather_codes.dart';
import 'package:responsi_cuaca/models/weather.dart';
import 'package:responsi_cuaca/services/open_meteo_service.dart';

import 'fixtures.dart';

void main() {
  group('Model WeatherData', () {
    test('JSON diubah menjadi model Dart dengan benar', () {
      final data = WeatherData.fromJson(forecastJson());
      expect(data.current.temperature, 27.4);
      expect(data.current.humidity, 80);
      expect(data.current.weatherCode, 61);
      expect(data.windUnit, 'km/h');
      expect(data.daily.length, 3);
      expect(data.daily.first.tempMax, 30.1);
      expect(data.todayRainProbability, 85);
      expect(data.daily.last.rainProbability, isNull); // null dari API
    });

    test('field precipitation_probability_max boleh tidak ada', () {
      final data = WeatherData.fromJson(forecastJson(withRain: false));
      expect(data.todayRainProbability, isNull);
    });

    test('JSON tanpa current/daily melempar FormatException', () {
      expect(() => WeatherData.fromJson({}), throwsFormatException);
    });
  });

  group('describeWeatherCode', () {
    test('kode WMO dipetakan ke teks Bahasa Indonesia', () {
      expect(describeWeatherCode(0).label, 'Cerah');
      expect(describeWeatherCode(61).label, 'Hujan ringan');
      expect(describeWeatherCode(95).label, 'Badai petir');
      expect(describeWeatherCode(1234).label, 'Tidak diketahui');
    });
  });

  group('OpenMeteoService', () {
    test('searchLocations memanggil Geocoding API dengan GET', () async {
      late http.Request captured;
      final service = OpenMeteoService(
        client: MockClient((request) async {
          captured = request;
          return fakeClient().get(request.url);
        }),
      );
      final result = await service.searchLocations('Purwokerto');
      expect(captured.method, 'GET');
      expect(captured.url.host, 'geocoding-api.open-meteo.com');
      expect(captured.url.queryParameters['name'], 'Purwokerto');
      expect(result.length, 2);
      expect(result.first.admin1, 'Jawa Tengah');
      expect(result.last.admin1, isNull);
    });

    test('hasil kosong -> list kosong', () async {
      final service = OpenMeteoService(client: fakeClient(empty: true));
      expect(await service.searchLocations('zzzz'), isEmpty);
    });

    test('fetchWeather mengirim koordinat, current, daily, timezone=auto',
        () async {
      late Uri url;
      final service = OpenMeteoService(
        client: MockClient((request) async {
          url = request.url;
          return fakeClient().get(request.url);
        }),
      );
      final weather = await service.fetchWeather(-7.42, 109.23);
      expect(url.host, 'api.open-meteo.com');
      expect(url.queryParameters['latitude'], '-7.42');
      expect(url.queryParameters['longitude'], '109.23');
      expect(url.queryParameters['timezone'], 'auto');
      expect(url.queryParameters['current'], contains('temperature_2m'));
      expect(url.queryParameters['daily'],
          contains('precipitation_probability_max'));
      expect(weather.current.temperature, 27.4);
    });

    test('status bukan 200 -> ApiException', () async {
      final service = OpenMeteoService(client: fakeClient(status: 500));
      expect(() => service.fetchWeather(0, 0),
          throwsA(isA<ApiException>()));
    });

    test('tidak ada koneksi -> ApiException ramah', () async {
      final service = OpenMeteoService(
        client: MockClient((_) async => throw Exception('offline')),
      );
      expect(
        () => service.searchLocations('x'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('koneksi'))),
      );
    });

    test('respons bukan JSON -> ApiException', () async {
      final service = OpenMeteoService(
        client: MockClient((_) async => http.Response('<html>', 200)),
      );
      expect(() => service.fetchWeather(0, 0), throwsA(isA<ApiException>()));
    });
  });
}
