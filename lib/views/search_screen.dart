import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/load_status.dart';
import '../viewmodels/search_view_model.dart';
import '../viewmodels/weather_view_model.dart';
import 'widgets/gradient_background.dart';
import 'widgets/state_views.dart';

/// Layar 2: Search / Location Screen.
/// Input nama kota -> request ke Geocoding API -> pilih lokasi -> kembali ke Home.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SearchViewModel>().reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(Location location) {
    context.read<WeatherViewModel>().selectLocation(location);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cari Kota'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: vm.onQueryChanged,
                      onSubmitted: vm.search,
                      decoration: InputDecoration(
                        hintText: 'Ketik nama kota, mis. Purwokerto',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: vm.query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus',
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _controller.clear();
                                  vm.onQueryChanged('');
                                },
                              ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody(vm)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SearchViewModel vm) {
    switch (vm.status) {
      case LoadStatus.idle:
        return _IdleView(
          onSelect: _select,
          onHistoryTap: (q) {
            _controller.text = q;
            vm.search(q);
          },
        );
      case LoadStatus.loading:
        return const LoadingView(message: 'Mencari kota...');
      case LoadStatus.error:
        return ErrorView(
            message: vm.errorMessage, onRetry: () => vm.search(vm.query));
      case LoadStatus.empty:
        return EmptyView(
          icon: Icons.location_off,
          title: 'Kota tidak ditemukan',
          message: 'Tidak ada hasil untuk "${vm.query.trim()}". '
              'Coba periksa ejaan atau gunakan nama kota lain.',
        );
      case LoadStatus.success:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: vm.results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) =>
              _LocationTile(location: vm.results[i], onTap: _select),
        );
    }
  }
}

/// Tampilan awal (query kosong): lokasi favorit + riwayat pencarian.
class _IdleView extends StatelessWidget {
  final void Function(Location) onSelect;
  final void Function(String) onHistoryTap;
  const _IdleView({required this.onSelect, required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesViewModel>().favorites;
    final search = context.watch<SearchViewModel>();
    final history = search.history;
    final theme = Theme.of(context);

    if (favorites.isEmpty && history.isEmpty) {
      return const EmptyView(
        icon: Icons.travel_explore,
        title: 'Cari kota di seluruh dunia',
        message: 'Ketik nama kota untuk melihat cuacanya. '
            'Kota favorit dan riwayat pencarian akan muncul di sini.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        if (favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Favorit', style: theme.textTheme.titleMedium),
          ),
          for (final f in favorites) ...[
            _LocationTile(location: f, onTap: onSelect),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
        ],
        if (history.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('Riwayat pencarian',
                      style: theme.textTheme.titleMedium),
                ),
              ),
              TextButton(
                onPressed: search.clearHistory,
                child: const Text('Hapus'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in history)
                ActionChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(q),
                  onPressed: () => onHistoryTap(q),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Satu baris hasil lokasi, dengan tombol bintang untuk favorit.
class _LocationTile extends StatelessWidget {
  final Location location;
  final void Function(Location) onTap;
  const _LocationTile({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesViewModel>();
    final isFavorite = favorites.isFavorite(location);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.10),
        leading: const Icon(Icons.location_on_outlined),
        title: Text(location.name, style: theme.textTheme.titleMedium),
        subtitle: Text(location.subtitle.isEmpty
            ? '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}'
            : location.subtitle),
        trailing: IconButton(
          tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
          icon: Icon(isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : null),
          onPressed: () => favorites.toggle(location),
        ),
        onTap: () => onTap(location),
      ),
    );
  }
}
