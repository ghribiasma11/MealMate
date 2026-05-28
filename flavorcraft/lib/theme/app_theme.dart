import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // FlavorCraft Brand Colors
  static const Color primaryGreen = Color(0xFF3CCF91);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color textDark = Color(0xFF2D3436);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softBackground = Color(0xFFF8F9FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color mediumGray = Color(0xFF636E72);
  static const Color lightGray = Color(0xFFDFE6E9);
  static const Color errorRed = Color(0xFFFF6B6B);
  static const Color successGreen = Color(0xFF3CCF91);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardDark = Color(0xFF0F3460);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryGreen,
      onPrimary: pureWhite,
      primaryContainer: primaryGreen.withValues(alpha: 0.12),
      onPrimaryContainer: textDark,
      secondary: accentOrange,
      onSecondary: pureWhite,
      secondaryContainer: accentOrange.withValues(alpha: 0.12),
      onSecondaryContainer: textDark,
      tertiary: primaryGreen,
      onTertiary: pureWhite,
      tertiaryContainer: primaryGreen.withValues(alpha: 0.08),
      onTertiaryContainer: textDark,
      error: errorRed,
      onError: pureWhite,
      surface: pureWhite,
      onSurface: textDark,
      onSurfaceVariant: mediumGray,
      outline: lightGray,
      outlineVariant: lightGray.withValues(alpha: 0.5),
      shadow: const Color(0x1A000000),
      scrim: const Color(0x1A000000),
      inverseSurface: textDark,
      onInverseSurface: pureWhite,
      inversePrimary: primaryGreen.withValues(alpha: 0.8),
    ),
    scaffoldBackgroundColor: softBackground,
    cardColor: cardWhite,
    dividerColor: lightGray,
    appBarTheme: AppBarThemeData(
      backgroundColor: pureWhite,
      foregroundColor: textDark,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: textDark, size: 24),
    ),
    cardTheme: CardThemeData(
      color: cardWhite,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: pureWhite,
      selectedItemColor: primaryGreen,
      unselectedItemColor: mediumGray,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentOrange,
      foregroundColor: pureWhite,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: pureWhite,
        backgroundColor: primaryGreen,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: primaryGreen, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: softBackground,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: lightGray, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: lightGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: GoogleFonts.dmSans(
        color: mediumGray,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.dmSans(
        color: mediumGray.withValues(alpha: 0.6),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryGreen;
        return mediumGray;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryGreen.withValues(alpha: 0.3);
        }
        return lightGray;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryGreen;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(pureWhite),
      side: const BorderSide(color: lightGray, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: softBackground,
      selectedColor: primaryGreen.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: lightGray),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryGreen,
      onPrimary: pureWhite,
      primaryContainer: primaryGreen.withValues(alpha: 0.2),
      onPrimaryContainer: pureWhite,
      secondary: accentOrange,
      onSecondary: pureWhite,
      secondaryContainer: accentOrange.withValues(alpha: 0.2),
      onSecondaryContainer: pureWhite,
      tertiary: primaryGreen,
      onTertiary: pureWhite,
      tertiaryContainer: primaryGreen.withValues(alpha: 0.15),
      onTertiaryContainer: pureWhite,
      error: errorRed,
      onError: pureWhite,
      surface: surfaceDark,
      onSurface: pureWhite,
      onSurfaceVariant: const Color(0xFFB2BEC3),
      outline: const Color(0xFF4A5568),
      outlineVariant: const Color(0xFF2D3748),
      shadow: const Color(0x33000000),
      scrim: const Color(0x33000000),
      inverseSurface: pureWhite,
      onInverseSurface: textDark,
      inversePrimary: primaryGreen,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: surfaceDark,
    dividerColor: const Color(0xFF2D3748),
    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceDark,
      foregroundColor: pureWhite,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: pureWhite,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: pureWhite, size: 24),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: cardDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: GoogleFonts.dmSans(
        color: const Color(0xFFB2BEC3),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.dmSans(
        color: const Color(0xFFB2BEC3).withValues(alpha: 0.6),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryGreen;
        return const Color(0xFFB2BEC3);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryGreen.withValues(alpha: 0.3);
        }
        return const Color(0xFF4A5568);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark,
      selectedColor: primaryGreen.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: pureWhite,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF4A5568)),
      ),
    ),
  );

  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color primaryText = isLight ? textDark : pureWhite;
    final Color secondaryText = isLight ? mediumGray : const Color(0xFFB2BEC3);

    return TextTheme(
      displayLarge: GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryText,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryText,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryText,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
    );
  }
}
