import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/weather.dart';
import 'panel.dart';

/// Daftar properti cuaca (label di kiri, nilai di kanan): terasa seperti,
/// kelembapan, kecepatan angin, curah hujan, dan peluang hujan hari ini.
class WeatherDetailsList extends StatelessWidget {
  final WeatherData data;
  const WeatherDetailsList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final c = data.current;
    final rain = data.todayRainProbability;
    final rows = <(IconData, String, String)>[
      (Icons.thermostat, 'Terasa seperti', '${c.apparentTemperature.round()}°'),
      (Icons.water_drop_outlined, 'Kelembapan', '${c.humidity}%'),
      (Icons.air, 'Kecepatan angin', '${c.windSpeed.round()} ${data.windUnit}'),
      (Icons.grain, 'Curah hujan', '${c.precipitation} ${data.precipitationUnit}'),
      (Icons.umbrella_outlined, 'Peluang hujan hari ini',
          rain == null ? '-' : '$rain%'),
    ];

    return Panel(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const RowDivider(),
            _DetailRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverRow(
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
            Text(value,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontFeatures: AppTheme.tabular)),
          ],
        ),
      ),
    );
  }
}
