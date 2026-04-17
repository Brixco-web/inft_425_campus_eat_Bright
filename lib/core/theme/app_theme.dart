import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Configures the visual identity of Campus Eats based on the "Heritage Lens" system.
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceContainerLowest,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
        onError: AppColors.onError,
      ),

      // 3-Font System Implementation
      textTheme: TextTheme(
        // Epilogue: Headlines for visceral, rooted impact
        displayLarge: GoogleFonts.epilogue(
          fontWeight: FontWeight.w900,
          letterSpacing: -2.0,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.epilogue(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.epilogue(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        
        // Manrope: Precision body text
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.6,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        
        // Space Grotesk: Technical labels and metadata
        labelLarge: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 12,
          color: AppColors.onSurfaceVariant.withOpacity(0.8),
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          fontSize: 10,
          color: AppColors.onSurfaceVariant.withOpacity(0.6),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerHigh.withOpacity(0.6),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        floatingLabelStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryContainer,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
        hintStyle: GoogleFonts.manrope(
          color: AppColors.onSurfaceVariant.withOpacity(0.3),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.epilogue(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

