import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../viewmodels/favorites_view_model.dart';
import '../viewmodels/load_status.dart';
import '../viewmodels/search_view_model.dart';
import '../viewmodels/weather_view_model.dart';
import 'widgets/panel.dart';
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
    final theme = Theme.of(context);

    return CallbackShortcuts(
      // Esc = kembali ke Home (kebiasaan keyboard di web/desktop).
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: vm.onQueryChanged,
            onSubmitted: vm.search,
            style: theme.textTheme.bodyLarge,
            cursorWidth: 1.5,
            decoration: InputDecoration(
              hintText: 'Ketik nama kota, mis. Purwokerto',
              hintStyle: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          actions: [
            if (vm.query.isNotEmpty)
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  vm.onQueryChanged('');
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _buildBody(vm),
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
          title: 'Kota tidak ditemukan',
          message: 'Tidak ada hasil untuk "${vm.query.trim()}". '
              'Coba periksa ejaan atau gunakan nama kota lain.',
        );
      case LoadStatus.success:
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            SectionLabel('${vm.results.length} hasil'),
            _LocationList(locations: vm.results, onTap: _select),
          ],
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
    final c = theme.colorScheme;

    if (favorites.isEmpty && history.isEmpty) {
      return const EmptyView(
        title: 'Cari kota di seluruh dunia',
        message: 'Ketik nama kota untuk melihat cuacanya. '
            'Kota favorit dan riwayat pencarian akan muncul di sini.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        if (favorites.isNotEmpty) ...[
          const SectionLabel('Favorit'),
          _LocationList(locations: favorites, onTap: onSelect),
          const SizedBox(height: 28),
        ],
        if (history.isNotEmpty) ...[
          SectionLabel(
            'Riwayat pencarian',
            trailing: TextButton(
              onPressed: search.clearHistory,
              child: const Text('Hapus'),
            ),
          ),
          Panel(
            child: Column(
              children: [
                for (var i = 0; i < history.length; i++) ...[
                  if (i > 0) const RowDivider(),
                  HoverRow(
                    onTap: () => onHistoryTap(history[i]),
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 16, color: c.outline),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(history[i],
                                style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Daftar baris lokasi dalam satu [Panel].
class _LocationList extends StatelessWidget {
  final List<Location> locations;
  final void Function(Location) onTap;
  const _LocationList({required this.locations, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          for (var i = 0; i < locations.length; i++) ...[
            if (i > 0) const RowDivider(),
            _LocationRow(location: locations[i], onTap: onTap),
          ],
        ],
      ),
    );
  }
}

/// Satu baris hasil lokasi, dengan tombol bintang untuk favorit.
class _LocationRow extends StatelessWidget {
  final Location location;
  final void Function(Location) onTap;
  const _LocationRow({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesViewModel>();
    final isFavorite = favorites.isFavorite(location);
    final theme = Theme.of(context);
    final c = theme.colorScheme;

    return HoverRow(
      onTap: () => onTap(location),
      padding: const EdgeInsets.only(left: 14, right: 6),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall),
                  Text(
                    location.subtitle.isEmpty
                        ? '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}'
                        : location.subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
              icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? c.onSurface : null),
              onPressed: () => favorites.toggle(location),
            ),
          ],
        ),
      ),
    );
  }
}
