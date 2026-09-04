import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography configuration tailored for elder accessibility.
/// Meets WCAG AAA contrast standards and ensures 18sp+ readability for patient mode.
class AppTypography {
  AppTypography._();

  // Patient Mode - Large, high-legibility scale
  static const TextStyle patientHero = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.35,
  );

  static const TextStyle patientTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle patientBody = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle patientInstruction = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.forestPrimary,
    letterSpacing: 0.1,
    height: 1.45,
  );

  static const TextStyle patientButton = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  // Caregiver Mode - Information rich yet readable
  static const TextStyle caregiverHeading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle caregiverSubheading = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle caregiverBody = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caregiverCaption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static const TextStyle caregiverChip = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
