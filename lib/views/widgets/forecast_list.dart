import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../core/weather_codes.dart';
import '../../models/weather.dart';
import 'panel.dart';

/// Prakiraan harian berbentuk tabel: hari, kondisi, peluang hujan, dan
/// rentang suhu min-maks (dengan bar tipis relatif terhadap seluruh minggu).
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
    final weekMin = daily.map((d) => d.tempMin).reduce(math.min);
    final weekMax = daily.map((d) => d.tempMax).reduce(math.max);
    final head = theme.textTheme.labelSmall;

    return Panel(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text('HARI', style: head)),
                SizedBox(
                    width: 44,
                    child: Text('HUJAN', textAlign: TextAlign.right, style: head)),
                const SizedBox(width: 16),
                SizedBox(
                    width: 112,
                    child: Text('SUHU', textAlign: TextAlign.right, style: head)),
              ],
            ),
          ),
          for (var i = 0; i < daily.length; i++) ...[
            const RowDivider(),
            _ForecastRow(
              label: _dayLabel(i, daily[i].date),
              date: DateFormat('d MMM', 'id_ID').format(daily[i].date),
              forecast: daily[i],
              weekMin: weekMin,
              weekMax: weekMax,
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
  final double weekMin;
  final double weekMax;
  const _ForecastRow({
    required this.label,
    required this.date,
    required this.forecast,
    required this.weekMin,
    required this.weekMax,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final condition = describeWeatherCode(forecast.weatherCode);
    final rain = forecast.rainProbability;
    final num = theme.textTheme.bodyMedium
        ?.copyWith(fontFeatures: AppTheme.tabular);

    return HoverRow(
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Icon(condition.icon, size: 16, color: c.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall),
                  Text(date, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(rain == null ? '-' : '$rain%',
                  textAlign: TextAlign.right,
                  style: num?.copyWith(color: c.onSurfaceVariant)),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 112,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text('${forecast.tempMin.round()}°',
                        textAlign: TextAlign.right,
                        style: num?.copyWith(color: c.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 8),
                  _RangeBar(
                    min: forecast.tempMin,
                    max: forecast.tempMax,
                    weekMin: weekMin,
                    weekMax: weekMax,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text('${forecast.tempMax.round()}°',
                        textAlign: TextAlign.right,
                        style: num?.copyWith(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bar tipis 3px: posisi rentang suhu hari itu terhadap rentang seminggu.
class _RangeBar extends StatelessWidget {
  final double min, max, weekMin, weekMax;
  const _RangeBar({
    required this.min,
    required this.max,
    required this.weekMin,
    required this.weekMax,
  });

  static const double _width = 40;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final span = weekMax - weekMin;
    final start = span <= 0 ? 0.0 : (min - weekMin) / span * _width;
    final len = span <= 0 ? _width : math.max(4.0, (max - min) / span * _width);
    return SizedBox(
      width: _width,
      height: 3,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: c.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            left: math.min(start, _width - len),
            width: len,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
