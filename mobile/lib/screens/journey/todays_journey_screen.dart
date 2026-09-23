import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/activity_item.dart';
import '../../services/mock_data_repository.dart';
import '../../services/profile_service.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/language_toggle_widget.dart';

/// Screen representing Today's Experience (Patient Home).
/// Rebuilt with two clear side-by-side columns:
/// 1. With Caregiver (Collaborative & Reminiscence)
/// 2. On My Own (Gentle Independent Cognitive Play)
class TodaysJourneyScreen extends StatefulWidget {
  const TodaysJourneyScreen({super.key});

  @override
  State<TodaysJourneyScreen> createState() => _TodaysJourneyScreenState();
}

class _TodaysJourneyScreenState extends State<TodaysJourneyScreen> {
  @override
  void initState() {
    super.initState();
    RecommendationService.instance.addListener(_onServiceUpdate);
    ProfileService.instance.addListener(_onServiceUpdate);
    VoiceAssistantService.instance.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RecommendationService.instance.removeListener(_onServiceUpdate);
    ProfileService.instance.removeListener(_onServiceUpdate);
    VoiceAssistantService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _launchActivity(ActivityItem activity) {
    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.guideSpeak(
        'Let us begin ${activity.patientFriendlyTitle}. I will be right here with you.',
      );
    }
    Navigator.of(context).pushNamed(activity.routeName);
  }

  void _handleFinishSession() {
    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.guideSpeak(
        'You have done wonderfully today. Rest well and see you tomorrow.',
      );
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWarm,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa, color: AppColors.forestPrimary, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Rest for Today?', style: AppTypography.patientTitle),
            ),
          ],
        ),
        content: const Text(
          'You have spent a wonderful, peaceful moment with us today. Your progress is completely preserved.',
          style: AppTypography.caregiverBody,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          ElderButton(
            label: 'Keep Exploring',
            icon: Icons.play_arrow,
            variant: ElderButtonVariant.primary,
            height: 50,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          const SizedBox(height: 10),
          ElderButton(
            label: 'Finish Session Gently',
            icon: Icons.check_circle_outline,
            variant: ElderButtonVariant.secondary,
            height: 50,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = ProfileService.instance.activeProfile;
    final patientName = patient?.preferredName ?? 'Friend';
    final isGuideMode = VoiceAssistantService.instance.isGuideMode;
    final isNoGame = RecommendationService.instance.isNoGameRecommended;
    final catalog = MockDataRepository.getCatalogActivities();

    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    // Activity groups
    final independentActs = [
      catalog.firstWhere((a) => a.id == 'act_remember_recall'),
      catalog.firstWhere((a) => a.id == 'act_colour_word_focus'),
    ];

    final caregiverActs = [
      catalog.firstWhere((a) => a.id == 'act_family_match'),
      catalog.firstWhere((a) => a.id == 'act_build_the_day'),
      catalog.firstWhere((a) => a.id == 'act_familiar_object_match'),
    ];

    final reminiscenceActs = [
      catalog.firstWhere((a) => a.id == 'act_look_and_talk'),
      catalog.firstWhere((a) => a.id == 'act_music_and_memory'),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(AppStrings.get('todays_journey'), style: AppTypography.patientTitle),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (isGuideMode)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.forestPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.forestPrimary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up_rounded, color: AppColors.forestPrimary, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Voice ON',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestPrimary),
                    ),
                  ],
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(right: 6.0),
            child: LanguageToggleWidget(compact: true),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_outlined, color: AppColors.forestPrimary),
            tooltip: 'Caregiver Dashboard',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.caregiverDashboard);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Greeting Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSoft),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWarm,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.spa_rounded, color: AppColors.forestPrimary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$timeGreeting, $patientName!',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Here is what we have prepared for you today.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rest Day State (No Game Today)
              if (isNoGame) ...[
                CalmCard(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: AppColors.peachLight,
                  borderColor: AppColors.peach,
                  borderWidth: 1.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.spa_rounded, size: 30, color: AppColors.peachDark),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rest & Recharge Today',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.peachDark),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'No structured games scheduled today. A restful walk or gentle music is recommended.',
                                  style: AppTypography.caregiverCaption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ════════════════════════════════════════════════
              // TWO CLEAR SIDE-BY-SIDE COLUMNS
              // ════════════════════════════════════════════════
              LayoutBuilder(
                builder: (context, constraints) {
                  // For compact screens, use responsive row or stacked if extremely narrow
                  final isWide = constraints.maxWidth > 550;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCaregiverColumn(caregiverActs, reminiscenceActs)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildIndependentColumn(independentActs)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCaregiverColumn(caregiverActs, reminiscenceActs),
                            const SizedBox(height: 14),
                            _buildIndependentColumn(independentActs),
                          ],
                        );
                },
              ),

              const SizedBox(height: 18),

              // Quiet Moment / Music Reminiscence Banner
              CalmCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.white,
                borderColor: AppColors.forestPrimary.withValues(alpha: 0.25),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWarm,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.music_note, color: AppColors.forestPrimary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prefer a Quiet Moment?',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Listen to soothing flute melodies or browse familiar photos together.',
                            style: AppTypography.caregiverCaption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.forestPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        backgroundColor: AppColors.surfaceWarm,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.connectionMusic);
                      },
                      child: const Text('Listen', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Finish Session for Today Button
              Center(
                child: ElderButton(
                  label: 'Finish Session for Today',
                  icon: Icons.check_circle_outline,
                  variant: ElderButtonVariant.secondary,
                  height: 52,
                  onPressed: _handleFinishSession,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Left Column: With Caregiver
  Widget _buildCaregiverColumn(List<ActivityItem> collabActs, List<ActivityItem> reminiscenceActs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.forestPrimary, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestPrimary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forestPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, size: 20, color: AppColors.forestPrimary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'With Caregiver',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.forestPrimary),
                    ),
                    Text(
                      'Shared play with hints & warmth',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 12),

          // Sub-section A: Cognitive Together
          const Text(
            'COGNITIVE TOGETHER',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.forestPrimary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          ...collabActs.map((act) => _buildActivityTile(act)),

          const SizedBox(height: 12),
          // Sub-section B: Remember & Connect
          const Text(
            'REMEMBER & CONNECT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.forestPrimary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          ...reminiscenceActs.map((act) => _buildActivityTile(act)),

          const SizedBox(height: 14),
          // Start button for caregiver section
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchActivity(collabActs.first),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Start Together', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  /// Right Column: On My Own
  Widget _buildIndependentColumn(List<ActivityItem> independentActs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.sage, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.sage.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, size: 20, color: AppColors.forestPrimary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On My Own',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Peaceful self-paced play',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 12),

          // Sub-section A: Think & Play
          const Text(
            'THINK & PLAY',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.forestPrimary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          ...independentActs.map((act) => _buildActivityTile(act)),

          const SizedBox(height: 14),
          // Start button for independent section
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchActivity(independentActs.first),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageLight,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20, color: AppColors.textPrimary),
              label: const Text('Start on My Own', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(ActivityItem activity) {
    return InkWell(
      onTap: () => _launchActivity(activity),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity.themeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(activity.icon, size: 18, color: activity.themeColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.patientFriendlyTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    activity.subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
