import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/repositories/weather_repository.dart';
import 'package:responsi_cuaca/services/local_storage.dart';
import 'package:responsi_cuaca/services/open_meteo_service.dart';
import 'package:responsi_cuaca/viewmodels/favorites_view_model.dart';
import 'package:responsi_cuaca/viewmodels/load_status.dart';
import 'package:responsi_cuaca/viewmodels/search_view_model.dart';
import 'package:responsi_cuaca/viewmodels/weather_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

Future<LocalStorage> newStorage([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return LocalStorage.create();
}

WeatherRepository repoWith(http.Client client) =>
    WeatherRepository(OpenMeteoService(client: client));

void main() {
  const purwokerto = Location(
    name: 'Purwokerto',
    admin1: 'Jawa Tengah',
    country: 'Indonesia',
    latitude: -7.42,
    longitude: 109.23,
  );

  group('WeatherViewModel', () {
    test('loading -> success, data berasal dari API', () async {
      final vm = WeatherViewModel(repoWith(fakeClient()), await newStorage());
      expect(vm.status, LoadStatus.idle);
      final future = vm.loadWeather();
      expect(vm.status, LoadStatus.loading);
      await future;
      expect(vm.status, LoadStatus.success);
      expect(vm.data!.current.temperature, 27.4);
    });

    test('API gagal -> status error + pesan', () async {
      final vm = WeatherViewModel(
          repoWith(fakeClient(status: 500)), await newStorage());
      await vm.loadWeather();
      expect(vm.status, LoadStatus.error);
      expect(vm.errorMessage, isNotEmpty);
    });

    test('lokasi awal = Purwokerto, lalu memakai lokasi tersimpan', () async {
      final first =
          WeatherViewModel(repoWith(fakeClient()), await newStorage());
      expect(first.location.name, 'Purwokerto');

      final storage = await newStorage();
      final vm = WeatherViewModel(repoWith(fakeClient()), storage);
      await vm.selectLocation(const Location(
          name: 'Bandung', country: 'Indonesia', latitude: -6.9, longitude: 107.6));
      // ViewModel baru (aplikasi dibuka lagi) membaca lokasi terakhir.
      final reopened = WeatherViewModel(repoWith(fakeClient()), storage);
      expect(reopened.location.name, 'Bandung');
    });
  });

  group('SearchViewModel', () {
    test('hasil ditemukan + masuk riwayat (tersimpan)', () async {
      final storage = await newStorage();
      final vm = SearchViewModel(repoWith(fakeClient()), storage);
      await vm.search('Purwokerto');
      expect(vm.status, LoadStatus.success);
      expect(vm.results.length, 2);
      expect(vm.history, ['Purwokerto']);
      expect(SearchViewModel(repoWith(fakeClient()), storage).history,
          ['Purwokerto']);
    });

    test('tidak ada hasil -> empty dan tidak masuk riwayat', () async {
      final vm =
          SearchViewModel(repoWith(fakeClient(empty: true)), await newStorage());
      await vm.search('zzzz');
      expect(vm.status, LoadStatus.empty);
      expect(vm.history, isEmpty);
    });

    test('error jaringan -> status error', () async {
      final vm = SearchViewModel(
        repoWith(MockClient((_) async => throw Exception('offline'))),
        await newStorage(),
      );
      await vm.search('Jakarta');
      expect(vm.status, LoadStatus.error);
    });

    test('query kosong -> idle, riwayat tidak duplikat & maksimal 8', () async {
      final vm = SearchViewModel(repoWith(fakeClient()), await newStorage());
      await vm.search('   ');
      expect(vm.status, LoadStatus.idle);
      for (var i = 0; i < 10; i++) {
        await vm.search('kota$i');
      }
      await vm.search('KOTA5');
      expect(vm.history.length, LocalStorage.maxHistory);
      expect(vm.history.first, 'KOTA5');
      expect(vm.history.where((e) => e.toLowerCase() == 'kota5').length, 1);
    });

    test('clearHistory mengosongkan riwayat', () async {
      final vm = SearchViewModel(repoWith(fakeClient()), await newStorage());
      await vm.search('Purwokerto');
      await vm.clearHistory();
      expect(vm.history, isEmpty);
    });
  });

  group('FavoritesViewModel', () {
    test('toggle menambah/menghapus dan tersimpan di Local Storage', () async {
      final storage = await newStorage();
      final vm = FavoritesViewModel(storage);
      expect(vm.isFavorite(purwokerto), isFalse);
      await vm.toggle(purwokerto);
      expect(vm.isFavorite(purwokerto), isTrue);

      // Aplikasi dibuka lagi: favorit masih ada.
      expect(FavoritesViewModel(storage).favorites.single.name, 'Purwokerto');

      await vm.toggle(purwokerto);
      expect(vm.favorites, isEmpty);
      expect(FavoritesViewModel(storage).favorites, isEmpty);
    });
  });
}
