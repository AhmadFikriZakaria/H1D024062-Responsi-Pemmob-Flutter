import 'package:flutter/material.dart';

import '../services/local_storage.dart';

/// ViewModel tema: gelap (default) atau terang, disimpan di Local Storage.
class ThemeViewModel extends ChangeNotifier {
  final LocalStorage _storage;
  late bool _isDark;

  ThemeViewModel(this._storage) {
    _isDark = _storage.loadDarkMode();
  }

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    await _storage.saveDarkMode(_isDark);
  }
}
