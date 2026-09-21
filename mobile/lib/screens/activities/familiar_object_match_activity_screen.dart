import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/safety/game_safety_manager.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import '../../services/session_service.dart';
import '../patient_activity/activity_completion_screen.dart';

class FamiliarObjectItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  bool isMatched;
  bool isSelected;

  FamiliarObjectItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isMatched = false,
    this.isSelected = false,
  });
}

/// Cognitive Together Activity 6: Familiar Object Match.
/// Match pairs of cherished cultural crafts and everyday natural items.
/// Non-clinical, visual and tactile warmth, supportive hints.
class FamiliarObjectMatchActivityScreen extends StatefulWidget {
  const FamiliarObjectMatchActivityScreen({super.key});

  @override
  State<FamiliarObjectMatchActivityScreen> createState() => _FamiliarObjectMatchActivityScreenState();
}

class _FamiliarObjectMatchActivityScreenState extends State<FamiliarObjectMatchActivityScreen> {
  int _currentRound = 1;
  final int _totalRounds = 2;
  int? _firstSelectedIndex;
  int? _hintIndex;
  bool _isChecking = false;
  String? _feedbackText;
  late final GameSafetyManager _safetyManager;

  final List<FamiliarObjectItem> _masterPool = [
    FamiliarObjectItem(
      id: 'leaf',
      name: 'Tea Leaf',
      description: 'Fresh green tea leaves from the garden.',
      icon: Icons.eco_rounded,
      color: AppColors.forestPrimary,
    ),
    FamiliarObjectItem(
      id: 'diya',
      name: 'Diya Lamp',
      description: 'Golden brass lamp lit for evening prayers.',
      icon: Icons.light_mode_rounded,
      color: AppColors.domainOrientation,
    ),
    FamiliarObjectItem(
      id: 'lotus',
      name: 'Lotus Flower',
      description: 'Pink lotus flower blossoming in the pond.',
      icon: Icons.local_florist_rounded,
      color: AppColors.peachDark,
    ),
    FamiliarObjectItem(
      id: 'bell',
      name: 'Temple Bell',
      description: 'Clear brass bell rung during morning chanting.',
      icon: Icons.notifications_active_rounded,
      color: AppColors.domainLanguage,
    ),
  ];

  late List<FamiliarObjectItem> _cards;

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Familiar Object Match');
    _safetyManager = GameSafetyManager(
      activityTitle: 'Familiar Object Match',
      onEndGameGracefully: _endGameGracefully,
      onAutoSkip: _onSkipPressed,
    );
    _safetyManager.onQuestionStart();
    _setupRound();
  }

  @override
  void dispose() {
    _safetyManager.dispose();
    super.dispose();
  }

  void _endGameGracefully() {
    SessionService.instance.completeSession();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Familiar Object Match',
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
          _setupRound();
        });
      } else {
        _endGameGracefully();
      }
    }
  }

  void _setupRound() {
    _firstSelectedIndex = null;
    _hintIndex = null;
    _isChecking = false;
    _feedbackText = null;

    final count = _currentRound == 1 ? 2 : 3; // 2 pairs (4 cards) in R1, 3 pairs (6 cards) in R2
    final selectedPool = _masterPool.take(count).toList();

    final List<FamiliarObjectItem> list = [];
    for (final obj in selectedPool) {
      list.add(FamiliarObjectItem(
        id: '${obj.id}_1',
        name: obj.name,
        description: obj.description,
        icon: obj.icon,
        color: obj.color,
      ));
      list.add(FamiliarObjectItem(
        id: '${obj.id}_2',
        name: obj.name,
        description: obj.description,
        icon: obj.icon,
        color: obj.color,
      ));
    }
    list.shuffle();
    _cards = list;
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    final card = _cards[index];
    if (card.isMatched || card.isSelected) return;

    setState(() {
      card.isSelected = true;
      _hintIndex = null;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      // Second card tapped
      _isChecking = true;
      final first = _cards[_firstSelectedIndex!];
      final second = card;

      final firstBase = first.id.split('_').first;
      final secondBase = second.id.split('_').first;

      if (firstBase == secondBase) {
        // Matched!
        _safetyManager.onAnswerCorrect();
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          first.isSelected = false;
          second.isSelected = false;
          _firstSelectedIndex = null;
          _isChecking = false;
          _feedbackText = 'Wonderful! You matched the ${first.name}. ${first.description}';
        });

        _checkRoundCompletion();
      } else {
        // Gentle feedback, unhurried delay to notice
        setState(() {
          _feedbackText = 'Take all the time you need. Let’s try again gently.';
        });

        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) {
            setState(() {
              first.isSelected = false;
              second.isSelected = false;
              _firstSelectedIndex = null;
              _isChecking = false;
            });
          }
        });
      }
    }
  }

  void _giveHint() {
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isMatched) {
        setState(() {
          _hintIndex = i;
          _feedbackText = 'Clue: Notice the ${_cards[i].name} with its gentle ${_cards[i].color == AppColors.forestPrimary ? "green" : "golden"} color.';
        });
        break;
      }
    }
  }

  void _checkRoundCompletion() {
    final allMatched = _cards.every((c) => c.isMatched);
    if (allMatched) {
      if (_currentRound < _totalRounds) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _currentRound++;
              _setupRound();
            });
            _safetyManager.onQuestionStart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lovely! Ready for Round 2 with fresh familiar crafts.'),
                backgroundColor: AppColors.forestPrimary,
              ),
            );
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            SessionService.instance.completeSession();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const ActivityCompletionScreen(
                  activityTitle: 'Familiar Object Match',
                ),
              ),
            );
          }
        });
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
          child: Text('Familiar Object Match', style: AppTypography.caregiverSubheading),
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
                instructionText: 'Touch two matching items from nature and traditional crafts.',
                autoPlay: false,
              ),
              const SizedBox(height: 14),

              if (_feedbackText != null) ...[
                CalmCard(
                  backgroundColor: AppColors.surfaceWarm,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, size: 20, color: AppColors.forestPrimary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _feedbackText!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.forestDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Grid of Objects
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _cards.length > 4 ? 3 : 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isHinted = _hintIndex == index;

                    return InkWell(
                      onTap: () => _onCardTap(index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: card.isMatched
                              ? AppColors.sageLight
                              : (card.isSelected ? card.color.withValues(alpha: 0.16) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: card.isMatched
                                ? AppColors.sage
                                : (isHinted
                                    ? AppColors.peachDark
                                    : (card.isSelected ? card.color : AppColors.borderSoft)),
                            width: card.isMatched || card.isSelected || isHinted ? 2.5 : 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(card.icon, size: 44, color: card.color),
                            const SizedBox(height: 8),
                            Text(
                              card.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            if (card.isMatched) ...[
                              const SizedBox(height: 4),
                              const Icon(Icons.check_circle, size: 18, color: AppColors.forestPrimary),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Hint and Assistance Buttons
              Row(
                children: [
                  Expanded(
                    child: ElderButton(
                      label: 'Show a Clue',
                      icon: Icons.lightbulb_outline,
                      variant: ElderButtonVariant.secondary,
                      height: 50,
                      onPressed: _giveHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElderButton(
                      label: 'Continue Gently',
                      icon: Icons.arrow_forward,
                      variant: ElderButtonVariant.secondary,
                      height: 50,
                      onPressed: _checkRoundCompletion,
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
