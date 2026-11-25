import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../services/local_storage.dart';

/// ViewModel lokasi favorit. Daftar disimpan di Local Storage sehingga
/// tetap tampil ketika aplikasi dibuka lagi.
class FavoritesViewModel extends ChangeNotifier {
  final LocalStorage _storage;
  late List<Location> _favorites;

  FavoritesViewModel(this._storage) {
    _favorites = _storage.loadFavorites();
  }

  List<Location> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(Location location) => _favorites.contains(location);

  /// Tambah ke favorit kalau belum ada, hapus kalau sudah ada.
  Future<void> toggle(Location location) async {
    if (isFavorite(location)) {
      _favorites = _favorites.where((e) => e != location).toList();
    } else {
      _favorites = [location, ..._favorites];
    }
    notifyListeners();
    await _storage.saveFavorites(_favorites);
  }
}
