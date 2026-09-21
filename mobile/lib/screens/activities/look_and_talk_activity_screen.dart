import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/audio/activity_voice_scripts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/safety/game_safety_manager.dart';
import '../../models/memory_item.dart';
import '../../services/memory_service.dart';
import '../../services/session_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import '../patient_activity/activity_completion_screen.dart';

/// Connection Together Activity 1: Look & Talk.
/// Focuses purely on warm shared connection, reminiscence, and conversation.
/// Strictly non-diagnostic: no scores, no right/wrong answers, no memory tests.
class LookAndTalkActivityScreen extends StatefulWidget {
  const LookAndTalkActivityScreen({super.key});

  @override
  State<LookAndTalkActivityScreen> createState() => _LookAndTalkActivityScreenState();
}

class _LookAndTalkActivityScreenState extends State<LookAndTalkActivityScreen> {
  int _currentIndex = 0;
  bool _isSpeaking = false;
  late final GameSafetyManager _safetyManager;

  final List<Map<String, dynamic>> _demoPhotos = [
    {
      'title': 'Grandmother’s Veranda in Tezpur',
      'location': 'Tezpur, Assam',
      'icon': Icons.deck_rounded,
      'color': AppColors.forestPrimary,
      'bgGradient': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      'prompt': 'Do you remember the morning breeze on this veranda, and sipping hot ginger tea?',
      'caregiverNote': 'Ask about the garden flowers or what birds used to visit in the morning.',
      'tag': 'Morning Routine & Comfort',
    },
    {
      'title': 'Priyanka’s College Graduation Day',
      'location': 'Guwahati University',
      'icon': Icons.school_rounded,
      'color': AppColors.domainMemory,
      'bgGradient': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
      'prompt': 'Look at Priyanka in her golden muga silk sari. What was everyone celebrating that afternoon?',
      'caregiverNote': 'Notice her smile and celebrate the family milestone together.',
      'tag': 'Family Milestone',
    },
    {
      'title': 'Rolling Sweet Til Pitha for Magh Bihu',
      'location': 'Home Kitchen, Tezpur',
      'icon': Icons.rice_bowl_rounded,
      'color': AppColors.peachDark,
      'bgGradient': [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
      'prompt': 'The aroma of roasted sesame and warm jaggery! Who loved making the pithas first?',
      'caregiverNote': 'Talk about the warmth of the winter kitchen and festive family gatherings.',
      'tag': 'Festive Tradition',
    },
    {
      'title': 'Sunset at the Brahmaputra River Ghat',
      'location': 'Brahmaputra Bank, Tezpur',
      'icon': Icons.water_rounded,
      'color': AppColors.domainOrientation,
      'bgGradient': [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
      'prompt': 'The gentle sound of flowing river water as the golden sun dips behind the hills.',
      'caregiverNote': 'Ask how the cool evening breeze felt after a warm day.',
      'tag': 'Nature & Peace',
    },
  ];

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Look & Talk');
    _safetyManager = GameSafetyManager(
      activityTitle: 'Look & Talk',
      onEndGameGracefully: _endGameGracefully,
      onAutoSkip: _nextPhoto,
    );
    _safetyManager.onQuestionStart();

    // Pre-populate with any personal photos from memory vault if available
    final personalPhotos = MemoryService.instance.getMemoriesByType(MemoryType.photo);
    if (personalPhotos.isNotEmpty) {
      for (final p in personalPhotos) {
        _demoPhotos.insert(0, {
          'title': p.title,
          'location': p.relationOrContext,
          'icon': Icons.photo_library_rounded,
          'color': AppColors.forestPrimary,
          'bgGradient': [const Color(0xFFF1F8E9), const Color(0xFFDCEDC8)],
          'prompt': 'What feelings or memories come to mind when you look at ${p.title}?',
          'caregiverNote': 'Listen gently to any story shared, without asking for factual accuracy.',
          'tag': 'Personal Vault Memory',
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (VoiceAssistantService.instance.isGuideMode && _demoPhotos.isNotEmpty) {
        VoiceAssistantService.instance.guideSequence([
          ...ActivityVoiceScripts.lookAndTalkIntro,
          ActivityVoiceScripts.lookAndTalkPhotoAppeared(_demoPhotos[0]['title'] as String),
          _demoPhotos[0]['prompt'] as String,
        ]);
      }
    });
  }

  @override
  void dispose() {
    _safetyManager.dispose();
    super.dispose();
  }

  void _endGameGracefully() {
    SessionService.instance.completeSession();
    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.guideSequence(ActivityVoiceScripts.lookAndTalkComplete);
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Look & Talk',
          ),
        ),
      );
    }
  }

  void _onSkipPressed() {
    final ended = _safetyManager.handleSkip();
    if (!ended) {
      _nextPhoto();
    }
  }

  void _speakPrompt(String text) async {
    setState(() => _isSpeaking = true);
    await VoiceAssistantService.instance.speak(text);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _nextPhoto() {
    if (_currentIndex < _demoPhotos.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _safetyManager.onQuestionStart();
      if (VoiceAssistantService.instance.isGuideMode) {
        final next = _demoPhotos[_currentIndex];
        VoiceAssistantService.instance.guideSequence([
          ActivityVoiceScripts.lookAndTalkBetweenPhotos,
          ActivityVoiceScripts.lookAndTalkPhotoAppeared(next['title'] as String),
          next['prompt'] as String,
        ]);
      }
    } else {
      // Completed all photos peacefully
      SessionService.instance.completeSession();
      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.guideSequence(ActivityVoiceScripts.lookAndTalkComplete);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Look & Talk',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _demoPhotos[_currentIndex];
    final title = current['title'] as String;
    final location = current['location'] as String;
    final icon = current['icon'] as IconData;
    final color = current['color'] as Color;
    final bgGradient = current['bgGradient'] as List<Color>;
    final prompt = current['prompt'] as String;
    final caregiverNote = current['caregiverNote'] as String;
    final tag = current['tag'] as String;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWarm,
        elevation: 0,
        leading: const ExitActivityButton(),
        leadingWidth: 88,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('Look & Talk', style: AppTypography.caregiverSubheading),
        ),
        actions: [
          const GuideModeSpeakerBadge(),
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Text(
              'Photo ${_currentIndex + 1} of ${_demoPhotos.length}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.forestDark),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Voice instruction
              const VoiceInstructionBar(
                instructionText: 'Look at this photo together. Talk about whatever feels warm and familiar.',
                autoPlay: false,
              ),
              const SizedBox(height: 16),

              // Large Familiar Photo Display
              Container(
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bgGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 68, color: color),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            title,
                            style: AppTypography.patientTitle.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location,
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Conversation Prompt Card with voice button
              CalmCard(
                borderColor: AppColors.forestPrimary.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: AppColors.forestPrimary, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Conversation Starter',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.forestDark),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                            color: AppColors.forestPrimary,
                          ),
                          tooltip: 'Listen to prompt',
                          onPressed: () => _speakPrompt(prompt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt,
                      style: AppTypography.patientBody.copyWith(
                        fontSize: 17,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Caregiver Facilitation Hint
              CalmCard(
                backgroundColor: AppColors.surfaceWarm,
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite, size: 18, color: AppColors.forestPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        caregiverNote,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              ElderButton(
                label: _currentIndex < _demoPhotos.length - 1 ? 'Next Cherished Photo' : 'Finish with Warmth',
                icon: Icons.arrow_forward,
                variant: ElderButtonVariant.primary,
                height: 56,
                onPressed: _nextPhoto,
              ),

              const SizedBox(height: 12),

              Center(
                child: SkipQuestionButton(
                  onSkip: _onSkipPressed,
                  label: 'Skip this photo',
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.feedback_outlined, size: 18, color: AppColors.forestPrimary),
                  label: const Text(
                    'Record Caregiver Observation for this session',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.forestPrimary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.caregiverFeedback);
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
