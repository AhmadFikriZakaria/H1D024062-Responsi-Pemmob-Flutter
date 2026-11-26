import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/weather_codes.dart';
import '../../models/location.dart';
import '../../models/weather.dart';

/// Bagian utama: nama kota, suhu saat ini, dan kondisi cuaca terkini.
/// Sengaja tanpa kartu/ikon besar; hierarki dibentuk oleh ukuran teks.
class CurrentWeatherSection extends StatelessWidget {
  final Location location;
  final WeatherData data;
  const CurrentWeatherSection(
      {super.key, required this.location, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final current = data.current;
    final condition = describeWeatherCode(current.weatherCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(location.name, style: theme.textTheme.headlineSmall),
        if (location.subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(location.subtitle, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 28),
        Text('${current.temperature.round()}°',
            style: theme.textTheme.displayLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(condition.icon, size: 16, color: c.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(condition.label, style: theme.textTheme.bodyLarge),
            const SizedBox(width: 10),
            Text('Diperbarui ${DateFormat('HH:mm').format(current.time)}',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
