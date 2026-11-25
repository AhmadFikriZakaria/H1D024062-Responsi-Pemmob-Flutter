import 'package:flutter/material.dart';

import '../../models/weather.dart';

/// Satu kotak informasi tambahan (ikon, label, nilai).
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoTile(
      {super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor)),
                  Text(value, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid 2 kolom informasi tambahan: terasa seperti, kelembapan, angin,
/// curah hujan, dan peluang hujan hari ini.
class WeatherDetailsGrid extends StatelessWidget {
  final WeatherData data;
  const WeatherDetailsGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final c = data.current;
    final rain = data.todayRainProbability;
    final tiles = [
      InfoTile(
          icon: Icons.thermostat,
          label: 'Terasa seperti',
          value: '${c.apparentTemperature.round()}°'),
      InfoTile(
          icon: Icons.water_drop_outlined,
          label: 'Kelembapan',
          value: '${c.humidity}%'),
      InfoTile(
          icon: Icons.air,
          label: 'Kecepatan angin',
          value: '${c.windSpeed.round()} ${data.windUnit}'),
      InfoTile(
          icon: Icons.grain,
          label: 'Curah hujan',
          value: '${c.precipitation} ${data.precipitationUnit}'),
      InfoTile(
          icon: Icons.umbrella_outlined,
          label: 'Peluang hujan hari ini',
          value: rain == null ? '-' : '$rain%'),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < tiles.length; i++)
            // Tile terakhir (ganjil) dibuat selebar penuh agar rapi.
            SizedBox(
              width: i == tiles.length - 1 && tiles.length.isOdd
                  ? constraints.maxWidth
                  : width,
              child: tiles[i],
            ),
        ],
      );
    });
  }
}
