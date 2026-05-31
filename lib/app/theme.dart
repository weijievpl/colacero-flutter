import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ColaCero Design System v2.0
/// Inspired by Linear, Stripe, Monzo — premium fintech aesthetic
class ColaCeroTheme {
  // Brand palette — deep indigo with warm accent
  static const _seedColor = Color(0xFF4F46E5); // Indigo-600 (deeper than before)
  static const _accentWarm = Color(0xFFF59E0B); // Amber for highlights
  static const _successSoft = Color(0xFF10B981); // Emerald
  static const _dangerSoft = Color(0xFFEF4444); // Red-500

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFFAFAFA), // Warm gray instead of pure white
      onSurface: const Color(0xFF18181B), // Zinc-900
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF4F4F5), // Zinc-100
      surfaceContainerHigh: const Color(0xFFE4E4E7), // Zinc-200
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF09090B), // Zinc-950
      onSurface: const Color(0xFFFAFAFA), // Zinc-50
      surfaceContainerLowest: const Color(0xFF0C0C0E),
      surfaceContainerLow: const Color(0xFF18181B), // Zinc-900
      surfaceContainerHigh: const Color(0xFF27272A), // Zinc-800
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Typography — Inter with refined scale
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 56, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.0),
        displayMedium: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.0, height: 1.1),
        headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
        headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.3),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
        labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        labelMedium: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
      ),

      // AppBar — clean, no elevation, seamless
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3,
          color: colorScheme.onSurface,
        ),
      ),

      // Cards — subtle borders, no shadow, refined radius
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
      ),

      // Filled buttons — pill shape, generous height
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Text fields — clean, spacious
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
            : const Color(0xFFF4F4F5), // Zinc-100
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        prefixIconColor: colorScheme.onSurfaceVariant,
      ),

      // Filter chips — rounded pills
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
      ),

      // Bottom nav — modern bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
          )
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        )),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 72,
      ),

      // Snackbar — floating, rounded
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFF18181B),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      ),

      // Divider — subtle
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Utility colors for consistent usage across pages
  static Color success(BuildContext context) => _successSoft;
  static Color danger(BuildContext context) => _dangerSoft;
  static Color accent(BuildContext context) => _accentWarm;
}
