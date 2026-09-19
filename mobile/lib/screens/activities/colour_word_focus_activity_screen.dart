import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import '../../services/session_service.dart';
import '../patient_activity/activity_completion_screen.dart';

class ColorItemStimulus {
  final String itemName;
  final String questionText;
  final IconData itemIcon;
  final Color itemColor;
  final String correctColorName;
  final String spokenPraise;

  const ColorItemStimulus({
    required this.itemName,
    required this.questionText,
    required this.itemIcon,
    required this.itemColor,
    required this.correctColorName,
    required this.spokenPraise,
  });
}

/// Independent Cognitive Activity 8: Colour–Word Focus.
/// Accessible, peaceful visual focus experience designed specifically for dementia care:
/// - Single, clear focal item with zero Stroop confusion or contradictory words.
/// - Unhurried, large touch targets with distinct nature symbols.
/// - Clear question with zero duplicate text.
class ColourWordFocusActivityScreen extends StatefulWidget {
  const ColourWordFocusActivityScreen({super.key});

  @override
  State<ColourWordFocusActivityScreen> createState() => _ColourWordFocusActivityScreenState();
}

class _ColourWordFocusActivityScreenState extends State<ColourWordFocusActivityScreen> {
  int _currentRound = 0;
  final int _totalRounds = 3;
  String? _feedbackText;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Colour & Word Focus');
  }

  final List<ColorItemStimulus> _rounds = const [
    ColorItemStimulus(
      itemName: 'Fresh Tea Leaf',
      questionText: 'What color is this fresh tea leaf?',
      itemIcon: Icons.eco_rounded,
      itemColor: AppColors.forestPrimary,
      correctColorName: 'Green',
      spokenPraise: 'Wonderful! The tea leaf is a fresh, gentle green.',
    ),
    ColorItemStimulus(
      itemName: 'Morning Sun',
      questionText: 'What color is the warm morning sun?',
      itemIcon: Icons.wb_sunny_rounded,
      itemColor: AppColors.peachDark,
      correctColorName: 'Yellow',
      spokenPraise: 'Lovely noticing! The morning sun is warm golden yellow.',
    ),
    ColorItemStimulus(
      itemName: 'Brahmaputra River',
      questionText: 'What color is the calm river water?',
      itemIcon: Icons.water_rounded,
      itemColor: AppColors.domainOrientation,
      correctColorName: 'Blue',
      spokenPraise: 'Beautiful! The calm river water is serene blue.',
    ),
  ];

  final List<Map<String, dynamic>> _answerChoices = const [
    {
      'colorName': 'Green',
      'label': 'Tea Leaf (Green)',
      'icon': Icons.eco_rounded,
      'color': AppColors.forestPrimary,
    },
    {
      'colorName': 'Yellow',
      'label': 'Morning Sun (Yellow)',
      'icon': Icons.wb_sunny_rounded,
      'color': AppColors.peachDark,
    },
    {
      'colorName': 'Blue',
      'label': 'River Water (Blue)',
      'icon': Icons.water_rounded,
      'color': AppColors.domainOrientation,
    },
    {
      'colorName': 'Red',
      'label': 'Lotus Rose (Red)',
      'icon': Icons.local_florist_rounded,
      'color': Color(0xFFC62828),
    },
  ];

  void _onAnswerSelected(String selectedColorName) {
    final stimulus = _rounds[_currentRound];
    final isCorrect = selectedColorName == stimulus.correctColorName;

    setState(() {
      _isSuccess = isCorrect;
      if (isCorrect) {
        _feedbackText = 'Wonderful! You chose ${stimulus.correctColorName}.';
        VoiceAssistantService.instance.speak(stimulus.spokenPraise);
      } else {
        _feedbackText = 'Take all the time you need. Notice the gentle ${stimulus.correctColorName} color.';
        VoiceAssistantService.instance.speak('Take all the time you need. Look at the color of the ${stimulus.itemName}.');
      }
    });

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) {
          _advanceRound();
        }
      });
    }
  }

  void _advanceRound() {
    if (_currentRound < _totalRounds - 1) {
      setState(() {
        _currentRound++;
        _feedbackText = null;
      });
    } else {
      SessionService.instance.completeSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Colour–Word Focus',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stimulus = _rounds[_currentRound];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWarm,
        elevation: 0,
        leading: const ExitActivityButton(),
        leadingWidth: 160,
        title: const Text('Colour–Word Focus', style: AppTypography.caregiverSubheading),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Text(
              'Item ${_currentRound + 1} of $_totalRounds',
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
              // Voice Instruction Bar at the top — speaks calmly
              VoiceInstructionBar(
                instructionText: stimulus.questionText,
                autoPlay: false,
              ),
              const SizedBox(height: 20),

              // Single Large Focal Item Card (NO duplicate question)
              CalmCard(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Column(
                  children: [
                    // Large nature icon in its natural, authentic color
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: stimulus.itemColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: stimulus.itemColor.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Icon(stimulus.itemIcon, size: 54, color: stimulus.itemColor),
                    ),
                    const SizedBox(height: 16),

                    // Clear item title
                    Text(
                      stimulus.itemName,
                      style: AppTypography.patientHero.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Clear, unrepeated prompt
                    Text(
                      'Touch the matching color below:',
                      style: AppTypography.patientBody.copyWith(fontSize: 16, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Supportive Feedback Banner
              if (_feedbackText != null) ...[
                CalmCard(
                  backgroundColor: _isSuccess ? AppColors.sageLight : AppColors.peachLight,
                  borderColor: _isSuccess ? AppColors.sage : AppColors.peach,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.favorite,
                        size: 24,
                        color: _isSuccess ? AppColors.forestDark : AppColors.peachDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _feedbackText!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _isSuccess ? AppColors.forestDark : AppColors.peachDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Answer Buttons Grid (Accessible, spacious, 4 options)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.8,
                ),
                itemCount: _answerChoices.length,
                itemBuilder: (context, index) {
                  final choice = _answerChoices[index];
                  final colorName = choice['colorName'] as String;
                  final label = choice['label'] as String;
                  final icon = choice['icon'] as IconData;
                  final color = choice['color'] as Color;

                  return InkWell(
                    onTap: () => _onAnswerSelected(colorName),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 24, color: color),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              label,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              ElderButton(
                label: 'Skip / Next Round',
                icon: Icons.arrow_forward,
                variant: ElderButtonVariant.secondary,
                height: 52,
                onPressed: _advanceRound,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
