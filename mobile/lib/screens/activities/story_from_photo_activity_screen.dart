import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/memory_item.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import '../../services/memory_service.dart';
import '../../services/session_service.dart';
import '../patient_activity/activity_completion_screen.dart';

/// Connection Together Activity 3: Story from Photo.
/// Invites the patient and caregiver to co-create or tell a short gentle story
/// inspired by a memory photo. No wrong answers, zero scoring.
class StoryFromPhotoActivityScreen extends StatefulWidget {
  const StoryFromPhotoActivityScreen({super.key});

  @override
  State<StoryFromPhotoActivityScreen> createState() => _StoryFromPhotoActivityScreenState();
}

class _StoryFromPhotoActivityScreenState extends State<StoryFromPhotoActivityScreen> {
  int _currentStoryIndex = 0;
  int _promptStep = 0; // 0: Setting, 1: People & Moments, 2: Feelings
  bool _isSpeaking = false;
  bool _isRecordingVoice = false;
  late List<Map<String, dynamic>> _stories;

  final List<Map<String, dynamic>> _defaultStories = const [
    {
      'title': 'The Green Tea Hills of Assam',
      'photoLabel': 'Morning Sunlight over Dibrugarh Tea Estate',
      'icon': Icons.terrain_rounded,
      'color': AppColors.forestPrimary,
      'bgGradient': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      'storyQuestions': [
        'Imagine stepping into the cool morning mist between the tea bushes. What does the fresh earth smell like?',
        'Look at the workers with their woven baskets. What songs did people sing while plucking the two leaves and a bud?',
        'When you returned home after a walk, what was the first warm drink waiting on the table?',
      ],
      'caregiverCue': 'Let them describe in as much or as little detail as they wish. Validate every word.',
    },
    {
      'title': 'Making Til Pitha on Magh Bihu Morning',
      'photoLabel': 'Clay Fireplace & Sesame Seeds in Tezpur',
      'icon': Icons.fireplace_rounded,
      'color': AppColors.peachDark,
      'bgGradient': [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
      'storyQuestions': [
        'The winter fire crackles softly. What was the secret to rolling the softest rice flour pitha?',
        'Who used to gather around the hearth to taste the first batch with hot tea?',
        'What sweet family laugh or tradition makes you smile when you think of Magh Bihu?',
      ],
      'caregiverCue': 'Remind them gently of relatives or favorite childhood memories.',
    },
    {
      'title': 'Family Gathering on the Veranda Swing',
      'photoLabel': 'Brahmaputra Breeze & Wooden Swing',
      'icon': Icons.chair_rounded,
      'color': AppColors.domainMemory,
      'bgGradient': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
      'storyQuestions': [
        'The gentle back-and-forth rhythm of the wooden swing. Who sat beside you on long summer afternoons?',
        'What stories did the elders tell while the sun began setting over the river ghats?',
        'What is one warm wish you have for the grandchildren today?',
      ],
      'caregiverCue': 'Hold hands if comfortable. Take all the time needed for pauses and quiet smiles.',
    },
  ];

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Story from Photo');
    _initStories();
  }

