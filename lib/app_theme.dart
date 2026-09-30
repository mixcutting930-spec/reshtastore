import 'package:flutter/material.dart';

/// App-wide design tokens.
/// Palette moves away from the generic "dating app pink" and leans into
/// something calmer and more deliberate for a nikah/marriage context:
/// deep emerald (trust, tradition) + dusty rose (warmth) on ivory.
///
/// Uses the project's existing bundled fonts (Rubik Medium / Rubik Regular)
/// instead of google_fonts, so no extra dependency or runtime download.
class AppColors {
  static const Color ivory = Color(0xFFFBF6EF);
  static const Color emerald = Color(0xFF1F4741);
  static const Color emeraldDark = Color(0xFF12302C);
  static const Color rose = Color(0xFFC98A7D);
  static const Color roseLight = Color(0xFFEFD9D1);
  static const Color textDark = Color(0xFF241E1A);
  static const Color textMuted = Color(0xFF8A7E76);
  static const Color divider = Color(0xFFE7DED3);
  static const Color error = Color(0xFFB0413E);

  // --- Backward-compatible aliases ---
  // Older screens in this project (e.g. payment_screen.dart) reference
  // these names. Keeping them mapped to the new palette avoids having to
  // rewrite every existing file in one go.
  static const Color primary = emerald;
  static const Color secondary = rose;
  static const Color accent = rose;
  static const Color background = ivory;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
  static const Color success = Color(0xFF3C8B5F);
  static const Color fieldFill = Colors.white;
  static const Color textGrey = textMuted;
}

class AppFonts {
  static const String medium = 'Rubik Medium';
  static const String regular = 'Rubik Regular';
}

class AppTheme {
  static TextTheme get _textTheme => const TextTheme(
        // Headings use Rubik Medium at larger sizes — carries the
        // "considered, confident" personality without needing a second
        // font family.
        displayLarge: TextStyle(
          fontFamily: AppFonts.medium,
          fontSize: 34,
          color: AppColors.textDark,
          height: 1.15,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: AppFonts.medium,
          fontSize: 26,
          color: AppColors.textDark,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppFonts.medium,
          fontSize: 20,
          color: AppColors.textDark,
        ),
        // Body copy uses Rubik Regular for readability at small sizes.
        bodyLarge: TextStyle(
          fontFamily: AppFonts.regular,
          fontSize: 16,
          color: AppColors.textDark,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.regular,
          fontSize: 14,
          color: AppColors.textMuted,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: AppFonts.medium,
          fontSize: 15,
          letterSpacing: 0.1,
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.ivory,
        fontFamily: AppFonts.regular,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          primary: AppColors.emerald,
          secondary: AppColors.rose,
          surface: AppColors.ivory,
          error: AppColors.error,
        ),
        textTheme: _textTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            foregroundColor: AppColors.ivory,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: _textTheme.labelLarge,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.emerald,
            minimumSize: const Size.fromHeight(56),
            side: const BorderSide(color: AppColors.emerald, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: _textTheme.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.emerald, width: 1.6),
          ),
        ),
        dividerColor: AppColors.divider,
      );
}
