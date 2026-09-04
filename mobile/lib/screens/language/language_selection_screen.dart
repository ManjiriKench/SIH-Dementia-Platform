import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLang = 'en';

  final List<Map<String, String>> _languages = [
    {
      'code': 'en',
      'nativeName': 'English',
      'region': 'Standard / Global',
      'sampleGreeting': 'Welcome. We are here to enjoy gentle activities together.',
    },
    {
      'code': 'hi',
      'nativeName': 'हिंदी',
      'region': 'Hindi',
      'sampleGreeting': 'नमस्ते। आइए मिलकर सुखद और शांत पल बिताएं।',
    },
    {
      'code': 'as',
      'nativeName': 'অসমীয়া',
      'region': 'North Eastern Region / Assam',
      'sampleGreeting': 'নমস্কাৰ। আহক আমি একেলগে কেইটামান শান্তিপূৰ্ণ মুহূৰ্ত কটাওঁ।',
    },
  ];

  void _onLanguageSelected(String code) {
    setState(() {
      _selectedLang = code;
      AppStrings.setLanguage(code);
    });
  }

  void _playSample(String sampleText) {
    VoiceAssistantService.instance.speak(sampleText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Choose Your Language',
                style: AppTypography.patientHero,
              ),
              const SizedBox(height: 6),
              const Text(
                'भाषा चुनें • ভাষা বাছক',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forestPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the language most comfortable for listening and reading.',
                style: AppTypography.caregiverBody,
              ),
              const SizedBox(height: 28),
              // Language List
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _languages[index];
                    final isSelected = _selectedLang == item['code'];

                    return CalmCard(
                      backgroundColor: isSelected ? AppColors.surfaceWarm : Colors.white,
                      borderColor: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                      borderWidth: isSelected ? 2.4 : 1.2,
                      padding: const EdgeInsets.all(18),
                      onTap: () => _onLanguageSelected(item['code']!),
                      child: Row(
                        children: [
                          // Selection Indicator
                          Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 28,
                            color: isSelected ? AppColors.forestPrimary : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 16),
                          // Language Names
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nativeName']!,
                                  style: AppTypography.patientTitle.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['region']!,
                                  style: AppTypography.caregiverCaption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Listen Sample Button
                          Material(
                            color: isSelected ? AppColors.forestPrimary : AppColors.surfaceWarm,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _playSample(item['sampleGreeting']!),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 24,
                                  color: isSelected ? Colors.white : AppColors.forestPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Continue Button
              ElderButton(
                label: 'Continue • आगे बढ़ें • আগবাঢ়ক',
                icon: Icons.arrow_forward,
                onPressed: () {
                  VoiceAssistantService.instance.stopSpeaking();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
                },
                variant: ElderButtonVariant.primary,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
