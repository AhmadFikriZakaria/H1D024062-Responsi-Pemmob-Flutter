import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/weather_codes.dart';
import '../../models/location.dart';
import '../../models/weather.dart';

/// Kartu utama: nama kota, kondisi cuaca terkini, dan suhu saat ini.
class CurrentWeatherCard extends StatelessWidget {
  final Location location;
  final WeatherData data;
  const CurrentWeatherCard(
      {super.key, required this.location, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = data.current;
    final condition = describeWeatherCode(current.weatherCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            Text(location.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            if (location.subtitle.isNotEmpty)
              Text(location.subtitle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 16),
            Icon(condition.icon, size: 84, color: condition.color),
            const SizedBox(height: 4),
            Text('${current.temperature.round()}°',
                style: theme.textTheme.displayLarge),
            Text(condition.label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Diperbarui ${DateFormat('HH:mm').format(current.time)}',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
