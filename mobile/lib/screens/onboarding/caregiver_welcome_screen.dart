  import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_routes.dart';
import '../../services/profile_service.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/language_toggle_widget.dart';
import '../../widgets/common/voice_companion_bubble.dart';

/// Warm, welcoming caregiver intro.
/// No clutter. A single heartfelt message, three simple bullets, one big button.
class CaregiverWelcomeScreen extends StatelessWidget {
  const CaregiverWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back to splash navigation and language toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestPrimary, size: 28),
                    tooltip: 'Back to Smriti Start',
                    onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.science_outlined, color: AppColors.forestPrimary, size: 26),
                        tooltip: 'AI & Backend Diagnostics',
                        onPressed: () => Navigator.of(context).pushNamed('/backend_test'),
                      ),
                      const SizedBox(width: 4),
                      const LanguageToggleWidget(compact: true),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // Smriti lotus icon — tapping takes back to the app name & logo splash screen
                    Tooltip(
                      message: 'Back to Smriti Start',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.splash),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWarm,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.forestPrimary.withValues(alpha: 0.35),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.forestPrimary.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            size: 44,
                            color: AppColors.forestPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ASTEYA co-branding badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.forestPrimary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.eco_rounded, size: 12, color: AppColors.forestPrimary),
                          const SizedBox(width: 5),
                          Text(
                            'AN ASTEYA INITIATIVE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: AppColors.forestDark.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.peachLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.peach.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        AppStrings.get('caregiver_welcome_badge'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Title
                    Text(
                      AppStrings.get('caregiver_welcome_title'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 14),

                    // Description — warm, human, not clinical
                    Text(
                      AppStrings.get('caregiver_welcome_desc'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Voice Companion Guide Mode Banner
                    const VoiceCompanionBubble(
                      contextualHint:
                          'Namaskar! Welcome to Smriti. I am your spoken companion. If you enable Voice Guide, I will read every question aloud, give hints, and celebrate your loved one throughout their journey.',
                    ),

                    const SizedBox(height: 20),

                    // Three benefit bullets in a warm card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderSoft,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestPrimary.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('caregiver_why_title'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBullet(Icons.music_note_rounded, AppStrings.get('caregiver_why_1')),
                          const SizedBox(height: 14),
                          _buildBullet(Icons.self_improvement_rounded, AppStrings.get('caregiver_why_2')),
                          const SizedBox(height: 14),
                          _buildBullet(Icons.local_hospital_outlined, AppStrings.get('caregiver_why_3')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Big primary button
                    ElderButton(
                      label: AppStrings.get('start_profile_btn'),
                      icon: Icons.arrow_forward_rounded,
                      variant: ElderButtonVariant.primary,
                      height: 62,
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.roleSelection);
                      },
                    ),

                    const SizedBox(height: 18),

                    // Demo option — not hidden, but secondary
                    GestureDetector(
                      onTap: () {
                        ProfileService.instance.loadProfile(useMock: true);
                        Navigator.of(context).pushReplacementNamed(AppRoutes.domainOverview);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 20,
                              color: AppColors.forestPrimary,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                AppStrings.get('load_demo_btn'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.forestPrimary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
