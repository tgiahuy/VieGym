import 'package:flutter/material.dart';

/// VieGym canonical design-system tokens according to AI_RULES.md.
abstract final class AppColors {
  // ── Dark Neutral System (14 steps according to AI_RULES.md) ────────────────
  static const neutral950 = Color(0xFF0B0C0E);
  static const neutral900 = Color(0xFF0F1012);
  static const neutral850 = Color(0xFF131417);
  static const neutral800 = Color(0xFF17181B);
  static const neutral750 = Color(0xFF1C1D21);
  static const neutral700 = Color(0xFF222327);
  static const neutral650 = Color(0xFF292A2F);
  static const neutral600 = Color(0xFF34363B);
  static const neutral500 = Color(0xFF62656B);
  static const neutral400 = Color(0xFF8A8D93);
  static const neutral300 = Color(0xFFA7A9AE);
  static const neutral200 = Color(0xFFC9CBD0);
  static const neutral100 = Color(0xFFE3E4E7);
  static const neutral50 = Color(0xFFF5F5F6);

  // ── Canvas & Surfaces (Semantic Mapping to Dark Neutrals) ──────────────────
  /// Main screen background canvas (neutral900 #0F1012).
  static const background = neutral900;
  static const backgroundPrimary = neutral900;

  /// Deep Background (neutral950 #0B0C0E) for bottom nav, top nav, deep overlays.
  static const backgroundDeep = neutral950;

  /// Secondary Background (neutral850 #131417) for subtle separation, canvas.
  static const backgroundSecondary = neutral850;

  /// Primary Card & Surface (neutral800 #17181B).
  static const surface = neutral800;
  static const surfacePrimary = neutral800;
  static const surfaceDark = neutral900;
  static const surfaceContainer = neutral800;

  /// Elevated Surface (neutral750 #1C1D21) for popups, sheets, elevated cards.
  static const surfaceElevated = neutral750;
  static const surfaceContainerHigh = neutral750;

  /// Surface Strong (neutral700 #222327) for nested cards, inner containers, input fills.
  static const surfaceStrong = neutral700;
  static const surfaceNested = neutral700;
  static const surfaceInput = neutral700;
  static const surfaceContainerHighest = neutral700;

  // ── Borders & Dividers ──────────────────────────────────────────────────────
  /// Default Border (neutral650 #292A2F). Refined 1px card boundary.
  static const border = neutral650;
  static const borderDefault = neutral650;
  static const outlineVariant = neutral650;

  /// Strong Border (neutral600 #34363B) for emphasized boundaries & secondary buttons.
  static const borderStrong = neutral600;
  static const outline = neutral600;

  /// Subtle Border / Divider (neutral700 #222327).
  static const borderSubtle = neutral700;
  static const divider = neutral700;

  // ── Primary Brand Red (Canonical VieGym Red #F2305A) ────────────────────────
  static const primary = Color(0xFFF2305A);
  static const primaryLight = Color(0xFFF4476D);
  static const primaryHighlight = Color(0xFFF4476D);
  static const primaryDark = Color(0xFFD52B50);
  static const primaryHover = Color(0xFFD52B50);
  static const primaryPressed = Color(0xFFC32649);
  static const primarySoft = Color(0x1FF2305A); // ~12% opacity
  static const primaryContainer = Color(0x1FF2305A);
  static const primarySurface = Color(0xFF221318);
  static const primaryBorder = Color(0x40F2305A); // ~25% opacity

  // ── Typography (Mapped to Dark Neutrals) ───────────────────────────────────
  static const textPrimary = neutral50; // #F5F5F6
  static const textSoft = neutral100; // #E3E4E7
  static const textSecondary = neutral300; // #A7A9AE
  static const textMuted = neutral400; // #8A8D93 (WCAG AA compliant)
  static const textTertiary = neutral400; // #8A8D93 (WCAG AA compliant)
  static const textDisabled = neutral600; // #34363B
  static const textInverse = neutral950; // #0B0C0E
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSurface = neutral50;
  static const onSurfaceVariant = neutral300;
  static const onSurfaceDark = Color(0xFFFFFFFF);

