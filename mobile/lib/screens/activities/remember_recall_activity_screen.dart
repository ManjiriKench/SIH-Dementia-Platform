import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import '../../services/profile_service.dart';
import '../../services/session_service.dart';
import '../patient_activity/activity_completion_screen.dart';

enum RecallPhase { memorize, recall, feedback }

class RecallItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const RecallItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Independent Cognitive Activity 7: Remember & Recall.
/// Unhurried observation phase with no countdown timer pressure,
/// followed by calm selection from familiar items.
class RememberRecallActivityScreen extends StatefulWidget {
  const RememberRecallActivityScreen({super.key});

  @override
  State<RememberRecallActivityScreen> createState() => _RememberRecallActivityScreenState();
}

class _RememberRecallActivityScreenState extends State<RememberRecallActivityScreen> {
  int _currentRound = 1;
  final int _totalRounds = 2;
  RecallPhase _phase = RecallPhase.memorize;
  final Set<String> _selectedItemIds = {};

  final List<RecallItem> _defaultPool = const [
    RecallItem(id: 'kettle', name: 'Assam Chai Kettle', icon: Icons.emoji_food_beverage_rounded, color: AppColors.domainExecutive),
    RecallItem(id: 'glasses', name: 'Reading Glasses', icon: Icons.visibility_rounded, color: AppColors.domainMemory),
    RecallItem(id: 'bell', name: 'Brass Prayer Bell', icon: Icons.notifications_active_rounded, color: AppColors.domainLanguage),
    RecallItem(id: 'clock', name: 'Grandfather Clock', icon: Icons.access_time_rounded, color: AppColors.domainOrientation),
    RecallItem(id: 'book', name: 'Poetry Book', icon: Icons.menu_book_rounded, color: AppColors.forestPrimary),
    RecallItem(id: 'plant', name: 'Tulsi Plant', icon: Icons.eco_rounded, color: AppColors.sageDark),
  ];

