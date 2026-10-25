import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_dimensions.dart';
export 'app_typography.dart';
export 'glass_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      primaryColor: AppColors.primaryOrange,
      scaffoldBackgroundColor: AppColors.bgWarmAmber,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryOrange,
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryOrangeLight,
        surface: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        titleLarge: AppTypography.screenHeading,
        titleMedium: AppTypography.cardTitleDark,
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textDarkSub,
        ),
        labelLarge: AppTypography.buttonText,
      ),
    );
  }
}
