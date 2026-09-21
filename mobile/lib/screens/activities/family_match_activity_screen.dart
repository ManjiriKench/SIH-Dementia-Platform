import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/audio/activity_voice_scripts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
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

class FamilyCardItem {
  final String id;
  final String personName;
  final String relationship;
  final IconData icon;
  final Color themeColor;
  final String memorySnippet;
  bool isFlipped;
  bool isMatched;

  FamilyCardItem({
    required this.id,
    required this.personName,
    required this.relationship,
    required this.icon,
    required this.themeColor,
    required this.memorySnippet,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

/// Cognitive Together Activity 4: Family Match & Tell.
/// Face-down cards with family faces. When a pair is matched, prompts:
/// "Tell me something about them" to spark spontaneous shared warmth.
class FamilyMatchActivityScreen extends StatefulWidget {
  const FamilyMatchActivityScreen({super.key});

  @override
  State<FamilyMatchActivityScreen> createState() => _FamilyMatchActivityScreenState();
}

class _FamilyMatchActivityScreenState extends State<FamilyMatchActivityScreen> {
  int _currentRound = 1;
  final int _totalRounds = 2;
  int _difficultyPairs = 2; // 2 pairs (4 cards) in Round 1, 3 pairs (6 cards) in Round 2
  bool _isProcessingMatch = false;
  int? _firstFlippedIndex;
  int? _hintCardIndex;
  late final GameSafetyManager _safetyManager;

  late List<FamilyCardItem> _cards;

  List<FamilyCardItem> _masterFamilyPool = [];

  final List<FamilyCardItem> _defaultFamilyPool = [
    FamilyCardItem(
      id: 'priyanka',
      personName: 'Priyanka',
      relationship: 'Granddaughter',
      icon: Icons.face_3_rounded,
      themeColor: AppColors.forestPrimary,
      memorySnippet: 'She loves spending evenings hearing your stories and wearing your heirloom silk sari.',
    ),
    FamilyCardItem(
      id: 'aarav',
      personName: 'Aarav',
      relationship: 'Grandson',
      icon: Icons.face_rounded,
      themeColor: AppColors.domainMemory,
      memorySnippet: 'Always asks for your sweet til pithas and loves playing flute music for you.',
    ),
    FamilyCardItem(
      id: 'bhaskar',
      personName: 'Bhaskar',
      relationship: 'Son',
      icon: Icons.person_rounded,
      themeColor: AppColors.peachDark,
      memorySnippet: 'Calls every Sunday morning from Guwahati to check on your morning tea routine.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Family Match & Tell');
    _safetyManager = GameSafetyManager(
      activityTitle: 'Family Match & Tell',
      onEndGameGracefully: _endGameGracefully,
      onAutoSkip: _onSkipPressed,
    );
    _safetyManager.onQuestionStart();
    _loadFamilyPool();
    _setupRound();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.guideSequence(ActivityVoiceScripts.familyMatchIntro);
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
      VoiceAssistantService.instance.guideSequence(ActivityVoiceScripts.familyMatchComplete);
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Family Match & Tell',
          ),
        ),
      );
    }
  }

  void _onSkipPressed() {
    final ended = _safetyManager.handleSkip();
    if (!ended) {
      if (_currentRound < _totalRounds) {
        setState(() {
          _currentRound++;
          _difficultyPairs = 3;
          _setupRound();
        });
      } else {
        _endGameGracefully();
      }
    }
  }

  void _loadFamilyPool() {
    final List<FamilyCardItem> dynamicPool = [];
    final colors = [
      AppColors.forestPrimary,
      AppColors.domainMemory,
      AppColors.peachDark,
      AppColors.domainLanguage,
      AppColors.domainVisuospatial,
    ];
    final icons = [
      Icons.face_3_rounded,
      Icons.face_rounded,
      Icons.person_rounded,
      Icons.sentiment_satisfied_alt_rounded,
      Icons.favorite_rounded,
    ];

    // 1. Try approved person memories from MemoryService
    final personMemories = MemoryService.instance
        .getMemoriesByType(MemoryType.person)
        .where((m) => m.isCaregiverApproved)
        .toList();

    for (int i = 0; i < personMemories.length; i++) {
      final mem = personMemories[i];
      dynamicPool.add(FamilyCardItem(
        id: 'mem_${mem.id}',
        personName: mem.title,
        relationship: mem.relationOrContext ?? 'Family Member',
        icon: icons[i % icons.length],
        themeColor: colors[i % colors.length],
        memorySnippet: mem.tags.isNotEmpty
            ? 'Cherished memory: ${mem.tags.join(", ")}'
            : 'A beloved family member whose love is always with you.',
      ));
    }

    // 2. If fewer than 2, check ProfileService.activeProfile.familiarPeople
    if (dynamicPool.length < 2) {
      final familiarPeople = ProfileService.instance.activeProfile?.familiarPeople ?? [];
      for (int i = 0; i < familiarPeople.length; i++) {
        final personStr = familiarPeople[i];
        String name = personStr;
        String rel = 'Family Member';
        if (personStr.contains('(') && personStr.contains(')')) {
          final parts = personStr.split('(');
          name = parts[0].trim();
          rel = parts[1].replaceAll(')', '').trim();
        }
        final existing = dynamicPool.any((p) => p.personName.toLowerCase() == name.toLowerCase());
        if (!existing) {
          final idx = dynamicPool.length;
          dynamicPool.add(FamilyCardItem(
            id: 'prof_person_$idx',
            personName: name,
            relationship: rel,
            icon: icons[idx % icons.length],
            themeColor: colors[idx % colors.length],
            memorySnippet: 'Always close to heart, bringing warmth and familiar comfort.',
          ));
        }
      }
    }

    // 3. Fallback to default pool if still fewer than 2
    if (dynamicPool.length >= 2) {
      _masterFamilyPool = dynamicPool;
    } else {
      _masterFamilyPool = List.from(_defaultFamilyPool);
    }
  }

  void _setupRound() {
    _firstFlippedIndex = null;
    _hintCardIndex = null;
    _isProcessingMatch = false;

    final availablePairs = _masterFamilyPool.length;
    final pairsCount = _difficultyPairs <= availablePairs ? _difficultyPairs : availablePairs;
    final pool = _masterFamilyPool.take(pairsCount).toList();

    final List<FamilyCardItem> list = [];
    for (final p in pool) {
      // Add two cards for each family member
      list.add(FamilyCardItem(
        id: '${p.id}_a',
        personName: p.personName,
        relationship: p.relationship,
        icon: p.icon,
        themeColor: p.themeColor,
        memorySnippet: p.memorySnippet,
      ));
      list.add(FamilyCardItem(
        id: '${p.id}_b',
        personName: p.personName,
        relationship: p.relationship,
        icon: p.icon,
        themeColor: p.themeColor,
        memorySnippet: p.memorySnippet,
      ));
    }
    list.shuffle();
    _cards = list;
  }

  void _onCardTap(int index) {
    if (_isProcessingMatch) return;
    if (_cards[index].isMatched || _cards[index].isFlipped) return;

    setState(() {
      _cards[index].isFlipped = true;
      _hintCardIndex = null;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.guideSpeak(ActivityVoiceScripts.familyMatchFirstFlip);
      }
    } else {
      // Second card flipped, evaluate match
      _isProcessingMatch = true;
      final first = _cards[_firstFlippedIndex!];
      final second = _cards[index];

      final firstBaseId = first.id.split('_').first;
      final secondBaseId = second.id.split('_').first;

      if (firstBaseId == secondBaseId) {
        // Matched!
        _safetyManager.onAnswerCorrect();
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _isProcessingMatch = false;
          _firstFlippedIndex = null;
        });

        // Show "Tell me something about them" modal
        _showTellMeAboutThemSheet(first);
      } else {
        if (VoiceAssistantService.instance.isGuideMode) {
          VoiceAssistantService.instance.guideSpeak(ActivityVoiceScripts.familyMatchNoMatch);
        }
        // Not matched, flip back gently
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              first.isFlipped = false;
              second.isFlipped = false;
              _firstFlippedIndex = null;
              _isProcessingMatch = false;
            });
          }
        });
      }
    }
  }

  void _showTellMeAboutThemSheet(FamilyCardItem person) {
    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.guideSequence([
        ActivityVoiceScripts.familyMatchOnMatch(person.personName),
        'A warm message from ${person.personName}: "${person.memorySnippet}"',
      ]);
    }

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWarm,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: person.themeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(person.icon, size: 48, color: person.themeColor),
            ),
            const SizedBox(height: 14),
            Text(
              'Tell me something about ${person.personName}',
              style: AppTypography.patientTitle.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              person.relationship,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            CalmCard(
              backgroundColor: AppColors.surfaceWarm,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.favorite, size: 22, color: AppColors.forestPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      person.memorySnippet,
                      style: AppTypography.caregiverBody,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.forestPrimary),
                    tooltip: 'Hear message',
                    onPressed: () {
                      VoiceAssistantService.instance.speak(
                        'A warm message from ${person.personName}: "${person.memorySnippet}"',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElderButton(
              label: 'Keep Playing',
              icon: Icons.check,
              variant: ElderButtonVariant.primary,
              height: 52,
              onPressed: () {
                Navigator.of(ctx).pop();
                _checkAllMatched();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _checkAllMatched() {
    final allMatched = _cards.every((c) => c.isMatched);
    if (allMatched) {
      if (_currentRound < _totalRounds) {
        setState(() {
          _currentRound++;
          _difficultyPairs = 3; // Step up from 2 pairs to 3 pairs gently
          _setupRound();
        });
        _safetyManager.onQuestionStart();
        if (VoiceAssistantService.instance.isGuideMode) {
          VoiceAssistantService.instance.guideSequence(ActivityVoiceScripts.familyMatchRound1Complete);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wonderful! Ready for Round 2 with one more family pair.'),
            backgroundColor: AppColors.forestPrimary,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Complete activity
        SessionService.instance.completeSession();
        if (VoiceAssistantService.instance.isGuideMode) {
          VoiceAssistantService.instance.guideSequence(ActivityVoiceScripts.familyMatchComplete);
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ActivityCompletionScreen(
              activityTitle: 'Family Match & Tell',
            ),
          ),
        );
      }
    }
  }

  void _giveCaregiverHint() {
    SessionService.instance.recordHint();
    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.guideSpeak(ActivityVoiceScripts.familyMatchHint);
    }
    // Find an unmatched pair and highlight one
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isMatched) {
        setState(() {
          _hintCardIndex = i;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hint: Notice ${_cards[i].personName} (${_cards[i].relationship}).'),
            backgroundColor: AppColors.forestPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Text('Family Match & Tell', style: AppTypography.caregiverSubheading),
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
              'Round $_currentRound of $_totalRounds',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.forestDark),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: Column(
            children: [
              const VoiceInstructionBar(
                instructionText: 'Touch any card to turn it over. When you find a pair, tell us something you love about them.',
                autoPlay: false,
              ),
              const SizedBox(height: 16),

              // Card Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isHinted = _hintCardIndex == index;

                    return InkWell(
                      onTap: () => _onCardTap(index),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: card.isFlipped || card.isMatched
                              ? Colors.white
                              : AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: card.isMatched
                                ? AppColors.forestPrimary
                                : (isHinted
                                    ? AppColors.peachDark
                                    : (card.isFlipped
                                        ? card.themeColor
                                        : AppColors.borderSoft)),
                            width: card.isMatched || isHinted ? 2.8 : 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                        child: card.isFlipped || card.isMatched
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: card.themeColor.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(card.icon, size: 40, color: card.themeColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    card.personName,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  Text(
                                    card.relationship,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.spa_rounded, size: 38, color: AppColors.forestPrimary.withValues(alpha: 0.5)),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Touch to Flip',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Caregiver hint & Assistance
              Row(
                children: [
                  Expanded(
                    child: ElderButton(
                      label: 'Caregiver Clue',
                      icon: Icons.lightbulb_outline,
                      variant: ElderButtonVariant.secondary,
                      height: 50,
                      onPressed: _giveCaregiverHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElderButton(
                      label: 'Next Round',
                      icon: Icons.arrow_forward,
                      variant: ElderButtonVariant.secondary,
                      height: 50,
                      onPressed: _checkAllMatched,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: SkipQuestionButton(
                  onSkip: _onSkipPressed,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
