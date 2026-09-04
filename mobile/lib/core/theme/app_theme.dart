import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Accessible Theme configuration tailored for elderly users and caregivers.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundWarm,
      primaryColor: AppColors.forestPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestPrimary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.sage,
        onSecondary: Colors.white,
        tertiary: AppColors.peach,
        surface: AppColors.surfaceWarm,
        onSurface: AppColors.textPrimary,
        error: AppColors.errorGentle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundWarm,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.caregiverHeading,
        iconTheme: IconThemeData(
          color: AppColors.forestPrimary,
          size: 28,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestPrimary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 58),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.patientButton,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestPrimary,
          minimumSize: const Size(double.infinity, 58),
          side: const BorderSide(color: AppColors.forestPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.patientButton.copyWith(
            color: AppColors.forestPrimary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSoft, width: 1.2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