  // ── Icons ──────────────────────────────────────────────────────────────────
  static const iconPrimary = neutral50;
  static const iconSecondary = neutral300;
  static const iconTertiary = neutral500;
  static const iconDisabled = neutral600;

  // ── Semantic Colors (Brand Red != Error Red) ────────────────────────────────
  static const success = Color(0xFF35C76F);
  static const successSoft = Color(0x1F35C76F);
  static const successBorder = Color(0x4035C76F);

  static const warning = Color(0xFFF4B740);
  static const warningSoft = Color(0x1FF4B740);
  static const warningBorder = Color(0x40F4B740);

  static const info = Color(0xFF4D8DFF);
  static const infoSoft = Color(0x1F4D8DFF);
  static const infoBorder = Color(0x404D8DFF);

  static const error = Color(0xFFFF5A5F);
  static const errorSoft = Color(0x1FFF5A5F);
  static const errorBorder = Color(0x40FF5A5F);

  // ── Supporting Accent Colors (Fitness-specific) ─────────────────────────────
  // Blue (Information, Fat, Body Metrics, Secondary Stats)
  static const blue = Color(0xFF4D8DFF);
  static const blueSoft = Color(0x1F4D8DFF);
  static const blueBorder = Color(0x404D8DFF);
  static const blueStrong = Color(0xFF2B70E4);
  static const accentBlue = blue;

  // Cyan / Teal (Protein, Recovery, Health Status, Duration, Secondary Fitness Metric)
  static const cyan = Color(0xFF2CC7B5);
  static const cyanSoft = Color(0x1F2CC7B5);
  static const cyanBorder = Color(0x402CC7B5);
  static const cyanStrong = Color(0xFF1EAB9B);
  static const recoveryAccent = cyan;
  static const recoverySoft = cyanSoft;
  static const recoveryBorder = cyanBorder;

  // Green (Success, Completed, Recovered, Goal Achieved)
  static const green = Color(0xFF35C76F);
  static const greenSoft = Color(0x1F35C76F);
  static const greenBorder = Color(0x4035C76F);
  static const greenStrong = Color(0xFF25A859);
  static const accentEmerald = green;

  // Amber (Warning, Approaching Limit, Medium Recovery, PR / Milestone)
  static const amber = Color(0xFFF4B740);
  static const amberSoft = Color(0x1FF4B740);
  static const amberBorder = Color(0x40F4B740);
  static const amberStrong = Color(0xFFD99E28);
  static const accentAmber = amber;

  // Orange (Energy, Streak, Calories Burned - NEVER Primary CTA / Brand)
  static const orange = Color(0xFFF28C38);
  static const orangeSoft = Color(0x1FF28C38);
  static const orangeBorder = Color(0x40F28C38);
  static const orangeStrong = Color(0xFFD67323);
  static const energyAccent = orange;
  static const streakAccent = orange;

  // Violet (AI Coach, Smart Recommendations, Personalized Insight)
  static const violet = Color(0xFF9B7BFF);
  static const violetSoft = Color(0x1F9B7BFF);
  static const violetBorder = Color(0x409B7BFF);
  static const violetStrong = Color(0xFF7E5BE0);
  static const aiAccent = violet;
  static const aiViolet = violet;
  static const aiVioletSoft = violetSoft;
  static const aiVioletBorder = violetBorder;
  static const aiSoft = violetSoft;
  static const aiBorder = violetBorder;
  static const aiStrong = violetStrong;
  static const accentViolet = violet;

  // Pink / Magenta (Special Achievement, Advanced Data - Rare Accent)
  static const pink = Color(0xFFE66BC5);
  static const pinkSoft = Color(0x1FE66BC5);
  static const pinkBorder = Color(0x40E66BC5);
  static const pinkStrong = Color(0xFFC94CA8);

