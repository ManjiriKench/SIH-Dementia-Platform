import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import 'activity_completion_screen.dart';
import 'activity_session_controller.dart';

/// Reusable Activity Shell hosting any patient-facing cognitive activity.
/// Plugs in with Priyanka's games through ActivitySessionController.
/// Supports Instructions, Start, Play, Correct, Incorrect, Hint,
/// Retry, Pause, Exit, Next-round, and Completion.
class ActivityShellScreen extends StatefulWidget {
  final ActivitySessionController? controller;
  final Widget? customContent;

  const ActivityShellScreen({
    super.key,
    this.controller,
    this.customContent,
  });

  @override
  State<ActivityShellScreen> createState() => _ActivityShellScreenState();
}

class _ActivityShellScreenState extends State<ActivityShellScreen> {
  late ActivitySessionController _controller;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ActivitySessionController(
        activityTitle: 'Familiar Nature Match',
        instructionText: 'Look at the gentle cards and find the matching tea leaves or flowers.',
        hintText: 'Notice the shape of the green tea leaf and golden brass diya.',
      );
      _isControllerInternal = true;
    }
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showPauseDialog() {
    _controller.pause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Activity Paused', style: AppTypography.patientTitle),
        content: const Text(
          'Take a breath and rest for as long as you like. We are right here when you are ready.',
          style: AppTypography.caregiverBody,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          ElderButton(
            label: 'Resume Activity',
            icon: Icons.play_arrow,
            variant: ElderButtonVariant.primary,
            height: 52,
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.resume();
            },
          ),
          const SizedBox(height: 10),
          ElderButton(
            label: 'Finish for Now',
            icon: Icons.home_outlined,
            variant: ElderButtonVariant.secondary,
            height: 52,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
            },
          ),
        ],
      ),
    );
  }

  void _openLifecycleDemoPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWarm,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lifecycle State Inspector', style: AppTypography.caregiverHeading),
            const SizedBox(height: 4),
            const Text('Switch between states to demo full activity lifecycle handling.', style: AppTypography.caregiverCaption),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStateChip(ctx, 'Instructions', ActivityLifecycleState.instructions),
                _buildStateChip(ctx, 'Ready to Start', ActivityLifecycleState.readyToStart),
                _buildStateChip(ctx, 'In Progress', ActivityLifecycleState.inProgress),
                _buildStateChip(ctx, 'Correct Feedback', ActivityLifecycleState.correctFeedback),
                _buildStateChip(ctx, 'Gentle Incorrect', ActivityLifecycleState.incorrectFeedback),
                _buildStateChip(ctx, 'Show Hint', ActivityLifecycleState.hint),
                _buildStateChip(ctx, 'Next Round', ActivityLifecycleState.nextRound),
                _buildStateChip(ctx, 'Completion', ActivityLifecycleState.completed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip(BuildContext ctx, String label, ActivityLifecycleState state) {
    final isCurrent = _controller.state == state;
    return ChoiceChip(
      label: Text(label),
      selected: isCurrent,
      selectedColor: AppColors.forestPrimary,
      labelStyle: TextStyle(
        color: isCurrent ? Colors.white : AppColors.textPrimary,
        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (val) {
        Navigator.of(ctx).pop();
        _controller.setStateDirectly(state);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.state == ActivityLifecycleState.completed) {
      return ActivityCompletionScreen(
        activityTitle: _controller.activityTitle,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        leading: const ExitActivityButton(),
        leadingWidth: 88,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(_controller.activityTitle, style: AppTypography.caregiverSubheading),
        ),
        actions: [
          // Round indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Text(
                'Round ${_controller.currentRound} of ${_controller.totalRounds}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.forestDark),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.pause_circle_outline, color: AppColors.forestPrimary, size: 28),
            tooltip: 'Pause Activity',
            onPressed: _showPauseDialog,
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.forestPrimary),
            tooltip: 'Lifecycle State Inspector',
            onPressed: _openLifecycleDemoPicker,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Voice instruction bar
              VoiceInstructionBar(
                instructionText: _controller.instructionText,
                autoPlay: false,
              ),
              const SizedBox(height: 16),

              // Main Lifecycle Viewport
              Expanded(
                child: _buildLifecycleViewport(),
              ),

              const SizedBox(height: 12),

              // Contextual Footer Controls
              _buildFooterControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifecycleViewport() {
    Widget child;
    switch (_controller.state) {
      case ActivityLifecycleState.instructions:
        child = _buildInstructionsView();
        break;
      case ActivityLifecycleState.readyToStart:
        child = _buildReadyToStartView();
        break;
      case ActivityLifecycleState.inProgress:
        child = widget.customContent ?? _buildDefaultActivityInteractiveViewport();
        break;
      case ActivityLifecycleState.correctFeedback:
        child = _buildCorrectFeedbackView();
        break;
      case ActivityLifecycleState.incorrectFeedback:
        child = _buildIncorrectFeedbackView();
        break;
      case ActivityLifecycleState.hint:
        child = _buildHintView();
        break;
      case ActivityLifecycleState.paused:
        child = _buildPausedPlaceholderView();
        break;
      case ActivityLifecycleState.nextRound:
        child = _buildNextRoundView();
        break;
      case ActivityLifecycleState.completed:
        return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      child: child,
    );
  }

  // State 1: Instructions
  Widget _buildInstructionsView() {
    return Center(
      child: CalmCard(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppColors.surfaceWarm, shape: BoxShape.circle),
              child: const Icon(Icons.lightbulb_outline, size: 48, color: AppColors.forestPrimary),
            ),
            const SizedBox(height: 18),
            const Text('How We Play', style: AppTypography.patientTitle),
            const SizedBox(height: 12),
            Text(
              _controller.instructionText,
              style: AppTypography.patientBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            const Text(
              '• Take all the time you need\n• Tap cards gently to explore\n• There are no wrong answers',
              style: AppTypography.caregiverBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElderButton(
              label: 'I am Ready',
              icon: Icons.play_arrow,
              variant: ElderButtonVariant.primary,
              height: 52,
              onPressed: () => _controller.readyToStart(),
            ),
          ],
        ),
      ),
    );
  }

  // State 2: Ready to Start
  Widget _buildReadyToStartView() {
    return Center(
      child: CalmCard(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppColors.sageLight, shape: BoxShape.circle),
              child: const Icon(Icons.nature_people_outlined, size: 48, color: AppColors.forestPrimary),
            ),
            const SizedBox(height: 18),
            Text('Ready for Round ${_controller.currentRound}?', style: AppTypography.patientTitle),
            const SizedBox(height: 10),
            const Text(
              'Let’s take a peaceful moment to begin. Tap Start whenever you are comfortable.',
              style: AppTypography.caregiverBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElderButton(
              label: 'Start Round',
              icon: Icons.play_arrow,
              variant: ElderButtonVariant.primary,
              height: 54,
              onPressed: () => _controller.startRound(),
            ),
          ],
        ),
      ),
    );
  }

  // State 3: Default Demo Interactive Viewport (Nature Match card simulator)
  Widget _buildDefaultActivityInteractiveViewport() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Touch to Match Familiar Elements',
            style: AppTypography.patientTitle,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDemoMatchCard(Icons.eco, 'Tea Leaf', AppColors.forestPrimary, isSelected: false),
              const SizedBox(width: 16),
              _buildDemoMatchCard(Icons.light_mode, 'Diya Lamp', AppColors.domainOrientation, isSelected: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDemoMatchCard(Icons.local_florist, 'Lotus', AppColors.peach, isSelected: false),
              const SizedBox(width: 16),
              _buildDemoMatchCard(Icons.light_mode, 'Diya Lamp', AppColors.domainOrientation, isSelected: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoMatchCard(IconData icon, String label, Color color, {required bool isSelected}) {
    return InkWell(
      onTap: () {
        if (label == 'Diya Lamp') {
          _controller.triggerCorrectFeedback();
        } else {
          _controller.triggerIncorrectFeedback();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.16) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.borderSoft,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // State 4: Correct Feedback
  Widget _buildCorrectFeedbackView() {
    return Center(
      child: CalmCard(
        backgroundColor: AppColors.sageLight,
        borderColor: AppColors.sage,
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: AppColors.forestDark),
            const SizedBox(height: 16),
            const Text('Wonderful!', style: AppTypography.patientHero),
            const SizedBox(height: 8),
            const Text(
              'You found the matching pair. Lovely noticing!',
              style: AppTypography.patientBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElderButton(
              label: 'Continue to Next Round',
              icon: Icons.arrow_forward,
              variant: ElderButtonVariant.primary,
              height: 52,
              onPressed: () => _controller.advanceRound(),
            ),
          ],
        ),
      ),
    );
  }

  // State 5: Incorrect / Gentle Feedback
  Widget _buildIncorrectFeedbackView() {
    return Center(
      child: CalmCard(
        backgroundColor: AppColors.surfaceWarm,
        borderColor: AppColors.borderSoft,
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_outline, size: 60, color: AppColors.forestPrimary),
            const SizedBox(height: 16),
            const Text("Let's Take Our Time", style: AppTypography.patientTitle),
            const SizedBox(height: 8),
            const Text(
              'No hurry at all. Would you like to try again gently or see a helpful hint?',
              style: AppTypography.patientBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElderButton(
                    label: 'Try Again',
                    icon: Icons.refresh,
                    variant: ElderButtonVariant.primary,
                    height: 50,
                    onPressed: () => _controller.startRound(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElderButton(
                    label: 'See Hint',
                    icon: Icons.lightbulb_outline,
                    variant: ElderButtonVariant.secondary,
                    height: 50,
                    onPressed: () => _controller.showHint(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // State 6: Hint View
  Widget _buildHintView() {
    return Center(
      child: CalmCard(
        backgroundColor: AppColors.peachLight,
        borderColor: AppColors.peach,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb, size: 54, color: AppColors.peachDark),
            const SizedBox(height: 14),
            const Text('Gentle Clue', style: AppTypography.patientTitle),
            const SizedBox(height: 8),
            Text(
              _controller.hintText,
              style: AppTypography.patientBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ElderButton(
              label: 'Back to Activity',
              icon: Icons.arrow_back,
              variant: ElderButtonVariant.primary,
              height: 50,
              onPressed: () => _controller.startRound(),
            ),
          ],
        ),
      ),
    );
  }

  // State 7: Paused Placeholder
  Widget _buildPausedPlaceholderView() {
    return Center(
      child: CalmCard(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle, size: 58, color: AppColors.forestPrimary),
            const SizedBox(height: 16),
            const Text('Session Paused', style: AppTypography.patientTitle),
            const SizedBox(height: 10),
            const Text('Take a restful break. Resume whenever you are ready.', style: AppTypography.caregiverBody, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            ElderButton(
              label: 'Resume Now',
              icon: Icons.play_arrow,
              variant: ElderButtonVariant.primary,
              height: 50,
              onPressed: () => _controller.resume(),
            ),
          ],
        ),
      ),
    );
  }

  // State 8: Next Round
  Widget _buildNextRoundView() {
    return Center(
      child: CalmCard(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppColors.surfaceWarm, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, size: 48, color: AppColors.forestPrimary),
            ),
            const SizedBox(height: 16),
            Text('Round ${_controller.currentRound} of ${_controller.totalRounds}', style: AppTypography.patientHero),
            const SizedBox(height: 8),
            const Text('Fresh cards are ready. Ready for another gentle moment?', style: AppTypography.caregiverBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElderButton(
              label: 'Begin Round',
              icon: Icons.play_arrow,
              variant: ElderButtonVariant.primary,
              height: 52,
              onPressed: () => _controller.startRound(),
            ),
          ],
        ),
      ),
    );
  }

  // Footer controls
  Widget _buildFooterControls() {
    if (_controller.state == ActivityLifecycleState.inProgress) {
      return Row(
        children: [
          Expanded(
            child: ElderButton(
              label: 'Need a Hint?',
              icon: Icons.lightbulb_outline,
              variant: ElderButtonVariant.secondary,
              height: 50,
              onPressed: () => _controller.showHint(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElderButton(
              label: 'Pause & Rest',
              icon: Icons.pause,
              variant: ElderButtonVariant.secondary,
              height: 50,
              onPressed: _showPauseDialog,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
