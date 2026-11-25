import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Respons palsu yang bentuknya sama dengan API Open-Meteo asli.
const geocodingJson = {
  'results': [
    {
      'id': 1,
      'name': 'Purwokerto',
      'latitude': -7.42,
      'longitude': 109.23,
      'country': 'Indonesia',
      'admin1': 'Jawa Tengah',
    },
    {
      'id': 2,
      'name': 'Purwokerto',
      'latitude': -7.0,
      'longitude': 110.0,
      'country': 'Indonesia',
    },
  ],
};

Map<String, dynamic> forecastJson({bool withRain = true}) => {
      'current_units': {'wind_speed_10m': 'km/h', 'precipitation': 'mm'},
      'current': {
        'time': '2026-11-25T17:00',
        'temperature_2m': 27.4,
        'relative_humidity_2m': 80,
        'apparent_temperature': 31.2,
        'precipitation': 0.2,
        'weather_code': 61,
        'wind_speed_10m': 8.5,
      },
      'daily': {
        'time': ['2026-11-25', '2026-11-26', '2026-11-27'],
        'weather_code': [61, 3, 0],
        'temperature_2m_max': [30.1, 29.0, 31.5],
        'temperature_2m_min': [22.0, 21.5, 22.3],
        'precipitation_probability_max': withRain ? [85, 40, null] : null,
      },
    };

MockClient fakeClient({int status = 200, bool empty = false}) =>
    MockClient((http.Request request) async {
      if (request.url.host == 'geocoding-api.open-meteo.com') {
        return http.Response(jsonEncode(empty ? {} : geocodingJson), status);
      }
      return http.Response(jsonEncode(forecastJson()), status);
    });
