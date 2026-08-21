import 'package:flutter/material.dart';

/// VieGym design-system tokens.
/// Seed hue: HSL(162, 72%, 28%) — deep teal-green for fitness brand.
abstract final class AppColors {
  static const primary = Color(0xFF1A6B52);
  static const primaryContainer = Color(0xFFB7F0D8);
  static const secondary = Color(0xFF2D6A8A);
  static const error = Color(0xFFBA1A1A);
  static const surface = Color(0xFFF6FBF8);
  static const onSurface = Color(0xFF1C1B1F);

  // Dark
  static const primaryDark = Color(0xFF5FD4A6);
  static const surfaceDark = Color(0xFF0F1F19);
  static const onSurfaceDark = Color(0xFFE2E9E5);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    return _buildTheme(cs);
  }

  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    return _buildTheme(cs);
  }

  static ThemeData _buildTheme(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      // ── Typography ────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      // ── FilledButton ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // ── InputDecoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: cs.surfaceContainerLowest,
      ),
      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      // ── BottomNavigationBar / NavigationBar ───────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface);
          }
          return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: cs.onSurfaceVariant);
        }),
      ),
    );
  }
}
