import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/safety/game_safety_manager.dart';
import '../../models/memory_item.dart';
import '../../services/memory_service.dart';
import '../../services/profile_service.dart';
import '../../services/session_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import '../patient_activity/activity_completion_screen.dart';

class FamilyMemberQuestion {
  final String id;
  final String personName;
  final String relationship;
  final String alternateOption;
  final IconData icon;
  final Color themeColor;
  final String memorySnippet;

  FamilyMemberQuestion({
    required this.id,
    required this.personName,
    required this.relationship,
    required this.alternateOption,
    required this.icon,
    required this.themeColor,
    required this.memorySnippet,
  });
}

/// Dementia-friendly Family Photos Together activity:
/// Displays one familiar family portrait card at a time with 2 simple options.
/// Celebrates human effort with warm memory notes from that family member.
class FamilyMatchActivityScreen extends StatefulWidget {
  const FamilyMatchActivityScreen({super.key});

  @override
  State<FamilyMatchActivityScreen> createState() => _FamilyMatchActivityScreenState();
}

class _FamilyMatchActivityScreenState extends State<FamilyMatchActivityScreen> {
  int _currentMemberIndex = 0;
  static const int _totalMembers = 3;

  bool _hasAnswered = false;
  bool _isCorrectChoice = false;
  Timer? _autoAdvanceTimer;

  late final GameSafetyManager _safetyManager;
  List<FamilyMemberQuestion> _familyQuestions = [];

  final List<FamilyMemberQuestion> _defaultQuestions = [
    FamilyMemberQuestion(
      id: 'priyanka',
      personName: 'Priyanka',
      relationship: 'Granddaughter',
      alternateOption: 'Daughter',
      icon: Icons.face_3_rounded,
      themeColor: AppColors.forestPrimary,
      memorySnippet: 'She loves spending evenings hearing your stories and wearing your heirloom silk sari.',
    ),
    FamilyMemberQuestion(
      id: 'aarav',
      personName: 'Aarav',
      relationship: 'Grandson',
      alternateOption: 'Nephew',
      icon: Icons.face_rounded,
      themeColor: AppColors.domainMemory,
      memorySnippet: 'Always asks for your sweet til pithas and loves playing flute music for you.',
    ),
    FamilyMemberQuestion(
      id: 'bhaskar',
      personName: 'Bhaskar',
      relationship: 'Son',
      alternateOption: 'Brother',
      icon: Icons.person_rounded,
      themeColor: AppColors.peachDark,
      memorySnippet: 'Calls every Sunday morning from Guwahati to check on your morning tea routine.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Family Photos Together');
    _safetyManager = GameSafetyManager(
      activityTitle: 'Family Photos Together',
      onEndGameGracefully: _endGameGracefully,
      onAutoSkip: _onSkipPressed,
    );
    _safetyManager.onQuestionStart();
    _loadFamilyQuestions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptCurrentQuestion();
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _safetyManager.dispose();
    super.dispose();
  }

