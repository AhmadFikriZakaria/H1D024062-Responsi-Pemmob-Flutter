import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme + Typography. Gaya: datar, netral, border tipis, satu keluarga font
/// (Inter). Tidak ada gradasi, kaca, atau warna aksen mencolok; hierarki
/// dibangun dari ukuran, bobot, dan tingkat kontras teks.
///
/// Peta warna (ColorScheme):
///   surface                 -> latar halaman
///   surfaceContainer        -> panel / kontainer
///   surfaceContainerHighest -> warna hover
///   outlineVariant          -> border tipis
///   onSurface               -> teks utama
///   onSurfaceVariant        -> teks sekunder
///   outline                 -> teks tersier / placeholder
class AppTheme {
  static const _font = 'Inter';

  static const _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF7F8F8),
    onPrimary: Color(0xFF08090A),
    secondary: Color(0xFF8A8F98),
    onSecondary: Color(0xFF08090A),
    error: Color(0xFFE5484D),
    onError: Color(0xFFF7F8F8),
    surface: Color(0xFF08090A),
    onSurface: Color(0xFFF7F8F8),
    onSurfaceVariant: Color(0xFF8A8F98),
    outline: Color(0xFF62666D),
    outlineVariant: Color(0xFF23252A),
    surfaceContainer: Color(0xFF0F1011),
    surfaceContainerHighest: Color(0xFF17181B),
  );

  static const _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1B1B1F),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF6B6F76),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFD13438),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1B1B1F),
    onSurfaceVariant: Color(0xFF6B6F76),
    outline: Color(0xFF9A9DA3),
    outlineVariant: Color(0xFFE4E4E7),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFF1F1F3),
  );

  static ThemeData get dark => _build(_dark);
  static ThemeData get light => _build(_light);

  /// Angka sejajar (tabular) supaya kolom suhu/persen rapi.
  static const tabular = [FontFeature.tabularFigures()];

  static ThemeData _build(ColorScheme c) {
    TextStyle t(double size, FontWeight w,
            {Color? color, double? height, double? spacing}) =>
        TextStyle(
          fontFamily: _font,
          fontSize: size,
          fontWeight: w,
          color: color ?? c.onSurface,
          height: height,
          letterSpacing: spacing ?? 0,
        );

    final text = TextTheme(
      displayLarge: t(64, FontWeight.w500, height: 1, spacing: -3)
          .copyWith(fontFeatures: tabular),
      headlineSmall: t(20, FontWeight.w600, spacing: -0.3),
      titleMedium: t(14, FontWeight.w500, height: 1.4),
      titleSmall: t(13, FontWeight.w500, height: 1.4),
      bodyLarge: t(15, FontWeight.w400, height: 1.5),
      bodyMedium: t(13, FontWeight.w400, height: 1.5),
      bodySmall: t(12, FontWeight.w400, color: c.onSurfaceVariant, height: 1.4),
      labelLarge: t(13, FontWeight.w500),
      labelMedium: t(12, FontWeight.w500, color: c.onSurfaceVariant),
      labelSmall: t(11, FontWeight.w500, color: c.outline, spacing: 0.4),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: c,
      brightness: c.brightness,
      fontFamily: _font,
      textTheme: text,
      scaffoldBackgroundColor: c.surface,
      canvasColor: c.surface,
      dividerColor: c.outlineVariant,
      hoverColor: c.surfaceContainerHighest,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory, // tanpa efek ripple
      focusColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.onSurface,
        selectionColor: c.onSurface.withValues(alpha: 0.22),
        selectionHandleColor: c.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 48,
        centerTitle: false,
        titleSpacing: 16,
        titleTextStyle: text.titleSmall,
        iconTheme: IconThemeData(color: c.onSurfaceVariant, size: 18),
        systemOverlayStyle: c.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: c.outlineVariant)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.onSurfaceVariant,
          hoverColor: c.surfaceContainerHighest,
          highlightColor: Colors.transparent,
          iconSize: 18,
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.onSurface,
          textStyle: text.labelLarge,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: BorderSide(color: c.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.hovered)
                  ? c.surfaceContainerHighest
                  : Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.onSurfaceVariant,
          textStyle: text.labelMedium,
          minimumSize: const Size(0, 28),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.outlineVariant, thickness: 1, space: 1),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.outlineVariant),
        ),
        textStyle: text.bodySmall?.copyWith(color: c.onSurface),
        waitDuration: const Duration(milliseconds: 400),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.onSurfaceVariant,
        linearTrackColor: c.outlineVariant,
      ),
    );
  }
}
