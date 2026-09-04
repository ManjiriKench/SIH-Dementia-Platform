import 'package:flutter/material.dart';

/// Design tokens for Dementia Support Platform.
/// Palette: Familiar world, modern interface.
/// Calm, warm, non-clinical, high contrast.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundWarm = Color(0xFFFAF7F2); // Warm sand
  static const Color surfaceWarm = Color(0xFFF5EFE6);    // Sand tint
  static const Color cardSurface = Color(0xFFFFFFFF);    // Pure white for crisp cards
  static const Color surfaceElevated = Color(0xFFFFFDF9);// Gentle elevated warm tint

  // Primary Action & Brand
  static const Color forestPrimary = Color(0xFF1B493D);  // Deep forest teal
  static const Color forestDark = Color(0xFF14382E);     // Darker forest for pressed
  static const Color forestLight = Color(0xFF286B5A);    // Hover/highlight forest

  // Calm Progress & Support
  static const Color sage = Color(0xFF5B8A72);           // Calm sage green
  static const Color sageLight = Color(0xFFDCE8E0);      // Very soft sage tint
  static const Color sageDark = Color(0xFF426854);

  // Warm Highlights & Accents
  static const Color peach = Color(0xFFE28B6A);          // Soft peach coral
  static const Color peachLight = Color(0xFFF9E7DF);     // Soft warm peach tint
  static const Color peachDark = Color(0xFFBF6848);

  // Text Colors (High contrast, never pure black)
  static const Color textPrimary = Color(0xFF232B28);    // Deep charcoal
  static const Color textSecondary = Color(0xFF4F5B56);  // Softer readable charcoal
  static const Color textTertiary = Color(0xFF707E79);   // Subtle hint
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // White on dark buttons

  // Neutral Borders & Dividers
  static const Color borderSoft = Color(0xFFE5DDD0);     // Warm border
  static const Color divider = Color(0xFFEDE6DA);

  // States (Gentle, never jarring)
  static const Color successSage = Color(0xFF488463);
  static const Color warningWarm = Color(0xFFD97736);
  static const Color errorGentle = Color(0xFFC05246);
  static const Color infoBlueSoft = Color(0xFF4A7C8C);
  static const Color offlineAmber = Color(0xFFB57C1E);

  // Cognitive Domain Accent Colors (Gentle differentiation)
  static const Color domainMemory = Color(0xFF3B6B7A);       // Calm Slate Blue
  static const Color domainAttention = Color(0xFF5B8A72);    // Sage
  static const Color domainLanguage = Color(0xFF916A8C);     // Muted Plum
  static const Color domainExecutive = Color(0xFF4A6B56);    // Forest Green
  static const Color domainOrientation = Color(0xFFC47F46);  // Warm Ochre
  static const Color domainVisuospatial = Color(0xFF6B728E); // Lavender Grey
}
