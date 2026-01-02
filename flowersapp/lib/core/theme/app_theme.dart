import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.accentPink,
      scaffoldBackgroundColor: AppColors.accentPink,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentPink,
        secondary: AppColors.sageGreen,
        background: AppColors.accentPink,
        surface: AppColors.creamPeach,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.primaryText,
        onSurface: AppColors.primaryText,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: AppColors.primaryText,
        displayColor: AppColors.primaryText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.creamPeach,
          foregroundColor: AppColors.primaryText,
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.creamPeach,
        foregroundColor: AppColors.primaryText,
      ),
      useMaterial3: true,
    );
  }
}
