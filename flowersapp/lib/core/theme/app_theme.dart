import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.accentPink,
      scaffoldBackgroundColor: AppColors.backgroundBeige,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentPink,
        secondary: AppColors.sageGreen,
        background: AppColors.backgroundBeige,
        surface: AppColors.creamPeach,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.darkGrey,
        onSurface: AppColors.darkGrey,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: AppColors.darkGrey,
        displayColor: AppColors.darkGrey,
      ),
      useMaterial3: true,
    );
  }
}
