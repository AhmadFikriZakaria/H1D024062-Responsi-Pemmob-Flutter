import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'repositories/weather_repository.dart';
import 'services/local_storage.dart';
import 'viewmodels/favorites_view_model.dart';
import 'viewmodels/search_view_model.dart';
import 'viewmodels/theme_view_model.dart';
import 'viewmodels/weather_view_model.dart';
import 'views/weather_screen.dart';

/// Akar aplikasi: mendaftarkan semua ViewModel lewat Provider (MVVM),
/// lalu menampilkan layar Home. Data cuaca langsung dimuat saat dibuka.
class CuacaApp extends StatelessWidget {
  final WeatherRepository repository;
  final LocalStorage storage;

  const CuacaApp({super.key, required this.repository, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel(storage)),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel(storage)),
        ChangeNotifierProvider(create: (_) => SearchViewModel(repository, storage)),
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(repository, storage)..loadWeather(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Cuaca Kota',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          home: const WeatherScreen(),
        ),
      ),
    );
  }
}
