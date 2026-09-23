import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Smriti Theme — warm amber sunrise palette.
/// Accessible, familiar, elder-friendly. High contrast, large touch targets.
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
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: AppColors.forestPrimary,
          size: 28,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestPrimary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(64, 48),
          elevation: 3,
          shadowColor: AppColors.forestPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestPrimary,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: AppColors.forestPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.forestPrimary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSoft, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.sageLight,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        side: BorderSide(color: AppColors.borderSoft),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSoft, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSoft, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.forestPrimary, width: 2.5),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }
}
