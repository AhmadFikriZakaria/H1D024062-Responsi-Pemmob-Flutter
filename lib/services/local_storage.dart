import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';

/// Local Storage (SharedPreferences): lokasi favorit, riwayat pencarian,
/// lokasi terakhir yang dipilih, dan pilihan tema.
/// Semua data ini dibaca lagi ketika aplikasi dibuka.
class LocalStorage {
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'search_history';
  static const _lastLocationKey = 'last_location';
  static const _darkModeKey = 'dark_mode';
  static const maxHistory = 8;

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> create() async =>
      LocalStorage(await SharedPreferences.getInstance());

  // ---- Favorit ----
  List<Location> loadFavorites() {
    final raw = _prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((e) => Location.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<Location> favorites) => _prefs.setStringList(
      _favoritesKey, favorites.map((e) => jsonEncode(e.toJson())).toList());

  // ---- Riwayat pencarian ----
  List<String> loadHistory() => _prefs.getStringList(_historyKey) ?? [];

  Future<void> saveHistory(List<String> history) =>
      _prefs.setStringList(_historyKey, history);

  // ---- Lokasi terakhir ----
  Location? loadLastLocation() {
    final raw = _prefs.getString(_lastLocationKey);
    if (raw == null) return null;
    return Location.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLastLocation(Location location) =>
      _prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));

  // ---- Tema ----
  bool loadDarkMode() => _prefs.getBool(_darkModeKey) ?? true;

  Future<void> saveDarkMode(bool value) => _prefs.setBool(_darkModeKey, value);
}
