import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../repositories/weather_repository.dart';
import '../services/local_storage.dart';
import '../services/open_meteo_service.dart';
import 'load_status.dart';

/// ViewModel layar pencarian: query, hasil pencarian (dari Geocoding API),
/// status, dan riwayat pencarian (Local Storage).
class SearchViewModel extends ChangeNotifier {
  final WeatherRepository _repository;
  final LocalStorage _storage;

  SearchViewModel(this._repository, this._storage) {
    _history = _storage.loadHistory();
  }

  Timer? _debounce;
  int _requestId = 0;

  String _query = '';
  List<Location> _results = [];
  List<String> _history = [];
  LoadStatus _status = LoadStatus.idle;
  String _errorMessage = '';

  String get query => _query;
  List<Location> get results => _results;
  List<String> get history => _history;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;

  /// Dipanggil setiap teks berubah. Request dikirim setelah pengguna
  /// berhenti mengetik 500 ms (debounce) supaya tidak boros request.
  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _requestId++;
      _results = [];
      _status = LoadStatus.idle;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => search(value));
  }

  /// Mencari kota ke API (dipanggil debounce, tombol cari, atau riwayat).
  Future<void> search(String value) async {
    final text = value.trim();
    _query = value;
    _debounce?.cancel();
    if (text.isEmpty) {
      _results = [];
      _status = LoadStatus.idle;
      notifyListeners();
      return;
    }

    final id = ++_requestId;
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final found = await _repository.searchCity(text);
      if (id != _requestId) return;
      _results = found;
      if (found.isEmpty) {
        _status = LoadStatus.empty;
      } else {
        _status = LoadStatus.success;
        await _addToHistory(text);
      }
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _errorMessage = e.message;
      _status = LoadStatus.error;
    } catch (_) {
      if (id != _requestId) return;
      _errorMessage = 'Terjadi kesalahan tak terduga.';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> _addToHistory(String text) async {
    final updated = [
      text,
      ..._history.where((e) => e.toLowerCase() != text.toLowerCase()),
    ].take(LocalStorage.maxHistory).toList();
    _history = updated;
    await _storage.saveHistory(updated);
  }

  Future<void> clearHistory() async {
    _history = [];
    await _storage.saveHistory([]);
    notifyListeners();
  }

  /// Reset saat layar pencarian dibuka lagi.
  void reset() {
    _debounce?.cancel();
    _requestId++;
    _query = '';
    _results = [];
    _status = LoadStatus.idle;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
