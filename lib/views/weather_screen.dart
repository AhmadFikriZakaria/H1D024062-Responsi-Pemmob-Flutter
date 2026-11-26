import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/load_status.dart';
import '../viewmodels/theme_view_model.dart';
import '../viewmodels/weather_view_model.dart';
import 'search_screen.dart';
import 'widgets/current_weather.dart';
import 'widgets/detail_list.dart';
import 'widgets/forecast_list.dart';
import 'widgets/panel.dart';
import 'widgets/state_views.dart';

/// Layar 1: Home / Weather Screen.
/// Hanya menampilkan state dari [WeatherViewModel]; tidak ada logika API di sini.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final favorites = context.watch<FavoritesViewModel>();
    final theme = context.watch<ThemeViewModel>();
    final isFavorite = favorites.isFavorite(vm.location);
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca Kota'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
            icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? c.onSurface : null),
            onPressed: () => favorites.toggle(vm.location),
          ),
          IconButton(
            tooltip: 'Cari kota',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            tooltip: theme.isDark ? 'Tema terang' : 'Tema gelap',
            icon: Icon(theme.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: theme.toggle,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: _buildBody(context, vm)),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    switch (vm.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return LoadingView(message: 'Memuat cuaca ${vm.location.name}...');
      case LoadStatus.error:
        return ErrorView(message: vm.errorMessage, onRetry: vm.loadWeather);
      case LoadStatus.empty:
        return const EmptyView(
          title: 'Data cuaca kosong',
          message: 'Server tidak mengirim data untuk lokasi ini.',
        );
      case LoadStatus.success:
        final data = vm.data!;
        final theme = Theme.of(context);
        return RefreshIndicator(
          color: theme.colorScheme.onSurface,
          backgroundColor: theme.colorScheme.surfaceContainer,
          onRefresh: vm.loadWeather,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                children: [
                  CurrentWeatherSection(location: vm.location, data: data),
                  const SizedBox(height: 36),
                  const SectionLabel('Detail'),
                  WeatherDetailsList(data: data),
                  const SizedBox(height: 28),
                  SectionLabel('Prakiraan ${data.daily.length} hari'),
                  ForecastList(daily: data.daily),
                  const SizedBox(height: 24),
                  Text('Sumber data: Open-Meteo.com',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
          ),
        );
    }
  }
}
