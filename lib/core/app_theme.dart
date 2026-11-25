import 'package:flutter/material.dart';

/// Pengaturan Theme + Typography agar tampilan konsisten di semua layar.
class AppTheme {
  static const _seed = Color(0xFF38BDF8); // biru langit

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: Colors.transparent,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge
            ?.copyWith(fontWeight: FontWeight.w300, letterSpacing: -2),
        headlineSmall:
            base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        titleMedium:
            base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.65),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  /// Warna latar gradasi lembut sesuai tema.
  static List<Color> backgroundColors(Brightness brightness) =>
      brightness == Brightness.dark
          ? const [Color(0xFF0B1120), Color(0xFF14233F), Color(0xFF1E1B4B)]
          : const [Color(0xFFE0F2FE), Color(0xFFBAE6FD), Color(0xFFDDD6FE)];
}
