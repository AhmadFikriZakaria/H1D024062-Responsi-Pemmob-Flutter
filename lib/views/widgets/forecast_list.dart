import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/weather_codes.dart';
import '../../models/weather.dart';

/// Daftar perkiraan cuaca beberapa hari ke depan.
class ForecastList extends StatelessWidget {
  final List<DailyForecast> daily;
  const ForecastList({super.key, required this.daily});

  String _dayLabel(int index, DateTime date) {
    if (index == 0) return 'Hari ini';
    if (index == 1) return 'Besok';
    return DateFormat('EEEE', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < daily.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _ForecastRow(
              label: _dayLabel(i, daily[i].date),
              date: DateFormat('d MMM', 'id_ID').format(daily[i].date),
              forecast: daily[i],
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final String label;
  final String date;
  final DailyForecast forecast;
  final ThemeData theme;
  const _ForecastRow({
    required this.label,
    required this.date,
    required this.forecast,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final condition = describeWeatherCode(forecast.weatherCode);
    final rain = forecast.rainProbability;
    return InkWell(
      onTap: () {},
      hoverColor: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleMedium),
                  Text(date,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor)),
                ],
              ),
            ),
            Icon(condition.icon, color: condition.color),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                rain == null ? '' : '💧 $rain%',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              '${forecast.tempMin.round()}°',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(width: 8),
            Text('${forecast.tempMax.round()}°',
                style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