  void _loadFamilyQuestions() {
    final List<FamilyMemberQuestion> dynamicList = [];

    // Try approved person memories from MemoryService
    final personMemories = MemoryService.instance
        .getMemoriesByType(MemoryType.person)
        .where((m) => m.isCaregiverApproved)
        .toList();

    for (final mem in personMemories) {
      final rel = mem.relationOrContext ?? 'Family Member';
      dynamicList.add(FamilyMemberQuestion(
        id: 'mem_${mem.id}',
        personName: mem.title,
        relationship: rel,
        alternateOption: _getAlternateRelationship(rel),
        icon: Icons.face_rounded,
        themeColor: AppColors.forestPrimary,
        memorySnippet: mem.tags.isNotEmpty
            ? 'Cherished memory: ${mem.tags.join(", ")}'
            : 'A beloved family member whose love is always with you.',
      ));
    }

    // Check familiarPeople from activeProfile
    final familiarPeople = ProfileService.instance.activeProfile?.familiarPeople ?? [];
    for (final personStr in familiarPeople) {
      String name = personStr;
      String rel = 'Family Member';
      if (personStr.contains('(') && personStr.contains(')')) {
        final parts = personStr.split('(');
        name = parts[0].trim();
        rel = parts[1].replaceAll(')', '').trim();
      }
      if (!dynamicList.any((m) => m.personName.toLowerCase() == name.toLowerCase())) {
        dynamicList.add(FamilyMemberQuestion(
          id: 'prof_${dynamicList.length}',
          personName: name,
          relationship: rel,
          alternateOption: _getAlternateRelationship(rel),
          icon: Icons.person_rounded,
          themeColor: AppColors.domainMemory,
          memorySnippet: 'Always close to heart, bringing warmth, respect, and familiar comfort.',
        ));
      }
    }

    // Fill remaining with defaults
    for (final def in _defaultQuestions) {
      if (dynamicList.length < _totalMembers &&
          !dynamicList.any((m) => m.personName.toLowerCase() == def.personName.toLowerCase())) {
        dynamicList.add(def);
      }
    }

    _familyQuestions = dynamicList.take(_totalMembers).toList();
    if (_familyQuestions.isEmpty) {
      _familyQuestions = List.from(_defaultQuestions);
    }
  }

  String _getAlternateRelationship(String correctRel) {
    final lower = correctRel.toLowerCase();
    if (lower.contains('daughter')) return 'Granddaughter';
    if (lower.contains('granddaughter')) return 'Daughter';
    if (lower.contains('son')) return 'Brother';
    if (lower.contains('grandson')) return 'Nephew';
    if (lower.contains('sister')) return 'Cousin';
    if (lower.contains('brother')) return 'Son';
    if (lower.contains('husband') || lower.contains('wife')) return 'Friend';
    return 'Family Friend';
  }

