import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/cognitive_domain.dart';
import '../../models/patient_profile.dart';
import '../../services/profile_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/gentle_back_button.dart';
import '../../widgets/common/language_toggle_widget.dart';
import '../../widgets/common/voice_input_field.dart';

/// Peaceful, dementia-friendly 3-part caregiver onboarding flow.
/// Replaces the cluttered 15-questionnaire wizard with 3 calm, unhurried steps:
/// - Part 1: General Information (Manual or Voice input)
/// - Part 2: Abilities, Preferences & Observations (Comforts, cultural anchors, voice)
/// - Part 3: Daily Routines & Doctor's Advises (Rhythm, clinician notes, voice reminders)
class CaregiverOnboardingScreen extends StatefulWidget {
  const CaregiverOnboardingScreen({super.key});

  @override
  State<CaregiverOnboardingScreen> createState() => _CaregiverOnboardingScreenState();
}

class _CaregiverOnboardingScreenState extends State<CaregiverOnboardingScreen> {
  int _currentPart = 1; // 1, 2, 3 or 4 (Completion)

  // Part 1: General Info Controllers
  final TextEditingController _nameController = TextEditingController(text: 'Bonti Baruah');
  String _selectedAgeRange = '70-79 years';
  String _selectedRelationship = 'Daughter';
  final TextEditingController _hometownController = TextEditingController(text: 'Tezpur, Assam');
  String? _part1VoiceNote;

  // Part 2: Abilities, Preferences & Observations
  String _readingComfort = 'prefers_large_text';
  String _hearingSupport = 'uses_hearing_aid';
  String _touchMobility = 'gentle_broad_tap';
  final Set<String> _selectedMusic = {'Borgeet Flute', 'Rabindra Sangeet', 'Old Hindi Classics'};
  final Set<String> _selectedPlacesAndFoods = {'Assam Tea Gardens', 'Veranda Swing', 'Pitha'};
  final Set<String> _selectedCalming = {'Soft flute music', 'Looking at family photos', 'Veranda chai'};
  final Set<String> _selectedDislikes = {'Loud sudden sounds', 'Rushing / timers'};
  final TextEditingController _observationController = TextEditingController(
    text: 'Listening to soft flute music and looking at tea garden photos brings a warm smile.',
  );
  String? _part2VoiceNote;

  // Part 3: Daily Routines & Doctor's Advises
  String _preferredTimeOfDay = 'Morning (9 AM - 11 AM)';
  final Set<String> _selectedRoutineAnchors = {
    'Morning Assam tea on veranda',
    'Evening family prayer',
    'Afternoon quiet rest',
  };
  final TextEditingController _doctorAdviceController = TextEditingController(
    text: 'Keep all activities relaxed and unpaced. Encourage gentle hydration and avoid afternoon fatigue.',
  );
  String _caregiverAvailability = 'Evenings & Weekends';
  String? _part3VoiceNote;

  @override
  void dispose() {
    _nameController.dispose();
    _hometownController.dispose();
    _observationController.dispose();
    _doctorAdviceController.dispose();
    super.dispose();
  }

  void _nextPart() {
    if (_currentPart < 3) {
      setState(() {
        _currentPart++;
      });
    } else {
      // Transition to completion state
      setState(() {
        _currentPart = 4;
      });
    }
  }

