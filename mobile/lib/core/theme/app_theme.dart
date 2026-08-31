import 'package:flutter/material.dart';

/// VieGym design-system tokens.
/// Native Flutter interpretation of the React VieGym design tokens.
abstract final class AppColors {
  static const primary = Color(0xFFFF2E54);
  static const primaryContainer = Color(0xFF3B121A);
  static const secondary = Color(0xFF232838);
  static const error = Color(0xFFFF4D6D);
  static const surface = Color(0xFF0A0C14);
  static const onSurface = Color(0xFFF6F7FB);

  // Dark & Neon
  static const primaryDark = Color(0xFFFF2E54);
  static const surfaceDark = Color(0xFF0A0C14);
  static const onSurfaceDark = Color(0xFFF6F7FB);
  static const accentEmerald = Color(0xFF10B981);
  static const accentAmber = Color(0xFFF59E0B);
  static const accentBlue = Color(0xFF3B82F6);
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
    final generated = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
    );
    final cs = generated.copyWith(
      primary: AppColors.primaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainer: const Color(0xFF141724),
      surfaceContainerHigh: const Color(0xFF1B1F30),
      surfaceContainerHighest: const Color(0xFF252A40),
      outlineVariant: const Color(0xFF282E44),
    );
    return _buildTheme(cs);
  }

  static ThemeData _buildTheme(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      splashFactory: InkSparkle.splashFactory,
      highlightColor: cs.primary.withValues(alpha: 0.12),
      splashColor: cs.primary.withValues(alpha: 0.20),
      // ── IconButton ────────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          highlightColor: cs.primary.withValues(alpha: 0.15),
          splashFactory: InkSparkle.splashFactory,
        ),
      ),
      // ── Typography ────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      // ── FilledButton ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      // ── InputDecoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: cs.surfaceContainer,
      ),
      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 0,
      ),
      // ── BottomNavigationBar / NavigationBar ───────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        indicatorColor: cs.primary.withValues(alpha: .22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cs.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
          );
        }),
      ),
    );
  }
}
