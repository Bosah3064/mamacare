// ============================================
// MamaCare KE - Design Tokens & Theme
// ============================================
// Warm, Kenyan, calm, trustworthy, professional
// design system for maternal wellbeing.
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MamaCare KE brand colors.
///
/// Inspired by Kenya's warm earth tones, savanna sunsets,
/// and nurturing maternal energy — not generic flag colors.
class MamaCareColors {
  MamaCareColors._();

  // ── Primary: Warm Terracotta Rose ──
  // Evokes warmth, care, maternal energy
  static const Color primary = Color(0xFFD4736E);
  static const Color primaryLight = Color(0xFFF2ABA7);
  static const Color primaryDark = Color(0xFFA8524E);
  static const Color primarySurface = Color(0xFFFFF0EF);

  // ── Secondary: Golden Savanna ──
  // Warmth, optimism, Kenyan sunlight
  static const Color secondary = Color(0xFFE8A54B);
  static const Color secondaryLight = Color(0xFFF5D49A);
  static const Color secondaryDark = Color(0xFFBF8230);
  static const Color secondarySurface = Color(0xFFFFF8ED);

  // ── Accent: Teal Life ──
  // Health, growth, trust
  static const Color accent = Color(0xFF4DAFA5);
  static const Color accentLight = Color(0xFFA0DDD7);
  static const Color accentDark = Color(0xFF2E8A80);
  static const Color accentSurface = Color(0xFFEEF9F7);

  // ── Neutrals ──
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0ED);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8E0DB);

  // ── Text ──
  static const Color textPrimary = Color(0xFF2D2420);
  static const Color textSecondary = Color(0xFF6B5E57);
  static const Color textTertiary = Color(0xFF9C8F88);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF2D2420);

  // ── Semantic ──
  static const Color success = Color(0xFF4CAF6E);
  static const Color successSurface = Color(0xFFEDF7F0);
  static const Color warning = Color(0xFFE8A54B);
  static const Color warningSurface = Color(0xFFFFF8ED);
  static const Color error = Color(0xFFD44B4B);
  static const Color errorSurface = Color(0xFFFDECEC);
  static const Color info = Color(0xFF4D8FAF);
  static const Color infoSurface = Color(0xFFECF4F8);

  // ── Risk Levels (Early Warning) ──
  static const Color riskLow = Color(0xFF4CAF6E);
  static const Color riskModerate = Color(0xFFE8A54B);
  static const Color riskHigh = Color(0xFFE87A4B);
  static const Color riskEmergency = Color(0xFFD44B4B);

  // ── Shimmer ──
  static const Color shimmerBase = Color(0xFFE8E0DB);
  static const Color shimmerHighlight = Color(0xFFF5F0ED);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFE8956F)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF0EF), Color(0xFFFAF7F5)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF6BC4BC)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4736E), Color(0xFFE8A54B)],
  );
}

/// Spacing and sizing tokens.
class MamaCareSpacing {
  MamaCareSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // Touch targets — accessible minimum
  static const double touchTargetMin = 48.0;
  static const double touchTargetLarge = 56.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // Card elevation
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 2.0;
  static const double elevationLg = 4.0;
}

/// Typography using Outfit — modern, clean, highly readable.
class MamaCareTypography {
  MamaCareTypography._();

  static TextStyle get _baseStyle => GoogleFonts.outfit();

  // ── Display ──
  static TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: MamaCareColors.textPrimary,
  );

  static TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: MamaCareColors.textPrimary,
  );

  // ── Headings ──
  static TextStyle headingLarge = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: MamaCareColors.textPrimary,
  );

  static TextStyle headingMedium = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: MamaCareColors.textPrimary,
  );

  static TextStyle headingSmall = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: MamaCareColors.textPrimary,
  );

  // ── Body ──
  static TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: MamaCareColors.textPrimary,
  );

  static TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: MamaCareColors.textSecondary,
  );

  static TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: MamaCareColors.textTertiary,
  );

  // ── Labels ──
  static TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
    color: MamaCareColors.textPrimary,
  );

  static TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.3,
    color: MamaCareColors.textSecondary,
  );

  static TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: MamaCareColors.textTertiary,
  );

  // ── Special ──
  static TextStyle button = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
  );

  static TextStyle caption = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: MamaCareColors.textTertiary,
  );

  static TextStyle weekNumber = _baseStyle.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: MamaCareColors.primary,
  );
}