  void _promptCurrentQuestion() {
    if (!mounted || _familyQuestions.isEmpty) return;
    final member = _familyQuestions[_currentMemberIndex];

    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.stopSpeaking();
      VoiceAssistantService.instance.guideSpeak(
        'Look at the photo. Who is ${member.personName} to you? Take your time.',
      );
    }
  }

  void _handleOptionSelect(String option) {
    if (_hasAnswered) return;
    _autoAdvanceTimer?.cancel();

    final currentMember = _familyQuestions[_currentMemberIndex];
    final isCorrect = option.toLowerCase() == currentMember.relationship.toLowerCase();

    setState(() {
      _hasAnswered = true;
      _isCorrectChoice = isCorrect;
    });

    _safetyManager.onAnswerCorrect();

    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.stopSpeaking();
      final praise = isCorrect
          ? 'Well done! ${currentMember.personName} is your ${currentMember.relationship}. ${currentMember.memorySnippet}'
          : 'That was close! ${currentMember.personName} is your beloved ${currentMember.relationship}.';
      VoiceAssistantService.instance.guideSpeak(praise);
    }

    // Gentle auto-advance after reading note
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 4200), () {
      if (mounted && _hasAnswered) {
        _goToNextMember();
      }
    });
  }

  void _goToNextMember() {
    _autoAdvanceTimer?.cancel();
    if (_currentMemberIndex < _familyQuestions.length - 1) {
      setState(() {
        _currentMemberIndex++;
        _hasAnswered = false;
        _isCorrectChoice = false;
      });
      _safetyManager.onQuestionStart();
      _promptCurrentQuestion();
    } else {
      _endGameGracefully();
    }
  }

  void _onSkipPressed() {
    _autoAdvanceTimer?.cancel();
    final ended = _safetyManager.handleSkip();
    if (!ended) {
      if (_currentMemberIndex < _familyQuestions.length - 1) {
        _goToNextMember();
      } else {
        _endGameGracefully();
      }
    }
  }

  void _endGameGracefully() {
    _autoAdvanceTimer?.cancel();
    SessionService.instance.completeSession();

    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.stopSpeaking();
      VoiceAssistantService.instance.guideSpeak(
        'Wonderful! You spent a lovely time with your family memories today.',
      );
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Family Photos Together',
            nextActivityTitle: 'Heartfelt Melodies',
            nextRoute: AppRoutes.connectionMusic,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_familyQuestions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentMember = _familyQuestions[_currentMemberIndex];
    final isGuideMode = VoiceAssistantService.instance.isGuideMode;

    // Create 2 options: correct and alternate (ordered deterministically per member)
    final options = currentMember.personName.hashCode % 2 == 1
        ? [currentMember.alternateOption, currentMember.relationship]
        : [currentMember.relationship, currentMember.alternateOption];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const ExitActivityButton(),
        title: const Text('Family Photos Together', style: AppTypography.patientTitle),
        actions: [
          const GuideModeSpeakerBadge(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Voice instruction indicator if guide mode
              if (isGuideMode)
                VoiceInstructionBar(
                  instructionText: 'Who is ${currentMember.personName} to you?',
                  autoPlay: false,
                ),

              const SizedBox(height: 10),

              // 2. Gentle Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Family Member ${_currentMemberIndex + 1} of ${_familyQuestions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestPrimary,
                    ),
                  ),
                  Row(
                    children: List.generate(_familyQuestions.length, (i) {
                      final isPast = i < _currentMemberIndex;
                      final isCurrent = i == _currentMemberIndex;
                      return Container(
                        margin: const EdgeInsets.only(left: 6),
                        width: isCurrent ? 24 : 12,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isPast || isCurrent
                              ? AppColors.forestPrimary
                              : AppColors.borderSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3. Central Family Member Card
              CalmCard(
                padding: const EdgeInsets.all(22),
                backgroundColor: Colors.white,
                borderColor: currentMember.themeColor.withValues(alpha: 0.35),
                borderWidth: 2.0,
                child: Column(
                  children: [
                    // Portrait Avatar Frame
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: currentMember.themeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: currentMember.themeColor.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentMember.themeColor.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        currentMember.icon,
                        size: 64,
                        color: currentMember.themeColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      currentMember.personName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Question prompt
                    Text(
                      'Who is ${currentMember.personName} to you?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // Feedback note once answered
                    if (_hasAnswered) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _isCorrectChoice
                              ? const Color(0xFFE8F5E9)
                              : AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isCorrectChoice
                                ? AppColors.forestPrimary.withValues(alpha: 0.3)
                                : AppColors.peach.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCorrectChoice ? Icons.check_circle : Icons.favorite,
                                  color: _isCorrectChoice
                                      ? AppColors.forestPrimary
                                      : AppColors.peachDark,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${currentMember.personName} is your ${currentMember.relationship}!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: _isCorrectChoice
                                        ? AppColors.forestDark
                                        : AppColors.peachDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '💌 "${currentMember.memorySnippet}"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Two Clear Choice Buttons (or Next Button if answered)
              if (!_hasAnswered) ...[
                const Text(
                  'Choose the relationship:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: options.map((opt) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ElderButton(
                          label: opt,
                          icon: Icons.person_outline,
                          variant: ElderButtonVariant.primary,
                          height: 56,
                          onPressed: () => _handleOptionSelect(opt),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                ElderButton(
                  label: _currentMemberIndex < _familyQuestions.length - 1
                      ? 'Continue to Next Family Member'
                      : 'Complete Family Time',
                  icon: Icons.arrow_forward_rounded,
                  variant: ElderButtonVariant.primary,
                  height: 54,
                  onPressed: _goToNextMember,
                ),
              ],

              const SizedBox(height: 16),

              // 5. Skip Button
              Center(
                child: TextButton.icon(
                  onPressed: _onSkipPressed,
                  icon: const Icon(Icons.skip_next_rounded, color: AppColors.textSecondary, size: 20),
                  label: const Text(
                    'Skip this one gently',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Take all the time you need • There are no wrong answers',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