  void _previousPart() {
    if (_currentPart > 1) {
      setState(() {
        _currentPart--;
      });
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.caregiverWelcome);
      }
    }
  }

  void _finishAndStartJourney() {
    // Construct patient profile from the 3-part answers
    final profile = PatientProfile(
      id: 'patient_${DateTime.now().millisecondsSinceEpoch}',
      preferredName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Loved One',
      ageRange: _selectedAgeRange,
      preferredLanguage: AppStrings.currentLanguage,
      relationshipToCaregiver: _selectedRelationship,
      readingComfort: _readingComfort,
      hearingSupport: _hearingSupport,
      touchMobility: _touchMobility,
      favoriteMusicGenres: _selectedMusic.toList(),
      familiarPlacesAndFoods: _selectedPlacesAndFoods.toList(),
      interestsAndHobbies: _selectedCalming.toList(),
      activitiesToAvoid: _selectedDislikes.toList(),
      observationNote: _observationController.text.trim(),
      whatHelpedNote: _observationController.text.trim(),
      preferredTimeOfDay: _preferredTimeOfDay,
      dailyRoutineAnchors: _selectedRoutineAnchors.toList(),
      caregiverAvailability: _caregiverAvailability,
      doctorRecommendations: _doctorAdviceController.text.trim(),
      familiarPlaces: [_hometownController.text.trim(), 'Veranda Swing'],
      areasToSupport: const [CognitiveDomainType.memory, CognitiveDomainType.orientation],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isComplete: true,
    );

    // Save profile and voice notes
    ProfileService.instance.saveProfile(
      profile,
      generalVoice: _part1VoiceNote,
      obsVoice: _part2VoiceNote,
      drVoice: _part3VoiceNote,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.forestPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profile for ${profile.preferredName} saved safely offline.',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Navigate to Activity Profile (6 Domains) to show organized domain profile
    Navigator.of(context).pushReplacementNamed(AppRoutes.domainOverview);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPart == 4) {
      return _buildCompletionScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _previousPart();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        leading: GentleBackButton(onPressed: _previousPart),
        title: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.spa_rounded, color: AppColors.forestPrimary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Step $_currentPart of 3',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: LanguageToggleWidget(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Step Indicator
            Container(
              height: 4,
              color: AppColors.sageLight,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _currentPart / 3.0,
                child: Container(color: AppColors.forestPrimary),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: _buildCurrentPartContent(),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentPart > 1) ...[
                    Expanded(
                      flex: 1,
                      child: ElderButton(
                        label: 'Back',
                        icon: Icons.arrow_back,
                        variant: ElderButtonVariant.secondary,
                        height: 52,
                        onPressed: _previousPart,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElderButton(
                      label: _currentPart == 3 ? 'Save & Review' : 'Next Step',
                      icon: Icons.arrow_forward,
                      variant: ElderButtonVariant.primary,
                      height: 52,
                      onPressed: _nextPart,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildCurrentPartContent() {
    switch (_currentPart) {
      case 1:
        return _buildPart1GeneralInfo();
      case 2:
        return _buildPart2AbilitiesAndPreferences();
      case 3:
      default:
        return _buildPart3RoutinesAndDoctor();
    }
  }

  // ==========================================
  // PART 1: GENERAL INFORMATION
  // ==========================================
  Widget _buildPart1GeneralInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('part_1_title'),
          style: AppTypography.patientTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.get('part_1_desc'),
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 20),

        // 1. Patient Name (Voice + Manual)
        VoiceInputField(
          controller: _nameController,
          label: AppStrings.get('patient_name_label'),
          hint: 'e.g. Bonti Baruah or Aita',
          voiceSimulationSample: 'Bonti Baruah',
        ),
        const SizedBox(height: 18),

        // 2. Age Range
        const Text(
          'Age Range',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['60-69 years', '70-79 years', '80-89 years', '90+ years'].map((age) {
            final isSelected = _selectedAgeRange == age;
            return ChoiceChip(
              label: Text(age),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (_) => setState(() => _selectedAgeRange = age),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 3. Relationship to Caregiver
        const Text(
          'Your Relationship to the Loved One',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Daughter', 'Son', 'Spouse', 'Grandchild', 'Nurse / Caregiver'].map((rel) {
            final isSelected = _selectedRelationship == rel;
            return ChoiceChip(
              label: Text(rel),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (_) => setState(() => _selectedRelationship = rel),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 4. Familiar Hometown / Region (Voice + Manual)
        VoiceInputField(
          controller: _hometownController,
          label: AppStrings.get('hometown_label'),
          hint: 'e.g. Tezpur, Assam',
          voiceSimulationSample: 'Tezpur, Assam near Brahmaputra river',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          children: ['Tezpur', 'Guwahati', 'Jorhat', 'Dibrugarh', 'Silchar'].map((place) {
            return ActionChip(
              label: Text(place, style: const TextStyle(fontSize: 13)),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.borderSoft),
              onPressed: () => setState(() => _hometownController.text = '$place, Assam'),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Voice Introduction Card
        CalmCard(
          backgroundColor: AppColors.surfaceWarm,
          borderColor: AppColors.forestPrimary.withValues(alpha: 0.25),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: AppColors.forestPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speak a Brief Voice Note',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'You can speak any general details using the mic icons above or type freely.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PART 2: ABILITIES, PREFERENCES & OBSERVATIONS
  // ==========================================
  Widget _buildPart2AbilitiesAndPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('part_2_title'),
          style: AppTypography.patientTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.get('part_2_desc'),
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 20),

        // 1. Reading & Sensory Comfort
        const Text(
          'Reading & Text Comfort',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            {'code': 'prefers_large_text', 'label': 'Large text needed'},
            {'code': 'prefers_spoken_only', 'label': 'Spoken voice is best'},
            {'code': 'fluent', 'label': 'Reads comfortably'},
            {'code': 'unsure', 'label': 'I am unsure'},
          ].map((item) {
            final isSelected = _readingComfort == item['code'];
            return ChoiceChip(
              label: Text(item['label']!),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (_) => setState(() => _readingComfort = item['code']!),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Hearing Support
        const Text(
          'Hearing & Sound Comfort',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            {'code': 'normal', 'label': 'Clear hearing'},
            {'code': 'uses_hearing_aid', 'label': 'Uses hearing aid'},
            {'code': 'needs_high_volume', 'label': 'Needs higher volume'},
            {'code': 'unsure', 'label': 'I am unsure'},
          ].map((item) {
            final isSelected = _hearingSupport == item['code'];
            return ChoiceChip(
              label: Text(item['label']!),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (_) => setState(() => _hearingSupport = item['code']!),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Touch Mobility
        const Text(
          'Touch & Screen Mobility',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            {'code': 'accurate_tap', 'label': 'Standard tap'},
            {'code': 'gentle_broad_tap', 'label': 'Gentle broad tap'},
            {'code': 'tremor_support_needed', 'label': 'Tremor support needed'},
            {'code': 'unsure', 'label': 'I am unsure'},
          ].map((item) {
            final isSelected = _touchMobility == item['code'];
            return ChoiceChip(
              label: Text(item['label']!),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (_) => setState(() => _touchMobility = item['code']!),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 2. Favorite Music Melodies
        const Text(
          'Beloved Music & Cultural Melodies',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Borgeet Flute',
            'Rabindra Sangeet',
            'Bihu Folk Melodies',
            'Old Hindi Classics',
            'Bhajan / Kirtan',
            'Assam Tea Songs',
          ].map((music) {
            final isSelected = _selectedMusic.contains(music);
            return FilterChip(
              label: Text(music),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (selected) {
                setState(() {
                  selected ? _selectedMusic.add(music) : _selectedMusic.remove(music);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 3. Cherished Places & Foods
        const Text(
          'Cherished Places & Foods',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Assam Tea Gardens',
            'Veranda Swing',
            'Brahmaputra River',
            'Pitha & Laru',
            'Masor Tenga',
            'Temple Veranda',
          ].map((item) {
            final isSelected = _selectedPlacesAndFoods.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (selected) {
                setState(() {
                  selected ? _selectedPlacesAndFoods.add(item) : _selectedPlacesAndFoods.remove(item);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 4. Caregiver Observations (Voice + Manual)
        VoiceInputField(
          controller: _observationController,
          label: AppStrings.get('caregiver_obs_label'),
          hint: 'What brings peace, calm, or a smile?',
          voiceSimulationSample: 'Looking at tea garden photos and listening to morning flute music brings a peaceful smile.',
          maxLines: 2,
        ),
      ],
    );
  }

  // ==========================================
  // PART 3: ROUTINES & DOCTOR'S ADVISES
  // ==========================================
  Widget _buildPart3RoutinesAndDoctor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('part_3_title'),
          style: AppTypography.patientTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.get('part_3_desc'),
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 20),

        // 1. Preferred Time of Day
        const Text(
          'Best Time for Gentle Activities',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Morning (9 AM - 11 AM)',
            'Afternoon (3 PM - 5 PM)',
            'Evening (6 PM - 8 PM)',
          ].map((time) {
            final isSelected = _preferredTimeOfDay == time;
            return ChoiceChip(
              label: Text(time),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (_) => setState(() => _preferredTimeOfDay = time),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 2. Daily Routine Anchors
        const Text(
          'Daily Routine Anchors',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Morning Assam tea on veranda',
            'Afternoon quiet rest',
            'Evening family prayer',
            'Garden walk',
            'Listening to evening radio',
          ].map((anchor) {
            final isSelected = _selectedRoutineAnchors.contains(anchor);
            return FilterChip(
              label: Text(anchor),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (selected) {
                setState(() {
                  selected ? _selectedRoutineAnchors.add(anchor) : _selectedRoutineAnchors.remove(anchor);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 3. Doctor's Advises & Clinician Notes (Voice + Manual)
        VoiceInputField(
          controller: _doctorAdviceController,
          label: AppStrings.get('doctor_advises_label'),
          hint: 'Enter or speak any clinician advice, medication timing or hydration reminders...',
          voiceSimulationSample: 'Ensure frequent water hydration. Keep all activities unhurried with zero pressure.',
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Caregiver Availability
        const Text(
          'Caregiver Presence Rhythm',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Always present with loved one',
            'Evenings & Weekends',
            'Occasional check-in',
          ].map((avail) {
            final isSelected = _caregiverAvailability == avail;
            return ChoiceChip(
              label: Text(avail),
              selected: isSelected,
              selectedColor: AppColors.surfaceWarm,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                width: isSelected ? 2.0 : 1.0,
              ),
              onSelected: (_) => setState(() => _caregiverAvailability = avail),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================
  // COMPLETION SCREEN
  // ==========================================
  Widget _buildCompletionScreen() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Loved One';

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                // Heart & Botanical Celebration Icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWarm,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.forestPrimary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forestPrimary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.forestPrimary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  AppStrings.get('profile_complete_title'),
                  style: AppTypography.patientHero.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.get('profile_complete_subtitle'),
                  style: AppTypography.caregiverBody.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Summary Card
                CalmCard(
                  backgroundColor: Colors.white,
                  borderColor: AppColors.forestPrimary.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.forestPrimary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Profile for: $name ($_selectedAgeRange)',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.music_note, color: AppColors.forestPrimary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Anchors: ${_selectedMusic.take(2).join(", ")}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_outlined, color: AppColors.forestPrimary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Best rhythm: $_preferredTimeOfDay',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Primary Action: Start Today's Journey
                ElderButton(
                  label: AppStrings.get('start_todays_journey'),
                  icon: Icons.play_arrow_rounded,
                  variant: ElderButtonVariant.primary,
                  height: 56,
                  onPressed: _finishAndStartJourney,
                ),
                const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