/// Builds the full Material ThemeData for MamaCare KE.
class MamaCareTheme {
  MamaCareTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: MamaCareColors.primary,
      onPrimary: MamaCareColors.textOnPrimary,
      primaryContainer: MamaCareColors.primarySurface,
      secondary: MamaCareColors.secondary,
      onSecondary: MamaCareColors.textOnSecondary,
      secondaryContainer: MamaCareColors.secondarySurface,
      tertiary: MamaCareColors.accent,
      tertiaryContainer: MamaCareColors.accentSurface,
      surface: MamaCareColors.surface,
      onSurface: MamaCareColors.textPrimary,
      surfaceContainerHighest: MamaCareColors.surfaceVariant,
      error: MamaCareColors.error,
      onError: Colors.white,
      errorContainer: MamaCareColors.errorSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MamaCareColors.background,
      fontFamily: GoogleFonts.outfit().fontFamily,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: MamaCareColors.background,
        foregroundColor: MamaCareColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: MamaCareTypography.headingMedium,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: MamaCareColors.cardBackground,
        elevation: MamaCareSpacing.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusLg),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MamaCareColors.primary,
          foregroundColor: MamaCareColors.textOnPrimary,
          minimumSize: const Size(double.infinity, MamaCareSpacing.touchTargetLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
          ),
          textStyle: MamaCareTypography.button,
          elevation: MamaCareSpacing.elevationSm,
          padding: const EdgeInsets.symmetric(
            horizontal: MamaCareSpacing.xxl,
            vertical: MamaCareSpacing.lg,
          ),
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MamaCareColors.primary,
          minimumSize: const Size(double.infinity, MamaCareSpacing.touchTargetLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
          ),
          side: const BorderSide(color: MamaCareColors.primary, width: 1.5),
          textStyle: MamaCareTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: MamaCareSpacing.xxl,
            vertical: MamaCareSpacing.lg,
          ),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MamaCareColors.primary,
          textStyle: MamaCareTypography.button,
          minimumSize: const Size(48, MamaCareSpacing.touchTargetMin),
        ),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MamaCareColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MamaCareSpacing.lg,
          vertical: MamaCareSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
          borderSide: const BorderSide(color: MamaCareColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
          borderSide: const BorderSide(color: MamaCareColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
          borderSide: const BorderSide(color: MamaCareColors.error, width: 1.5),
        ),
        labelStyle: MamaCareTypography.bodyMedium,
        hintStyle: MamaCareTypography.bodyMedium.copyWith(
          color: MamaCareColors.textTertiary,
        ),
        errorStyle: MamaCareTypography.bodySmall.copyWith(
          color: MamaCareColors.error,
        ),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: MamaCareColors.surface,
        selectedItemColor: MamaCareColors.primary,
        unselectedItemColor: MamaCareColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: MamaCareTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: MamaCareTypography.labelSmall,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: MamaCareColors.surfaceVariant,
        selectedColor: MamaCareColors.primarySurface,
        labelStyle: MamaCareTypography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: MamaCareSpacing.md,
          vertical: MamaCareSpacing.xs,
        ),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: MamaCareColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: MamaCareColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusXl),
        ),
        titleTextStyle: MamaCareTypography.headingSmall,
        contentTextStyle: MamaCareTypography.bodyLarge,
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MamaCareColors.textPrimary,
        contentTextStyle: MamaCareTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MamaCareSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MamaCareColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MamaCareSpacing.radiusXl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: MamaCareColors.divider,
      ),
    );
  }
}
