import 'package:flutter/material.dart';

/// `docs/design/DESIGN.md` (Stitch, "Sarı Urban Transit") değerlerinden
/// türetilmiş tema. Tasarım değişirse önce DESIGN.md, sonra burası güncellenir.
abstract final class SariColors {
  /// Marka sarısı: çağır butonu, aktif rota, seçili araç sınıfı.
  static const yellow = Color(0xFFFFC800);

  /// Birincil mürekkep: birincil butonlar, ana metin, harita pinleri.
  static const ink = Color(0xFF111111);
  static const inkPressed = Color(0xFF262626);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF2F2F2);
  static const border = Color(0xFFE5E5E5);
  static const textSecondary = Color(0xFF666666);
  static const success = Color(0xFF1DB954);
  static const critical = Color(0xFFE53935);

  /// Kullanıcının haritadaki konumunu gösteren mavi.
  static const userLocation = Color(0xFF2F80ED);
}

abstract final class SariRadius {
  static const sheet = 16.0;
  static const button = 12.0;
  static const badge = 8.0;
}

abstract final class SariSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

const _fontFamily = 'Inter';

TextStyle _style(
  double size,
  FontWeight weight,
  double lineHeight, [
  double letterSpacingEm = 0,
]) => TextStyle(
  fontFamily: _fontFamily,
  fontSize: size,
  fontWeight: weight,
  height: lineHeight / size,
  letterSpacing: letterSpacingEm * size,
);

/// DESIGN.md tipografi ölçeği, Material rollerine eşlenmiş hali.
final sariTextTheme = TextTheme(
  displaySmall: _style(32, FontWeight.w700, 38, -0.02),
  headlineLarge: _style(28, FontWeight.w700, 34, -0.02),
  headlineMedium: _style(24, FontWeight.w700, 30, -0.015),
  headlineSmall: _style(20, FontWeight.w600, 26, -0.01),
  titleMedium: _style(17, FontWeight.w600, 22, -0.005),
  bodyLarge: _style(16, FontWeight.w400, 22),
  bodyMedium: _style(14, FontWeight.w400, 20),
  bodySmall: _style(12, FontWeight.w400, 16),
  labelLarge: _style(16, FontWeight.w600, 20),
  labelMedium: _style(14, FontWeight.w600, 18),
  labelSmall: _style(12, FontWeight.w500, 16),
);

/// Plaka rozetleri için (`34 TKB 82`).
final sariPlateStyle = _style(13, FontWeight.w700, 16, 0.04);

ThemeData buildSariTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF755B00),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: SariColors.yellow,
    onPrimaryContainer: Color(0xFF6E5500),
    secondary: Color(0xFF5F5E5E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE5E2E1),
    onSecondaryContainer: Color(0xFF656464),
    tertiary: Color(0xFF006E2D),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF5DEA7E),
    onTertiaryContainer: Color(0xFF006729),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF9F9F9),
    onSurface: Color(0xFF1A1C1C),
    onSurfaceVariant: Color(0xFF4F4632),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F3F3),
    surfaceContainer: Color(0xFFEEEEEE),
    surfaceContainerHigh: Color(0xFFE8E8E8),
    surfaceContainerHighest: Color(0xFFE2E2E2),
    outline: Color(0xFF81765F),
    outlineVariant: Color(0xFFD2C5AB),
    inverseSurface: Color(0xFF2F3131),
    onInverseSurface: Color(0xFFF1F1F1),
    inversePrimary: Color(0xFFF4BF00),
    surfaceTint: Color(0xFF755B00),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(SariRadius.button),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: _fontFamily,
    textTheme: sariTextTheme.apply(
      bodyColor: SariColors.ink,
      displayColor: SariColors.ink,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    dividerColor: SariColors.border,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SariColors.ink,
        foregroundColor: SariColors.surface,
        minimumSize: const Size.fromHeight(56),
        shape: buttonShape,
        textStyle: sariTextTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SariColors.surfaceSecondary,
      hintStyle: sariTextTheme.bodyLarge?.copyWith(
        color: SariColors.textSecondary,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SariRadius.button),
        borderSide: const BorderSide(color: SariColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SariRadius.button),
        borderSide: const BorderSide(color: SariColors.ink, width: 1.5),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: SariColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SariRadius.sheet),
        ),
      ),
    ),
  );
}
