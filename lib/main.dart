import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'repositories/weather_repository.dart';
import 'services/local_storage.dart';
import 'services/open_meteo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID'); // nama hari/bulan Bahasa Indonesia
  final storage = await LocalStorage.create(); // Local Storage siap sebelum UI

  runApp(CuacaApp(
    repository: WeatherRepository(OpenMeteoService()),
    storage: storage,
  ));
}
