import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Floating or embedded voice instruction bar that speaks text aloud,
/// shows live audio wave indication, and offers a repeat button.
class VoiceInstructionBar extends StatefulWidget {
  final String instructionText;
  final bool autoPlay;

  const VoiceInstructionBar({
    super.key,
    required this.instructionText,
    this.autoPlay = false,
  });

  @override
  State<VoiceInstructionBar> createState() => _VoiceInstructionBarState();
}

class _VoiceInstructionBarState extends State<VoiceInstructionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    VoiceAssistantService.instance.addListener(_handleVoiceUpdate);

    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        VoiceAssistantService.instance.speak(widget.instructionText);
      });
    }
  }

  void _handleVoiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant VoiceInstructionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.instructionText != widget.instructionText && widget.autoPlay) {
      VoiceAssistantService.instance.speak(widget.instructionText);
    }
  }

  @override
  void dispose() {
    VoiceAssistantService.instance.removeListener(_handleVoiceUpdate);
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = VoiceAssistantService.instance.isSpeaking;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isSpeaking ? AppColors.sageLight : AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSpeaking ? AppColors.sage : AppColors.borderSoft,
          width: 1.6,
        ),
      ),
      child: Row(
        children: [
          // Animated Speaker / Sound Button
          Material(
            color: isSpeaking ? AppColors.forestPrimary : Colors.white,
            shape: const CircleBorder(),
            elevation: 1,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                if (isSpeaking) {
                  VoiceAssistantService.instance.stopSpeaking();
                } else {
                  VoiceAssistantService.instance.speak(widget.instructionText);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  isSpeaking ? Icons.volume_up : Icons.volume_down_outlined,
                  color: isSpeaking ? Colors.white : AppColors.forestPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Instruction Subtitle Text
          Expanded(
            child: Text(
              widget.instructionText,
              style: AppTypography.patientInstruction.copyWith(
                color: isSpeaking ? AppColors.forestDark : AppColors.textPrimary,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Replay Button
          IconButton(
            tooltip: 'Replay audio instruction',
            icon: const Icon(Icons.replay, color: AppColors.forestPrimary, size: 26),
            onPressed: () {
              VoiceAssistantService.instance.speak(widget.instructionText);
            },
          ),
        ],
      ),
    );
  }
}
