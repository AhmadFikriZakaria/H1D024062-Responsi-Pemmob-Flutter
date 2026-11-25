/// Cuaca saat ini (`current` pada Forecast API).
class CurrentWeather {
  final DateTime time;
  final double temperature; // current.temperature_2m
  final double apparentTemperature; // current.apparent_temperature
  final int humidity; // current.relative_humidity_2m
  final double precipitation; // current.precipitation
  final int weatherCode; // current.weather_code
  final double windSpeed; // current.wind_speed_10m

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).round(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

/// Prakiraan satu hari (satu elemen dari array `daily`).
class DailyForecast {
  final DateTime date;
  final int weatherCode; // daily.weather_code
  final double tempMax; // daily.temperature_2m_max
  final double tempMin; // daily.temperature_2m_min
  final int? rainProbability; // daily.precipitation_probability_max (bisa null)

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    this.rainProbability,
  });
}

/// Gabungan respons Forecast API: cuaca terkini + prakiraan harian.
class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final String windUnit; // mis. "km/h"
  final String precipitationUnit; // mis. "mm"

  const WeatherData({
    required this.current,
    required this.daily,
    required this.windUnit,
    required this.precipitationUnit,
  });

  /// Peluang hujan maksimum hari ini (elemen pertama `daily`).
  int? get todayRainProbability =>
      daily.isEmpty ? null : daily.first.rainProbability;

  /// Mengubah JSON Forecast API menjadi model Dart.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final daily = json['daily'];
    if (current is! Map<String, dynamic> || daily is! Map<String, dynamic>) {
      throw const FormatException('Data cuaca dari server tidak lengkap.');
    }

    final dates = (daily['time'] as List<dynamic>).cast<String>();
    final codes = daily['weather_code'] as List<dynamic>;
    final maxes = daily['temperature_2m_max'] as List<dynamic>;
    final mins = daily['temperature_2m_min'] as List<dynamic>;
    final rains = daily['precipitation_probability_max'] as List<dynamic>?;

    final forecasts = <DailyForecast>[
      for (var i = 0; i < dates.length; i++)
        DailyForecast(
          date: DateTime.parse(dates[i]),
          weatherCode: (codes[i] as num).toInt(),
          tempMax: (maxes[i] as num).toDouble(),
          tempMin: (mins[i] as num).toDouble(),
          rainProbability:
              rains == null || rains[i] == null ? null : (rains[i] as num).round(),
        ),
    ];

    final units = json['current_units'];
    return WeatherData(
      current: CurrentWeather.fromJson(current),
      daily: forecasts,
      windUnit: units is Map ? (units['wind_speed_10m'] as String? ?? 'km/h') : 'km/h',
      precipitationUnit:
          units is Map ? (units['precipitation'] as String? ?? 'mm') : 'mm',
    );
  }
}
