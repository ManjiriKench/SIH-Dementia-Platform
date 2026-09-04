import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/ai_recommendation.dart';
import '../../services/profile_service.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';

/// Screen simulating the AI profile-processing lifecycle and handling
/// all 6 required states: Preparing, Personalizing, Ready, Delayed Offline, Failed, and Insufficient Info.
class AiProcessingScreen extends StatefulWidget {
  const AiProcessingScreen({super.key});

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen> {
  @override
  void initState() {
    super.initState();
    RecommendationService.instance.addListener(_onServiceUpdate);
    _startAiSynthesis();
  }

  @override
  void dispose() {
    RecommendationService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _startAiSynthesis({AiProcessingStatus targetStatus = AiProcessingStatus.ready}) {
    final patient = ProfileService.instance.activeProfile;
    final patientId = patient?.id ?? 'patient_default';
    RecommendationService.instance.simulateAiAnalysis(
      patientId: patientId,
      targetFinalStatus: targetStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rec = RecommendationService.instance.currentRecommendation;
    final status = rec?.status ?? AiProcessingStatus.preparing;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        title: const Text('Personalizing Experience', style: AppTypography.caregiverHeading),
        actions: [
          // Testing / Evaluation menu to demonstrate all 6 states required by the specification
          PopupMenuButton<AiProcessingStatus>(
            icon: const Icon(Icons.science_outlined, color: AppColors.forestPrimary),
            tooltip: 'Simulate AI States (Evaluation Tool)',
            onSelected: (newStatus) => _startAiSynthesis(targetStatus: newStatus),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AiProcessingStatus.ready,
                child: Text('Simulate: Ready (Full Success)'),
              ),
              const PopupMenuItem(
                value: AiProcessingStatus.delayedOffline,
                child: Text('Simulate: Offline Delayed'),
              ),
              const PopupMenuItem(
                value: AiProcessingStatus.insufficientInfo,
                child: Text('Simulate: Insufficient Details'),
              ),
              const PopupMenuItem(
                value: AiProcessingStatus.failed,
                child: Text('Simulate: Recoverable Error / Retry'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: _buildContentForStatus(status, rec),
        ),
      ),
    );
  }

  Widget _buildContentForStatus(AiProcessingStatus status, AiRecommendation? rec) {
    switch (status) {
      case AiProcessingStatus.preparing:
        return _buildPreparingState();
      case AiProcessingStatus.personalizing:
        return _buildPersonalizingState();
      case AiProcessingStatus.ready:
        return _buildReadyState(rec);
      case AiProcessingStatus.delayedOffline:
        return _buildDelayedOfflineState(rec);
      case AiProcessingStatus.insufficientInfo:
        return _buildInsufficientInfoState();
      case AiProcessingStatus.failed:
        return _buildFailedState();
    }
  }

  // State 1: Preparing profile
  Widget _buildPreparingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestPrimary),
          ),
        ),
        const SizedBox(height: 32),
        const Text('Organizing Profile Information', style: AppTypography.patientTitle, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text(
          'Synthesizing comfortable pace, preferred language, and daily routine anchors...',
          style: AppTypography.caregiverBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        _buildInfluenceProgressCard(
          icon: Icons.checklist_rtl_outlined,
          title: 'Reading baseline abilities & support needs',
          isDone: true,
        ),
        const SizedBox(height: 12),
        _buildInfluenceProgressCard(
          icon: Icons.music_note_outlined,
          title: 'Matching cultural music & familiar traditions',
          isDone: false,
        ),
      ],
    );
  }

  // State 2: Personalizing activities
  Widget _buildPersonalizingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage),
          ),
        ),
        const SizedBox(height: 32),
        const Text('Curating Gentle Activities', style: AppTypography.patientTitle, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text(
          'Aligning morning tea rhythms and regional memories with the 6 cognitive domains...',
          style: AppTypography.caregiverBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        _buildInfluenceProgressCard(
          icon: Icons.checklist_rtl_outlined,
          title: 'Reading baseline abilities & support needs',
          isDone: true,
        ),
        const SizedBox(height: 12),
        _buildInfluenceProgressCard(
          icon: Icons.music_note_outlined,
          title: 'Matching cultural music & familiar traditions',
          isDone: true,
        ),
      ],
    );
  }

  Widget _buildInfluenceProgressCard({required IconData icon, required String title, required bool isDone}) {
    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.hourglass_top_outlined,
            color: isDone ? AppColors.sage : AppColors.forestPrimary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // State 3: Ready (Recommendations prepared)
  Widget _buildReadyState(AiRecommendation? rec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.sage.withValues(alpha: 0.5), width: 1.4),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.forestDark, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendations Ready',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.forestDark),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Personalized for comfort, unhurried pace, and familiar cultural anchors.',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('What Shaped Today’s Plan?', style: AppTypography.caregiverHeading),
        const SizedBox(height: 8),
        const Text(
          'Our personalization engine strictly optimizes for engagement and comfort, never clinical diagnosis.',
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 16),
        ...((rec?.reasoningInfluences ?? [
          'Assam tea culture & gardening affinity',
          'Morning time preference (9 AM - 11 AM)',
          'Preference for large text & soothing audio',
        ]).map((inf) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 20, color: AppColors.forestPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(inf, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ))),
        const SizedBox(height: 32),
        ElderButton(
          label: 'View 6-Domain Support Overview',
          icon: Icons.dashboard_outlined,
          variant: ElderButtonVariant.primary,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.domainOverview);
          },
        ),
      ],
    );
  }

  // State 4: Delayed Offline
  Widget _buildDelayedOfflineState(AiRecommendation? rec) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.cloud_off, size: 68, color: AppColors.offlineAmber),
        const SizedBox(height: 20),
        const Text('Profile Saved Locally', style: AppTypography.patientTitle, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text(
          'Your profile is saved safely on this phone. We will use your information locally and update cloud recommendations when internet is available.',
          style: AppTypography.caregiverBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        ElderButton(
          label: 'Continue with Local Activities',
          icon: Icons.play_arrow,
          variant: ElderButtonVariant.primary,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
          },
        ),
      ],
    );
  }

  // State 5: Insufficient Information
  Widget _buildInsufficientInfoState() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.info_outline, size: 68, color: AppColors.peachDark),
        const SizedBox(height: 20),
        const Text('More Details Will Help Personalize', style: AppTypography.patientTitle, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text(
          'Sharing favorite songs or morning routine anchors helps us create more comforting activities. In the meantime, safe starter activities are ready.',
          style: AppTypography.caregiverBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        ElderButton(
          label: 'Add More Details',
          icon: Icons.edit_note,
          variant: ElderButtonVariant.primary,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.caregiverOnboarding);
          },
        ),
        const SizedBox(height: 12),
        ElderButton(
          label: 'Play Safe Starter Activities',
          variant: ElderButtonVariant.secondary,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
          },
        ),
      ],
    );
  }

  // State 6: Failed with safe recovery
  Widget _buildFailedState() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.sync_problem, size: 68, color: AppColors.errorGentle),
        const SizedBox(height: 20),
        const Text('Personalization Was Interrupted', style: AppTypography.patientTitle, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text(
          'All your profile data is preserved safely. You can retry synthesis or proceed directly with gentle starter activities.',
          style: AppTypography.caregiverBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        ElderButton(
          label: 'Retry Personalization',
          icon: Icons.refresh,
          variant: ElderButtonVariant.primary,
          onPressed: () => _startAiSynthesis(targetStatus: AiProcessingStatus.ready),
        ),
        const SizedBox(height: 12),
        ElderButton(
          label: 'Continue with Starter Activities',
          variant: ElderButtonVariant.secondary,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
          },
        ),
      ],
    );
  }
}
