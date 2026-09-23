import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../services/alert_service.dart';

/// Manages question safety, consecutive skips, 15-minute timeouts, and frustration detection.
class GameSafetyManager {
  final String activityTitle;
  final VoidCallback onEndGameGracefully;
  final VoidCallback? onAutoSkip;

  int _consecutiveSkips = 0;
  Timer? _questionTimer;
  static const Duration questionTimeout = Duration(minutes: 15);

  GameSafetyManager({
    required this.activityTitle,
    required this.onEndGameGracefully,
    this.onAutoSkip,
  });

  int get consecutiveSkips => _consecutiveSkips;

  void onQuestionStart() {
    _questionTimer?.cancel();
    _questionTimer = Timer(questionTimeout, () {
      handleSkip(isAutoTimeout: true);
      onAutoSkip?.call();
    });
  }

  void onAnswerCorrect() {
    _consecutiveSkips = 0;
    _questionTimer?.cancel();
  }

  /// Handles skip logic:
  /// - Increments consecutive skips
  /// - Resets timer
  /// - At 3 skips: speaks gentle reassurance
  /// - At 4 skips: raises alert to caregiver and gracefully completes activity
  bool handleSkip({bool isAutoTimeout = false}) {
    _questionTimer?.cancel();
    _consecutiveSkips++;

    if (_consecutiveSkips >= 4) {
      AlertService.instance.raiseAlert(
        patientId: 'patient_default',
        activityTitle: activityTitle,
        reason: 'Multiple consecutive skips observed ($_consecutiveSkips) — patient may be tired or experiencing hesitation.',
      );
      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.guideSpeak(
          'You have done wonderfully today. Let us take a peaceful rest now.',
        );
      }
      onEndGameGracefully();
      return true; // Game ended
    } else if (_consecutiveSkips == 3) {
      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.guideSpeak(
          'Take a gentle breath. We are in no hurry at all. You are doing great.',
        );
      }
    } else if (isAutoTimeout) {
      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.guideSpeak(
          'Moving gently to the next card. Take all the time you need.',
        );
      }
    }

    return false; // Continue game
  }

  void dispose() {
    _questionTimer?.cancel();
  }
}

/// Subtle "Skip this one" button placed beside actions.
class SkipQuestionButton extends StatelessWidget {
  final VoidCallback onSkip;
  final String label;

  const SkipQuestionButton({
    super.key,
    required this.onSkip,
    this.label = 'Skip this one',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSkip,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fast_forward_rounded, size: 16, color: AppColors.forestPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.forestPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal speaker badge in AppBar indicating that Voice Guide Mode is active.
class GuideModeSpeakerBadge extends StatelessWidget {
  const GuideModeSpeakerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuide = VoiceAssistantService.instance.isGuideMode;
    if (!isGuide) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.forestPrimary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.forestPrimary),
        ),
      ),
    );
  }
}
