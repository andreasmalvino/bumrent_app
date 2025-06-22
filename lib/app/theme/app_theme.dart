import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App theme configuration
class AppTheme {
  /// Get light theme for the app
  static ThemeData get lightTheme {
    return ThemeData(
      // Base colors
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // Set Lato as the default font for the entire app
      fontFamily: GoogleFonts.lato().fontFamily,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: AppColors.shadow,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.buttonText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          textStyle: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.inputFocused, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.lato(color: AppColors.textLight),
        labelStyle: GoogleFonts.lato(color: AppColors.textSecondary),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.buttonDisabled;
          }
          return AppColors.primary;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Text themes
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lato(color: AppColors.textPrimary),
        displayMedium: GoogleFonts.lato(color: AppColors.textPrimary),
        displaySmall: GoogleFonts.lato(color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.lato(color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.lato(color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.lato(color: AppColors.textPrimary),
        titleLarge: GoogleFonts.lato(color: AppColors.textPrimary),
        titleMedium: GoogleFonts.lato(color: AppColors.textPrimary),
        titleSmall: GoogleFonts.lato(color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.lato(color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.lato(color: AppColors.textPrimary),
        bodySmall: GoogleFonts.lato(color: AppColors.textSecondary),
        labelLarge: GoogleFonts.lato(color: AppColors.textPrimary),
        labelMedium: GoogleFonts.lato(color: AppColors.textSecondary),
        labelSmall: GoogleFonts.lato(color: AppColors.textLight),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 16,
      ),

      // Icon theme
      iconTheme: IconThemeData(color: AppColors.iconPrimary, size: 24),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}
