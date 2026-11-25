import 'package:flutter/material.dart';

/// Deskripsi kondisi cuaca untuk satu kode WMO (`weather_code` Open-Meteo).
class WeatherCondition {
  final String label;
  final IconData icon;
  final Color color;

  const WeatherCondition(this.label, this.icon, this.color);
}

/// Memetakan kode cuaca WMO ke teks Bahasa Indonesia + ikon.
/// Daftar kode: https://open-meteo.com/en/docs (bagian "WMO Weather interpretation codes").
WeatherCondition describeWeatherCode(int code) {
  switch (code) {
    case 0:
      return const WeatherCondition('Cerah', Icons.wb_sunny, Color(0xFFFFC107));
    case 1:
      return const WeatherCondition(
          'Cerah berawan', Icons.wb_sunny_outlined, Color(0xFFFFB300));
    case 2:
      return const WeatherCondition(
          'Berawan sebagian', Icons.cloud_queue, Color(0xFF90A4AE));
    case 3:
      return const WeatherCondition('Mendung', Icons.cloud, Color(0xFF78909C));
    case 45:
    case 48:
      return const WeatherCondition('Berkabut', Icons.foggy, Color(0xFFB0BEC5));
    case 51:
    case 53:
    case 55:
      return const WeatherCondition('Gerimis', Icons.grain, Color(0xFF4FC3F7));
    case 56:
    case 57:
      return const WeatherCondition(
          'Gerimis beku', Icons.ac_unit, Color(0xFF81D4FA));
    case 61:
      return const WeatherCondition(
          'Hujan ringan', Icons.water_drop, Color(0xFF4FC3F7));
    case 63:
      return const WeatherCondition(
          'Hujan sedang', Icons.water_drop, Color(0xFF29B6F6));
    case 65:
      return const WeatherCondition(
          'Hujan lebat', Icons.water_drop, Color(0xFF0288D1));
    case 66:
    case 67:
      return const WeatherCondition(
          'Hujan beku', Icons.ac_unit, Color(0xFF81D4FA));
    case 71:
    case 73:
    case 75:
    case 77:
      return const WeatherCondition('Salju', Icons.ac_unit, Color(0xFFE1F5FE));
    case 80:
    case 81:
    case 82:
      return const WeatherCondition(
          'Hujan lokal', Icons.umbrella, Color(0xFF29B6F6));
    case 85:
    case 86:
      return const WeatherCondition(
          'Salju lokal', Icons.ac_unit, Color(0xFFE1F5FE));
    case 95:
      return const WeatherCondition(
          'Badai petir', Icons.thunderstorm, Color(0xFFFFCA28));
    case 96:
    case 99:
      return const WeatherCondition(
          'Badai petir & es', Icons.thunderstorm, Color(0xFFFFA000));
    default:
      return const WeatherCondition(
          'Tidak diketahui', Icons.help_outline, Color(0xFF9E9E9E));
  }
}
