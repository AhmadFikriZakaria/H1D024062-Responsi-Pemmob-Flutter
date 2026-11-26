import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:responsi_cuaca/app.dart';
import 'package:responsi_cuaca/repositories/weather_repository.dart';
import 'package:responsi_cuaca/services/local_storage.dart';
import 'package:responsi_cuaca/services/open_meteo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

Future<void> pumpApp(WidgetTester tester, {int status = 200}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorage.create();
  await tester.pumpWidget(CuacaApp(
    repository:
        WeatherRepository(OpenMeteoService(client: fakeClient(status: status))),
    storage: storage,
  ));
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  testWidgets('Home menampilkan kota, suhu, dan info dari API', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Purwokerto'), findsOneWidget);
    expect(find.text('27°'), findsOneWidget);
    expect(find.text('Hujan ringan'), findsWidgets);
    expect(find.text('80%'), findsOneWidget); // kelembapan
    expect(find.text('85%'), findsWidgets); // peluang hujan (detail + prakiraan)
    // Daftar prakiraan ada di bawah layar: scroll dulu.
    await tester.scrollUntilVisible(find.text('Besok'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Besok'), findsOneWidget);
  });

  testWidgets('Error API -> pesan + tombol Coba lagi', (tester) async {
    await pumpApp(tester, status: 500);
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('Cari kota -> pilih -> favorit tersimpan', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Cari kota di seluruh dunia'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Purwokerto');
    await tester.pump(const Duration(milliseconds: 600)); // debounce
    await tester.pumpAndSettle();
    expect(find.text('Jawa Tengah, Indonesia'), findsOneWidget);

    // Bintang favorit di hasil pertama.
    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsOneWidget);

    // Pilih lokasi -> kembali ke Home.
    await tester.tap(find.text('Jawa Tengah, Indonesia'));
    await tester.pumpAndSettle();
    expect(find.text('Cuaca Kota'), findsOneWidget);
  });
}
