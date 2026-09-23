import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';

/// Floating or embedded Voice Companion Bubble.
/// Gives patients and caregivers a direct, visual connection to the Voice Assistant:
/// - Pulsing wave ring when speaking
/// - Tap to repeat current message or pause
/// - Toggle Guide Mode (auto-narration for every step without tapping)
/// - Prominent warm badge indicating Guide Mode status
class VoiceCompanionBubble extends StatefulWidget {
  final String? contextualHint;
  final bool compact;
  final VoidCallback? onModeChanged;

  const VoiceCompanionBubble({
    super.key,
    this.contextualHint,
    this.compact = false,
    this.onModeChanged,
  });

  @override
  State<VoiceCompanionBubble> createState() => _VoiceCompanionBubbleState();
}

class _VoiceCompanionBubbleState extends State<VoiceCompanionBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    VoiceAssistantService.instance.addListener(_onVoiceUpdate);
  }

  void _onVoiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    VoiceAssistantService.instance.removeListener(_onVoiceUpdate);
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final service = VoiceAssistantService.instance;
    if (service.isSpeaking) {
      service.stopSpeaking();
    } else {
      if (widget.contextualHint != null && widget.contextualHint!.isNotEmpty) {
        service.speak(widget.contextualHint!);
      } else if (service.isGuideMode) {
        service.speak('I am here with you. Take all the time you need.');
      } else {
        service.speak(
          'Hello! Tap and hold to enable Voice Guide, and I will read and guide you through everything automatically.',
        );
      }
    }
  }

  void _handleLongPress() {
    final service = VoiceAssistantService.instance;
    service.toggleGuideMode();
    widget.onModeChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          service.isGuideMode
              ? 'Voice Guide Mode ON — Narrating everything automatically'
              : 'Voice Guide Mode OFF — Tap anytime you want voice assistance',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor:
            service.isGuideMode ? AppColors.successSage : AppColors.forestPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = VoiceAssistantService.instance;
    final isSpeaking = service.isSpeaking;
    final isGuide = service.isGuideMode;

    if (widget.compact) {
      return _buildCompactBubble(isSpeaking, isGuide);
    }

    return _buildExpandedCard(isSpeaking, isGuide);
  }

  Widget _buildCompactBubble(bool isSpeaking, bool isGuide) {
    return Semantics(
      label: isGuide
          ? 'Voice companion active. Long press to turn off voice guide.'
          : 'Voice companion. Tap to hear guide or long press to turn on voice guide.',
      button: true,
      child: Tooltip(
        message: isGuide ? 'Voice Guide ON' : 'Voice Guide (Tap to hear)',
        child: GestureDetector(
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = isSpeaking ? _pulseAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isGuide ? AppColors.peachLight : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isGuide ? AppColors.forestPrimary : AppColors.borderSoft,
                      width: isGuide ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isGuide ? AppColors.forestPrimary : Colors.black)
                            .withValues(alpha: 0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isSpeaking)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.peach.withValues(alpha: 0.3),
                              ),
                            ),
                          Icon(
                            isSpeaking
                                ? Icons.volume_up_rounded
                                : (isGuide
                                    ? Icons.record_voice_over_rounded
                                    : Icons.volume_down_rounded),
                            size: 18,
                            color: AppColors.forestPrimary,
                          ),
                        ],
                      ),
                      if (isGuide) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.successSage,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCard(bool isSpeaking, bool isGuide) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isGuide ? const Color(0xFFFEF3C7) : AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGuide ? AppColors.forestPrimary : AppColors.borderSoft,
          width: isGuide ? 2.0 : 1.2,
        ),
      ),
      child: Row(
        children: [
          // Avatar / Icon Button
          GestureDetector(
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final scale = isSpeaking ? _pulseAnimation.value : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSpeaking
                          ? AppColors.forestPrimary
                          : (isGuide
                              ? AppColors.peach
                              : AppColors.surfaceElevated),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isSpeaking ? AppColors.forestPrimary : Colors.black)
                              .withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isSpeaking
                          ? Icons.volume_up_rounded
                          : (isGuide
                              ? Icons.record_voice_over_rounded
                              : Icons.hearing_rounded),
                      color: isSpeaking ? Colors.white : AppColors.forestDark,
                      size: 26,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          // Information Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Voice Companion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isGuide
                            ? AppColors.successSage.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isGuide
                                  ? AppColors.successSage
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isGuide ? 'Active' : 'Standby',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isGuide
                                  ? AppColors.successSage
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isSpeaking
                      ? 'Speaking now... Tap circle to pause'
                      : (isGuide
                          ? 'Auto-guiding every step. Sit back and enjoy.'
                          : 'Turn on Guide Mode to narrate without tapping.'),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Toggle Switch
          Switch(
            value: isGuide,
            activeThumbColor: AppColors.forestPrimary,
            activeTrackColor: AppColors.peachLight,
            onChanged: (val) {
              VoiceAssistantService.instance.setGuideMode(val);
              widget.onModeChanged?.call();
            },
          ),
        ],
      ),
    );
  }
}
