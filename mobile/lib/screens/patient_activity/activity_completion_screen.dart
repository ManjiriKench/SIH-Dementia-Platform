import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/safety/game_safety_manager.dart';
import '../../services/session_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';

/// Reusable session / activity completion screen for patient experiences.
/// Celebrates human effort, connection, and calm engagement without numerical scores.
/// Features a gentle 10-second floating caregiver feedback banner.
class ActivityCompletionScreen extends StatefulWidget {
  final String activityTitle;
  final Duration? durationSpent;
  final VoidCallback? onNextActivity;
  final VoidCallback? onFinishSession;
  final String? nextActivityTitle;
  final String? nextRoute;

  const ActivityCompletionScreen({
    super.key,
    this.activityTitle = 'Familiar Activity',
    this.durationSpent,
    this.onNextActivity,
    this.onFinishSession,
    this.nextActivityTitle,
    this.nextRoute,
  });

  @override
  State<ActivityCompletionScreen> createState() => _ActivityCompletionScreenState();
}

class _ActivityCompletionScreenState extends State<ActivityCompletionScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 10;
  bool _showFeedbackFloat = false;
  bool _floatDismissed = false;
  bool _voiceSpoken = false;

  @override
  void initState() {
    super.initState();
    _initCompletionFlow();
  }

  void _initCompletionFlow() {
    // 1. Show feedback float after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted || _floatDismissed) return;
      setState(() {
        _showFeedbackFloat = true;
      });
      _startCountdown();
    });

    // 2. Speak calm positive reinforcement in Guide Mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_voiceSpoken && mounted) {
        _voiceSpoken = true;
        final title = widget.activityTitle;
        if (VoiceAssistantService.instance.isGuideMode) {
          VoiceAssistantService.instance.speak(
            'Wonderful effort today with $title. If a caregiver is present, please tap Submit Feedback to help us adapt tomorrow’s session.',
          );
        }
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _showFeedbackFloat = false;
          _floatDismissed = true;
        });
      }
    });
  }

  void _dismissFloat() {
    _countdownTimer?.cancel();
    setState(() {
      _showFeedbackFloat = false;
      _floatDismissed = true;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read route arguments if present
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = routeArgs?['activityTitle'] as String? ?? widget.activityTitle;
    final duration = widget.durationSpent ??
        (routeArgs?['duration'] as Duration?) ??
        SessionService.instance.lastCompletedSession?.sessionDuration;

    String? durationFormatted;
    if (duration != null && duration.inSeconds > 0) {
      if (duration.inMinutes >= 1) {
        final mins = duration.inMinutes;
        final secs = duration.inSeconds % 60;
        durationFormatted = secs > 0 ? '$mins min $secs sec' : '$mins min';
      } else {
        durationFormatted = '${duration.inSeconds} seconds';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWarm,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [
          GuideModeSpeakerBadge(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Calm Celebration Floral Icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.sage, width: 2),
                    ),
                    child: const Icon(
                      Icons.spa,
                      size: 48,
                      color: AppColors.forestPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Wonderful Effort Today!',
                    style: AppTypography.patientHero,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'You spent a gentle, peaceful moment with $title. Every moment shared together brings warmth and familiarity.',
                    style: AppTypography.patientBody.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (durationFormatted != null) ...[
                    const SizedBox(height: 14),
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
                          const Icon(Icons.schedule_rounded, size: 18, color: AppColors.forestPrimary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Time Spent: $durationFormatted',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Non-medical affirmation card
                  CalmCard(
                    backgroundColor: AppColors.surfaceWarm,
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite_outline, color: AppColors.forestPrimary, size: 26),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Your progress is saved safely. No rush, no scores — just peaceful connection.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forestDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Play Next Activity
                  ElderButton(
                    label: widget.nextActivityTitle != null
                        ? 'Play Next: ${widget.nextActivityTitle}'
                        : 'Play Next Activity',
                    icon: Icons.play_arrow_rounded,
                    variant: ElderButtonVariant.primary,
                    height: 56,
                    onPressed: widget.onNextActivity ??
                        () {
                          _countdownTimer?.cancel();
                          if (widget.nextRoute != null) {
                            Navigator.of(context).pushReplacementNamed(widget.nextRoute!);
                          } else {
                            Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
                          }
                        },
                  ),
                  const SizedBox(height: 12),

                  // End Session
                  ElderButton(
                    label: 'End Session for Today',
                    icon: Icons.nightlight_round,
                    variant: ElderButtonVariant.secondary,
                    height: 54,
                    onPressed: widget.onFinishSession ??
                        () async {
                          _countdownTimer?.cancel();
                          if (VoiceAssistantService.instance.isGuideMode) {
                            await VoiceAssistantService.instance.speak('Great work today. See you tomorrow.');
                          }
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.roleSelection,
                              (route) => false,
                            );
                          }
                        },
                  ),
                  const SizedBox(height: 90), // Spacing for possible floating banner
                ],
              ),
            ),

            // Floating 10-Second Caregiver Feedback Banner
            if (_showFeedbackFloat && !_floatDismissed)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _showFeedbackFloat ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Material(
                    elevation: 6,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.surfaceWarm,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.forestPrimary, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.sageLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: AppColors.forestPrimary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Caregiver Feedback',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.forestDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.peachLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_secondsRemaining}s',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.forestPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _dismissFloat,
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'If a caregiver is here, share a 30-second observation to help adapt upcoming activities.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _countdownTimer?.cancel();
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.caregiverFeedback,
                                      arguments: {'activityTitle': title},
                                    );
                                    _dismissFloat();
                                  },
                                  icon: const Icon(Icons.edit_note, size: 18),
                                  label: const Text('Submit Observation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.forestPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _dismissFloat,
                                child: const Text('Dismiss', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