  static const secondary = surfaceElevated;

  // ── Nutrition Macros (100% Consistent Across Project) ───────────────────────
  // Neutral equivalent of #F5F5F5, as permitted by AI_RULES.md §11.2.
  static const nutritionCalories = textPrimary;
  static final nutritionCaloriesSoft = nutritionCalories.withValues(
    alpha: 0.12,
  );
  static const nutritionProtein = cyan;
  static const nutritionProteinSoft = cyanSoft;
  static const nutritionProteinBorder = cyanBorder;
  static const nutritionCarbs = amber;
  static const nutritionCarb = nutritionCarbs;
  static const nutritionCarbsSoft = amberSoft;
  static const nutritionCarbsBorder = amberBorder;
  static const nutritionFat = blue;
  static const nutritionFatSoft = blueSoft;
  static const nutritionFatBorder = blueBorder;
  static const nutritionFiber = green;
  static const nutritionFiberSoft = greenSoft;
  static const nutritionWater = Color(0xFF55B7FF);
  static final nutritionWaterSoft = nutritionWater.withValues(alpha: 0.12);

  // ── Data Visualization Palette (Multi-Series Charts) ───────────────────────
  static const chartPrimary = primary; // #F2305A (Series 1)
  static const chartBlue = blue; // #4D8DFF (Series 2)
  static const chartCyan = cyan; // #2CC7B5
  static const chartGreen = green; // #35C76F
  static const chartAmber = amber; // #F4B740
  static const chartOrange = orange; // #F28C38
  static const chartViolet = violet; // #9B7BFF
  static const chartPink = pink; // #E66BC5

  // ── Muscle Visualization (Monochromatic Red Intensity Scale) ───────────────
  static const musclePrimary = primary; // #F2305A
  static const muscleHighlight = primaryHighlight; // #F4476D
  static const muscleInactive = neutral500; // #62656B
  static const muscleBackground = backgroundDeep; // #0B0C0E
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
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    final cs = generated.copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceElevated,
      surfaceContainerHighest: AppColors.surfaceInput,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.borderDefault,
      error: AppColors.error,
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
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      // ── FilledButton ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: AppColors.onPrimary,
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
          borderSide: BorderSide(color: cs.outlineVariant),
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
        fillColor: cs.surfaceContainerHighest,
      ),
      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      // ── BottomNavigationBar / NavigationBar ───────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.backgroundDeep,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cs.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          );
        }),
      ),
    );
  }
}

/// VieGym canonical border radius tokens according to AI_RULES.md.
abstract final class AppRadius {
  /// Badges, chips, small tags (8px)
  static const double xs = 8;
  static final BorderRadius xsBorderRadius = BorderRadius.circular(xs);

  /// Small buttons, inner nested items (12px)
  static const double sm = 12;
  static final BorderRadius smBorderRadius = BorderRadius.circular(sm);

  /// Standard inputs (14px)
  static const double input = 14;
  static final BorderRadius inputBorderRadius = BorderRadius.circular(input);

  /// Standard buttons, dialogs, bottom sheets (16px)
  static const double md = 16;
  static final BorderRadius mdBorderRadius = BorderRadius.circular(md);

  /// Standard cards according to AI_RULES.md (18px)
  static const double card = 18;
  static final BorderRadius cardBorderRadius = BorderRadius.circular(card);

  /// Large hero cards, prominent containers (20px)
  static const double lg = 20;
  static final BorderRadius lgBorderRadius = BorderRadius.circular(lg);

  /// Full modal sheets, prominent dialogs (24px)
  static const double xl = 24;
  static final BorderRadius xlBorderRadius = BorderRadius.circular(xl);

  /// Pill / Circular
  static const double full = 999;
  static final BorderRadius fullBorderRadius = BorderRadius.circular(full);
}
