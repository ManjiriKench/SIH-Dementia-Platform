import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../services/profile_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';

/// Role selection gateway routing to Caregiver Onboarding or Patient Daily Journey.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  void initState() {
    super.initState();
    ProfileService.instance.addListener(_onProfileUpdated);
  }

  void _onProfileUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ProfileService.instance.removeListener(_onProfileUpdated);
    super.dispose();
  }

  void _handlePatientEntry() {
    final hasProfile = ProfileService.instance.hasProfile;
    if (hasProfile) {
      Navigator.of(context).pushNamed(AppRoutes.todaysJourney);
    } else {
      // Gentle notification explaining profile requirement
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.backgroundWarm,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Profile Setup First', style: AppTypography.patientTitle),
          content: const Text(
            'To ensure activities are safe, comfortable, and familiar, a caregiver should complete a short 5-step profile first.\n\nWould you like to start caregiver setup, or load a sample profile for testing?',
            style: AppTypography.caregiverBody,
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actions: [
            ElderButton(
              label: 'Load Demo Profile (Bonti Baruah)',
              icon: Icons.auto_awesome,
              variant: ElderButtonVariant.peach,
              height: 52,
              onPressed: () {
                Navigator.of(ctx).pop();
                ProfileService.instance.loadProfile(useMock: true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sample profile loaded. You can now explore Patient Mode!'),
                    backgroundColor: AppColors.forestPrimary,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElderButton(
              label: 'Set Up as Caregiver',
              icon: Icons.person_add_alt_1,
              variant: ElderButtonVariant.primary,
              height: 52,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed(AppRoutes.caregiverOnboarding);
              },
            ),
          ],
        ),
      );
    }
  }

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWarm,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 28, color: AppColors.forestPrimary),
                  SizedBox(width: 12),
                  Text('Privacy & Ethical Care', style: AppTypography.caregiverHeading),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Strict Non-Diagnostic Principle',
                style: AppTypography.caregiverSubheading,
              ),
              const SizedBox(height: 4),
              const Text(
                'This application is built for joyful cognitive activity, daily engagement, and family connection. It never diagnoses dementia, evaluates clinical disease stages, predicts cognitive decline, or substitutes medical guidance.',
                style: AppTypography.caregiverBody,
              ),
              const SizedBox(height: 16),
              const Text(
                '2. 100% Offline-First Architecture',
                style: AppTypography.caregiverSubheading,
              ),
              const SizedBox(height: 4),
              const Text(
                'Personalized activities, photos, and music play completely offline on this device. No family photo or observation is sent to cloud servers without explicit caregiver sync action.',
                style: AppTypography.caregiverBody,
              ),
              const SizedBox(height: 16),
              const Text(
                '3. No Stressful Scores or Grading',
                style: AppTypography.caregiverSubheading,
              ),
              const SizedBox(height: 4),
              const Text(
                'Elderly participants will never see numerical scores, red fail markers, speed timers, or competitive rankings. Every interaction is supportive, patient, and unpaced.',
                style: AppTypography.caregiverBody,
              ),
              const SizedBox(height: 24),
              ElderButton(
                label: 'Understood & Agreed',
                onPressed: () => Navigator.of(ctx).pop(),
                variant: ElderButtonVariant.primary,
                height: 54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = ProfileService.instance.hasProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Top Offline Reassurance Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: AppColors.sageDark),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get('offline_note'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Welcome Text
              Text(
                AppStrings.get('app_title'),
                style: AppTypography.patientHero.copyWith(
                  color: AppColors.forestPrimary,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'How would you like to use the app right now?',
                style: AppTypography.patientBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Primary Action: Caregiver
              CalmCard(
                borderColor: AppColors.forestPrimary,
                borderWidth: 1.8,
                padding: const EdgeInsets.all(22),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.caregiverOnboarding);
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.forestPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 34,
                        color: AppColors.forestPrimary,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('role_caregiver'),
                            style: AppTypography.patientTitle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Personalize activities, routines, memories, and view supportive trends.',
                            style: AppTypography.caregiverBody,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.forestPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Secondary Action: Patient
              CalmCard(
                backgroundColor: hasProfile ? Colors.white : AppColors.surfaceWarm.withValues(alpha: 0.6),
                borderColor: hasProfile ? AppColors.sage : AppColors.borderSoft,
                borderWidth: 1.6,
                padding: const EdgeInsets.all(22),
                onTap: _handlePatientEntry,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 34,
                        color: AppColors.sageDark,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('role_patient'),
                            style: AppTypography.patientTitle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasProfile
                                ? 'Start today’s gentle journey with familiar memories.'
                                : 'Requires caregiver profile setup first.',
                            style: AppTypography.caregiverBody,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: hasProfile ? AppColors.sageDark : AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Language switch shortcut
              TextButton.icon(
                icon: const Icon(Icons.language, size: 20, color: AppColors.forestPrimary),
                label: const Text(
                  'Change Language / भाषा / ভাষা',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestPrimary,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.language);
                },
              ),
              // Plain-language privacy link
              TextButton(
                onPressed: _showPrivacySheet,
                child: const Text(
                  'Plain-Language Privacy & Zero Medical Claims Notice',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
