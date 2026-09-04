import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/activity_item.dart';
import '../../services/profile_service.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';

/// Screen representing Today's Gentle Journey hub.
/// Organizes daily activities along an unpaced garden path motif
/// and adapts based on whether a caregiver is currently present.
class TodaysJourneyScreen extends StatefulWidget {
  const TodaysJourneyScreen({super.key});

  @override
  State<TodaysJourneyScreen> createState() => _TodaysJourneyScreenState();
}

class _TodaysJourneyScreenState extends State<TodaysJourneyScreen> {
  bool _isCaregiverPresent = true;

  @override
  Widget build(BuildContext context) {
    final patient = ProfileService.instance.activeProfile;
    final patientName = patient?.preferredName ?? 'Friend';

    final activities = RecommendationService.instance.getTodaysJourneyActivities(
      isCaregiverPresent: _isCaregiverPresent,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        title: Text(AppStrings.get('todays_journey'), style: AppTypography.patientTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined, color: AppColors.forestPrimary),
            tooltip: 'Caregiver Dashboard',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.caregiverDashboard);
            },
          ),
          IconButton(
            icon: const Icon(Icons.switch_account_outlined, color: AppColors.forestPrimary),
            tooltip: 'Switch Role / Home',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voice Instruction & Warm Greeting Bar
              VoiceInstructionBar(
                instructionText: 'Welcome back, $patientName. Today is peaceful. Let us enjoy gentle activities together.',
              ),
              const SizedBox(height: 20),

              // Caregiver Presence Triage Card
              CalmCard(
                backgroundColor: AppColors.surfaceWarm,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.people_outline, color: AppColors.forestPrimary, size: 26),
                        SizedBox(width: 10),
                        Text(
                          'Is a caregiver with you right now?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'We adjust activities so you can either play together or enjoy relaxing solo moments.',
                      style: AppTypography.caregiverCaption,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPresenceChoice(
                            label: AppStrings.get('yes_together'),
                            icon: Icons.favorite,
                            isSelected: _isCaregiverPresent,
                            onTap: () => setState(() => _isCaregiverPresent = true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildPresenceChoice(
                            label: AppStrings.get('no_independent'),
                            icon: Icons.person,
                            isSelected: !_isCaregiverPresent,
                            onTap: () => setState(() => _isCaregiverPresent = false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Journey Path Header
              Row(
                children: [
                  const Icon(Icons.park_outlined, color: AppColors.sage, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    _isCaregiverPresent ? 'Shared Moments Together' : 'Independent Peaceful Path',
                    style: AppTypography.patientTitle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '3 unhurried activities for today. There are no timers, no grades, and no pressure.',
                style: AppTypography.caregiverBody,
              ),
              const SizedBox(height: 16),

              // Activity Cards
              ...List.generate(activities.length, (index) {
                final activity = activities[index];
                return _buildActivityCard(context, activity, index + 1, activities.length);
              }),

              const SizedBox(height: 20),

              // Shortcuts footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.photo_album_outlined, size: 20, color: AppColors.forestPrimary),
                    label: const Text('Memory Vault', style: TextStyle(color: AppColors.forestPrimary, fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.memoryVault),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.bar_chart, size: 20, color: AppColors.forestPrimary),
                    label: const Text('Activity Trends', style: TextStyle(color: AppColors.forestPrimary, fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.caregiverDashboard),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresenceChoice({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.forestPrimary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem activity, int stepNumber, int totalSteps) {
    return CalmCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Garden path step indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Activity $stepNumber of $totalSteps',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestDark,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activity.themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  activity.modalityBadgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activity.themeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: activity.themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(activity.icon, size: 30, color: activity.themeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.patientFriendlyTitle,
                      style: AppTypography.patientTitle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(activity.subtitle, style: AppTypography.caregiverBody),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Cultural tags chips
          Wrap(
            spacing: 6,
            children: activity.culturalTags
                .map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.surfaceWarm,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          ElderButton(
            label: 'Start Gently',
            icon: Icons.play_arrow,
            variant: ElderButtonVariant.primary,
            height: 52,
            onPressed: () {
              Navigator.of(context).pushNamed(activity.routeName);
            },
          ),
        ],
      ),
    );
  }
}
