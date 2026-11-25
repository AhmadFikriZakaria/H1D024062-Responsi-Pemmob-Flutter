import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/load_status.dart';
import '../viewmodels/theme_view_model.dart';
import '../viewmodels/weather_view_model.dart';
import 'search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/forecast_list.dart';
import 'widgets/gradient_background.dart';
import 'widgets/info_tile.dart';
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

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cuaca Kota'),
          actions: [
            IconButton(
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
              icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : null),
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
              icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: theme.toggle,
            ),
          ],
        ),
        body: SafeArea(child: _buildBody(context, vm)),
      ),
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
          icon: Icons.cloud_queue,
          title: 'Data cuaca kosong',
          message: 'Server tidak mengirim data untuk lokasi ini.',
        );
      case LoadStatus.success:
        final data = vm.data!;
        return RefreshIndicator(
          onRefresh: vm.loadWeather,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  CurrentWeatherCard(location: vm.location, data: data),
                  const SizedBox(height: 12),
                  WeatherDetailsGrid(data: data),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Prakiraan ${data.daily.length} hari',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ForecastList(daily: data.daily),
                  const SizedBox(height: 16),
                  Center(
                    child: Text('Sumber data: Open-Meteo.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).hintColor)),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