  late List<RecallItem> _activePool;
  late List<RecallItem> _targetItems;
  late List<RecallItem> _choiceItems;

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Remember & Recall');
    _initPool();
    _setupRound();
  }

  void _initPool() {
    final profile = ProfileService.instance.activeProfile;
    final familiarItems = <RecallItem>[];

    if (profile != null) {
      final foodsAndPlaces = [
        ...profile.familiarPlacesAndFoods,
        ...profile.familiarPlaces,
      ].where((s) => s.trim().isNotEmpty).toSet().toList();

      for (int i = 0; i < foodsAndPlaces.length; i++) {
        final name = foodsAndPlaces[i];
        final lower = name.toLowerCase();
        IconData icon = Icons.star_rounded;
        Color col = AppColors.domainMemory;

        if (lower.contains('tea') || lower.contains('chai') || lower.contains('kettle')) {
          icon = Icons.emoji_food_beverage_rounded;
          col = AppColors.domainExecutive;
        } else if (lower.contains('pitha') || lower.contains('food') || lower.contains('fish') || lower.contains('rice') || lower.contains('tenga')) {
          icon = Icons.restaurant_rounded;
          col = AppColors.peachDark;
        } else if (lower.contains('veranda') || lower.contains('swing') || lower.contains('garden')) {
          icon = Icons.chair_rounded;
          col = AppColors.forestPrimary;
        } else if (lower.contains('ghat') || lower.contains('river') || lower.contains('temple') || lower.contains('tezpur') || lower.contains('guwahati')) {
          icon = Icons.place_rounded;
          col = AppColors.domainOrientation;
        }

        familiarItems.add(RecallItem(
          id: 'custom_$i',
          name: name,
          icon: icon,
          color: col,
        ));
      }
    }

    if (familiarItems.length >= 2) {
      _activePool = [...familiarItems, ..._defaultPool];
    } else {
      _activePool = List.from(_defaultPool);
    }
  }

  void _setupRound() {
    _phase = RecallPhase.memorize;
    _selectedItemIds.clear();

    if (_currentRound == 1) {
      _targetItems = [_activePool[0], _activePool[1]];
      _choiceItems = [
        _activePool[0],
        _activePool[1],
        _activePool[2 % _activePool.length],
        _activePool[3 % _activePool.length],
      ];
    } else {
      _targetItems = [
        _activePool[2 % _activePool.length],
        _activePool[3 % _activePool.length],
        _activePool[4 % _activePool.length],
      ];
      _choiceItems = [
        _activePool[1 % _activePool.length],
        _activePool[2 % _activePool.length],
        _activePool[3 % _activePool.length],
        _activePool[4 % _activePool.length],
        _activePool[5 % _activePool.length],
      ];
    }
    _choiceItems = List<RecallItem>.from(_choiceItems.toSet())..shuffle();
  }

  void _transitionToRecall() {
    setState(() {
      _phase = RecallPhase.recall;
    });
  }

  void _toggleChoice(String id) {
    if (_phase != RecallPhase.recall) return;
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  void _submitRecall() {
    setState(() {
      _phase = RecallPhase.feedback;
    });
  }

  void _retryMemorize() {
    setState(() {
      _phase = RecallPhase.memorize;
      _selectedItemIds.clear();
    });
  }

  void _advanceToNextRoundOrComplete() {
    if (_currentRound < _totalRounds) {
      setState(() {
        _currentRound++;
        _setupRound();
      });
    } else {
      SessionService.instance.completeSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Remember & Recall',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allTargetsFound = _targetItems.every((t) => _selectedItemIds.contains(t.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWarm,
        elevation: 0,
        leading: const ExitActivityButton(),
        leadingWidth: 160,
        title: const Text('Remember & Recall', style: AppTypography.caregiverSubheading),
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
              'Round $_currentRound of $_totalRounds',
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
              VoiceInstructionBar(
                instructionText: _phase == RecallPhase.memorize
                    ? 'Look at these gentle items calmly. When you feel comfortable, tap "I am Ready".'
                    : (_phase == RecallPhase.recall
                        ? 'Which items did you see a moment ago? Tap on them gently.'
                        : 'Wonderful noticing! Take a peaceful breath.'),
                autoPlay: false,
              ),
              const SizedBox(height: 18),

              // Phase 1: Memorize
              if (_phase == RecallPhase.memorize) ...[
                const Text(
                  'Take all the time you need to look at these items:',
                  style: AppTypography.patientTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _targetItems.map((item) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: item.color.withValues(alpha: 0.35), width: 2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(item.icon, size: 54, color: item.color),
                            const SizedBox(height: 12),
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 36),

                ElderButton(
                  label: 'I am Ready to Recall',
                  icon: Icons.check_circle_outline,
                  variant: ElderButtonVariant.primary,
                  height: 56,
                  onPressed: _transitionToRecall,
                ),
              ],

              // Phase 2: Recall
              if (_phase == RecallPhase.recall) ...[
                const Text(
                  'Which items were shown earlier?',
                  style: AppTypography.patientTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap ${_targetItems.length} items to select them:',
                  style: AppTypography.caregiverCaption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _choiceItems.map((choice) {
                    final isSelected = _selectedItemIds.contains(choice.id);

                    return InkWell(
                      onTap: () => _toggleChoice(choice.id),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? choice.color.withValues(alpha: 0.16) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? choice.color : AppColors.borderSoft,
                            width: isSelected ? 2.5 : 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(choice.icon, size: 40, color: choice.color),
                            const SizedBox(height: 8),
                            Text(
                              choice.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Icon(Icons.check_circle, size: 18, color: choice.color),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                ElderButton(
                  label: 'Check My Selections',
                  icon: Icons.check,
                  variant: ElderButtonVariant.primary,
                  height: 56,
                  onPressed: _selectedItemIds.isNotEmpty ? _submitRecall : null,
                ),
              ],

              // Phase 3: Feedback
              if (_phase == RecallPhase.feedback) ...[
                CalmCard(
                  backgroundColor: allTargetsFound ? AppColors.sageLight : AppColors.surfaceWarm,
                  borderColor: allTargetsFound ? AppColors.sage : AppColors.borderSoft,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Icon(
                        allTargetsFound ? Icons.check_circle_outline : Icons.favorite_outline,
                        size: 58,
                        color: allTargetsFound ? AppColors.forestDark : AppColors.forestPrimary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        allTargetsFound ? 'Wonderful Noticing!' : 'Gentle Effort',
                        style: AppTypography.patientHero,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        allTargetsFound
                            ? 'You recalled the items with peaceful focus. Every gentle moment helps our day.'
                            : 'You gave this a lovely try! The items were ${_targetItems.map((t) => t.name).join(' and ')}.',
                        style: AppTypography.patientBody,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElderButton(
                        label: 'Try Again',
                        icon: Icons.refresh,
                        variant: ElderButtonVariant.secondary,
                        height: 52,
                        onPressed: _retryMemorize,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElderButton(
                        label: _currentRound < _totalRounds ? 'Next Round' : 'Finish Activity',
                        icon: Icons.arrow_forward,
                        variant: ElderButtonVariant.primary,
                        height: 52,
                        onPressed: _advanceToNextRoundOrComplete,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