  void _initStories() {
    final customStories = <Map<String, dynamic>>[];

    // 1. Check for conversation prompt memories
    final promptMemories = MemoryService.instance
        .getMemoriesByType(MemoryType.conversationPrompt)
        .where((m) => m.isCaregiverApproved)
        .toList();

    for (final mem in promptMemories) {
      customStories.add({
        'title': mem.title,
        'photoLabel': mem.relationOrContext ?? 'Cherished Conversation & Memory',
        'icon': Icons.forum_rounded,
        'color': AppColors.forestPrimary,
        'bgGradient': const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        'storyQuestions': mem.tags.isNotEmpty
            ? [
                mem.relationOrContext ?? mem.title,
                'What comes to mind when you recall ${mem.title}?',
                mem.tags.first,
              ]
            : [
                mem.relationOrContext ?? mem.title,
                'Take all your time. What feelings or people does this bring to your heart?',
                'Is there a favorite detail or story you would like to share with us?',
              ],
        'caregiverCue': 'Listen with warmth. Every shared memory is a gift.',
      });
    }

    // 2. Check for photo memories
    final photoMemories = MemoryService.instance
        .getMemoriesByType(MemoryType.photo)
        .where((m) => m.isCaregiverApproved)
        .toList();

    for (final mem in photoMemories) {
      customStories.add({
        'title': mem.title,
        'photoLabel': mem.relationOrContext ?? 'Family Vault Photo',
        'icon': Icons.photo_library_rounded,
        'color': AppColors.domainMemory,
        'bgGradient': const [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        'storyQuestions': [
          mem.relationOrContext != null && mem.relationOrContext!.isNotEmpty
              ? mem.relationOrContext!
              : 'Look closely at this treasured family moment: ${mem.title}.',
          'Who was present on this beautiful day, and what made everyone smile?',
          'What is your favorite feeling when looking back at this time together?',
        ],
        'caregiverCue': 'Point out gentle details in the memory together.',
      });
    }

    if (customStories.isNotEmpty) {
      _stories = [...customStories, ..._defaultStories];
    } else {
      _stories = List.from(_defaultStories);
    }
  }

  void _speakCurrentPrompt(String text) async {
    setState(() => _isSpeaking = true);
    await VoiceAssistantService.instance.speak(text);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _toggleVoiceRecording() {
    setState(() {
      _isRecordingVoice = !_isRecordingVoice;
    });
    if (_isRecordingVoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listening and capturing this gentle story for your family vault...'),
          backgroundColor: AppColors.forestPrimary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _advancePrompt() {
    final story = _stories[_currentStoryIndex];
    final questions = story['storyQuestions'] as List<String>;

    if (_promptStep < questions.length - 1) {
      setState(() {
        _promptStep++;
      });
    } else {
      // Move to next story or finish
      if (_currentStoryIndex < _stories.length - 1) {
        setState(() {
          _currentStoryIndex++;
          _promptStep = 0;
        });
      } else {
        SessionService.instance.completeSession();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ActivityCompletionScreen(
              activityTitle: 'Story from Photo',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_currentStoryIndex];
    final title = story['title'] as String;
    final photoLabel = story['photoLabel'] as String;
    final icon = story['icon'] as IconData;
    final color = story['color'] as Color;
    final bgGradient = story['bgGradient'] as List<Color>;
    final questions = story['storyQuestions'] as List<String>;
    final caregiverCue = story['caregiverCue'] as String;
    final currentQuestion = questions[_promptStep];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWarm,
        elevation: 0,
        leading: const ExitActivityButton(),
        leadingWidth: 160,
        title: const Text('Story from Photo', style: AppTypography.caregiverSubheading),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Text(
              'Story ${_currentStoryIndex + 1} of ${_stories.length}',
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
              const VoiceInstructionBar(
                instructionText: 'Look at the picture together. Share any story, feeling, or memory that comes to mind.',
                autoPlay: false,
              ),
              const SizedBox(height: 16),

              // Visual Illustration Container
              Container(
                height: 220,
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 64, color: color),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: AppTypography.patientTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        photoLabel,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Step Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(questions.length, (i) {
                  final isCurrent = i == _promptStep;
                  final isDone = i < _promptStep;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isCurrent ? 28 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? color
                          : isDone
                              ? color.withValues(alpha: 0.4)
                              : AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Dynamic Story Prompt Card
              CalmCard(
                borderColor: color.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_stories, color: AppColors.forestPrimary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Story Starter (Part ${_promptStep + 1} of ${questions.length})',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.forestDark),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                            color: AppColors.forestPrimary,
                          ),
                          tooltip: 'Speak story question',
                          onPressed: () => _speakCurrentPrompt(currentQuestion),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuestion,
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

              const SizedBox(height: 12),

              // Caregiver Facilitation Tip
              CalmCard(
                backgroundColor: AppColors.surfaceWarm,
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.handshake_outlined, size: 18, color: AppColors.forestPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        caregiverCue,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Simulated Voice Note Option
              OutlinedButton.icon(
                onPressed: _toggleVoiceRecording,
                icon: Icon(_isRecordingVoice ? Icons.mic : Icons.mic_none_rounded, color: _isRecordingVoice ? Colors.red : AppColors.forestPrimary),
                label: Text(
                  _isRecordingVoice ? 'Recording Story (Tap to Save)' : 'Record This Story Audio (Optional)',
                  style: TextStyle(
                    color: _isRecordingVoice ? Colors.red : AppColors.forestPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _isRecordingVoice ? Colors.red : AppColors.borderSoft),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              const SizedBox(height: 16),

              // Next step / Next story action
              ElderButton(
                label: _promptStep < questions.length - 1
                    ? 'Continue This Story'
                    : (_currentStoryIndex < _stories.length - 1 ? 'Next Memory Story' : 'Finish Storytelling'),
                icon: Icons.arrow_forward,
                variant: ElderButtonVariant.primary,
                height: 56,
                onPressed: _advancePrompt,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
