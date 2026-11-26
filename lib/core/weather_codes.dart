import 'package:flutter/material.dart';

/// Deskripsi kondisi cuaca untuk satu kode WMO (`weather_code` Open-Meteo).
class WeatherCondition {
  final String label;
  final IconData icon;

  const WeatherCondition(this.label, this.icon);
}

/// Memetakan kode cuaca WMO ke teks Bahasa Indonesia + ikon outline.
/// Daftar kode: https://open-meteo.com/en/docs (bagian "WMO Weather interpretation codes").
WeatherCondition describeWeatherCode(int code) {
  switch (code) {
    case 0:
      return const WeatherCondition('Cerah', Icons.wb_sunny_outlined);
    case 1:
      return const WeatherCondition('Cerah berawan', Icons.wb_sunny_outlined);
    case 2:
      return const WeatherCondition('Berawan sebagian', Icons.cloud_queue);
    case 3:
      return const WeatherCondition('Mendung', Icons.cloud_outlined);
    case 45:
    case 48:
      return const WeatherCondition('Berkabut', Icons.foggy);
    case 51:
    case 53:
    case 55:
      return const WeatherCondition('Gerimis', Icons.grain);
    case 56:
    case 57:
      return const WeatherCondition('Gerimis beku', Icons.ac_unit);
    case 61:
      return const WeatherCondition('Hujan ringan', Icons.water_drop_outlined);
    case 63:
      return const WeatherCondition('Hujan sedang', Icons.water_drop_outlined);
    case 65:
      return const WeatherCondition('Hujan lebat', Icons.water_drop_outlined);
    case 66:
    case 67:
      return const WeatherCondition('Hujan beku', Icons.ac_unit);
    case 71:
    case 73:
    case 75:
    case 77:
      return const WeatherCondition('Salju', Icons.ac_unit);
    case 80:
    case 81:
    case 82:
      return const WeatherCondition('Hujan lokal', Icons.water_drop_outlined);
    case 85:
    case 86:
      return const WeatherCondition('Salju lokal', Icons.ac_unit);
    case 95:
      return const WeatherCondition('Badai petir', Icons.thunderstorm_outlined);
    case 96:
    case 99:
      return const WeatherCondition(
          'Badai petir & es', Icons.thunderstorm_outlined);
    default:
      return const WeatherCondition('Tidak diketahui', Icons.help_outline);
  }
}
