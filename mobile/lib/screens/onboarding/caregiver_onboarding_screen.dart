import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/cognitive_domain.dart';
import '../../models/patient_profile.dart';
import '../../services/profile_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';

/// Progressive 5-step caregiver onboarding wizard for creating
/// a personalized, non-diagnostic patient profile.
class CaregiverOnboardingScreen extends StatefulWidget {
  const CaregiverOnboardingScreen({super.key});

  @override
  State<CaregiverOnboardingScreen> createState() => _CaregiverOnboardingScreenState();
}

class _CaregiverOnboardingScreenState extends State<CaregiverOnboardingScreen> {
  int _currentStep = 1;
  bool _isProfileReady = false;

  // Step 1: Basic Information
  final TextEditingController _nameController = TextEditingController(text: 'Bonti Baruah');
  String _selectedAgeRange = '70-79 years';
  String _selectedRelationship = 'Daughter';
  String _preferredLanguage = 'en';

  // Step 2: Baseline Abilities & Support Needs (with "I am unsure" options)
  String _readingComfort = 'prefers_large_text';
  String _hearingSupport = 'uses_hearing_aid';
  String _visualSupport = 'large_elements_needed';
  String _speechComfort = 'expressive';
  String _touchMobility = 'gentle_broad_tap';
  String _independentPlay = 'gentle_supervision';
  String _attentionSpan = '5_10_minutes';

  // Step 3: Preferences & Cultural Anchors
  final Set<String> _selectedInterests = {
    'Assam Tea Gardens',
    'Gardening',
    'Traditional Weaving',
  };
  final Set<String> _selectedMusic = {
    'Borgeet Flute',
    'Rabindra Sangeet',
    'Old Hindi Classics',
  };
  final Set<String> _selectedPlacesAndFoods = {
    'Tezpur Ghats',
    'Assam Chai',
    'Pitha & Laru',
  };
  String _interactionStyle = 'warm_and_guided';

  // Step 4: Routines & Caregiver Availability
  String _preferredTimeOfDay = 'Morning (9 AM - 11 AM)';
  final Set<String> _selectedRoutineAnchors = {
    'Morning Assam tea on veranda',
    'Evening family prayers',
    'Listening to morning radio',
  };
  String _caregiverAvailability = 'Evenings & Weekends';

  // Step 5: Recent Observations & Voice Note
  final Set<String> _selectedMoodTags = {'calm', 'engaged'};
  final TextEditingController _whatHelpedController = TextEditingController(
    text: 'Listening to soft flute music and looking at old photographs together brings a warm smile.',
  );
  final TextEditingController _voiceNoteController = TextEditingController();
  bool _isRecordingVoice = false;

  @override
  void dispose() {
    _nameController.dispose();
    _whatHelpedController.dispose();
    _voiceNoteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finalizeProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _finalizeProfile() {
    final newProfile = PatientProfile(
      id: 'patient_${DateTime.now().millisecondsSinceEpoch}',
      preferredName: _nameController.text.trim().isEmpty ? 'Grandmother' : _nameController.text.trim(),
      ageRange: _selectedAgeRange,
      preferredLanguage: _preferredLanguage,
      relationshipToCaregiver: _selectedRelationship,
      readingComfort: _readingComfort,
      hearingSupport: _hearingSupport,
      visualSupport: _visualSupport,
      speechComfort: _speechComfort,
      touchMobility: _touchMobility,
      independentPlay: _independentPlay,
      attentionSpan: _attentionSpan,
      areasToSupport: const [
        CognitiveDomainType.memory,
        CognitiveDomainType.orientation,
        CognitiveDomainType.attention,
      ],
      safeActivityTypes: const ['matching', 'music_listening', 'photo_stories'],
      activitiesToAvoid: const ['time_pressure', 'rapid_flashing'],
      interestsAndHobbies: _selectedInterests.toList(),
      favoriteMusicGenres: _selectedMusic.toList(),
      familiarPlacesAndFoods: _selectedPlacesAndFoods.toList(),
      interactionStyle: _interactionStyle,
      preferredTimeOfDay: _preferredTimeOfDay,
      dailyRoutineAnchors: _selectedRoutineAnchors.toList(),
      caregiverAvailability: _caregiverAvailability,
      recentMoodTags: _selectedMoodTags.toList(),
      observationNote: _voiceNoteController.text.isNotEmpty ? _voiceNoteController.text : null,
      whatHelpedNote: _whatHelpedController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ProfileService.instance.saveProfile(newProfile);

    setState(() {
      _isProfileReady = true;
    });
  }

  void _showSaveAndExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Save & Continue Later?', style: AppTypography.patientTitle),
        content: const Text(
          'Your progress is preserved on this device. You can return anytime to complete onboarding.',
          style: AppTypography.caregiverBody,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          ElderButton(
            label: 'Keep Going',
            variant: ElderButtonVariant.primary,
            height: 50,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          const SizedBox(height: 10),
          ElderButton(
            label: 'Save Draft & Exit',
            variant: ElderButtonVariant.secondary,
            height: 50,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleVoiceRecording() async {
    if (!_isRecordingVoice) {
      final started = await VoiceAssistantService.instance.startRecording();
      if (started) {
        setState(() => _isRecordingVoice = true);
      }
    } else {
      final transcription = await VoiceAssistantService.instance.stopRecordingAndTranscribe();
      setState(() {
        _isRecordingVoice = false;
        _voiceNoteController.text = transcription;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProfileReady) {
      return _buildProfileReadyScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.forestPrimary),
          onPressed: _previousStep,
        ),
        title: Text('Step $_currentStep of 5', style: AppTypography.caregiverSubheading),
        actions: [
          TextButton(
            onPressed: _showSaveAndExitDialog,
            child: const Text(
              'Save & Later',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.forestPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Bar
            LinearProgressIndicator(
              value: _currentStep / 5.0,
              backgroundColor: AppColors.borderSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forestPrimary),
              minHeight: 4.5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22.0),
                child: _buildCurrentStepContent(),
              ),
            ),
            // Bottom Action Navigation Bar
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              decoration: const BoxDecoration(
                color: AppColors.backgroundWarm,
                border: Border(top: BorderSide(color: AppColors.borderSoft, width: 1.2)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    Expanded(
                      flex: 1,
                      child: ElderButton(
                        label: 'Previous',
                        onPressed: _previousStep,
                        variant: ElderButtonVariant.secondary,
                        height: 56,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElderButton(
                      label: _currentStep == 5 ? 'Create Gentle Profile' : 'Next Step',
                      icon: _currentStep == 5 ? Icons.check_circle_outline : Icons.arrow_forward,
                      onPressed: _nextStep,
                      variant: ElderButtonVariant.primary,
                      height: 56,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1BasicInfo();
      case 2:
        return _buildStep2Abilities();
      case 3:
        return _buildStep3Preferences();
      case 4:
        return _buildStep4Routines();
      case 5:
        return _buildStep5Observations();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1: Basic Info ---
  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Who are we caring for?', style: AppTypography.patientHero),
        const SizedBox(height: 6),
        const Text(
          'Let’s start with a few basic details to personalize their experience.',
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 24),
        // Name Input
        const Text('Preferred Name or Warm Greeting', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: AppTypography.patientBody,
          decoration: InputDecoration(
            hintText: 'e.g. Bonti Baruah, Dadi, Maa',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSoft, width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.forestPrimary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 22),
        // Age Range
        const Text('Age Bracket', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['60-69 years', '70-79 years', '80-89 years', '90+ years'].map((age) {
            final isSelected = _selectedAgeRange == age;
            return ChoiceChip(
              label: Text(age),
              selected: isSelected,
              selectedColor: AppColors.forestPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setState(() => _selectedAgeRange = age),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        // Relationship to Caregiver
        const Text('Your Relationship to Them', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Daughter', 'Son', 'Spouse', 'Grandchild', 'Nurse / Professional', 'Other'].map((rel) {
            final isSelected = _selectedRelationship == rel;
            return ChoiceChip(
              label: Text(rel),
              selected: isSelected,
              selectedColor: AppColors.forestPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setState(() => _selectedRelationship = rel),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        // Preferred Language
        const Text('Primary Language for Activities', style: AppTypography.caregiverSubheading),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            {'code': 'en', 'label': 'English'},
            {'code': 'hi', 'label': 'हिंदी (Hindi)'},
            {'code': 'as', 'label': 'অসমীয়া (Assamese)'},
          ].map((lang) {
            final isSelected = _preferredLanguage == lang['code'];
            return ChoiceChip(
              label: Text(lang['label']!),
              selected: isSelected,
              selectedColor: AppColors.forestPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setState(() => _preferredLanguage = lang['code']!),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Step 2: Baseline Abilities & Support Needs ---
  Widget _buildStep2Abilities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comfort & Support Needs', style: AppTypography.patientHero),
        const SizedBox(height: 6),
        const Text(
          'Capture practical baseline comfort rather than medical diagnosis. Every question includes an "I am unsure" option.',
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 24),
        _buildRadioOptionGroup(
          title: 'Reading Comfort',
          currentValue: _readingComfort,
          onChanged: (val) => setState(() => _readingComfort = val),
          options: const {
            'fluent': 'Enjoys reading short phrases',
            'prefers_large_text': 'Prefers extra-large text',
            'prefers_spoken_only': 'Prefers spoken audio instructions',
            'unsure': 'I am unsure right now',
          },
        ),
        const SizedBox(height: 20),
        _buildRadioOptionGroup(
          title: 'Hearing Support',
          currentValue: _hearingSupport,
          onChanged: (val) => setState(() => _hearingSupport = val),
          options: const {
            'normal': 'Standard audio is clear',
            'uses_hearing_aid': 'Uses hearing aid',
            'needs_high_volume': 'Needs extra clear, high volume',
            'unsure': 'I am unsure right now',
          },
        ),
        const SizedBox(height: 20),
        _buildRadioOptionGroup(
          title: 'Touch & Interaction Style',
          currentValue: _touchMobility,
          onChanged: (val) => setState(() => _touchMobility = val),
          options: const {
            'accurate_tap': 'Steady and accurate taps',
            'gentle_broad_tap': 'Broad, relaxed taps on large buttons',
            'tremor_support_needed': 'Needs support for hand tremor / hesitation',
            'unsure': 'I am unsure right now',
          },
        ),
        const SizedBox(height: 20),
        _buildRadioOptionGroup(
          title: 'Attention & Engagement Pace',
          currentValue: _attentionSpan,
          onChanged: (val) => setState(() => _attentionSpan = val),
          options: const {
            '3_5_minutes': '3 to 5 minutes at a time',
            '5_10_minutes': '5 to 10 minutes comfortably',
            'relaxed_unpaced': 'Completely unhurried, no expectations',
            'unsure': 'I am unsure right now',
          },
        ),
      ],
    );
  }

  Widget _buildRadioOptionGroup({
    required String title,
    required String currentValue,
    required ValueChanged<String> onChanged,
    required Map<String, String> options,
  }) {
    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caregiverSubheading),
          const SizedBox(height: 10),
          ...options.entries.map((entry) {
            final isSelected = currentValue == entry.key;
            final isUnsure = entry.key == 'unsure';

            return InkWell(
              onTap: () => onChanged(entry.key),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected
                          ? (isUnsure ? AppColors.offlineAmber : AppColors.forestPrimary)
                          : AppColors.textTertiary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isUnsure && isSelected ? AppColors.offlineAmber : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Step 3: Preferences & Cultural Anchors ---
  Widget _buildStep3Preferences() {
    final availableInterests = [
      'Assam Tea Gardens',
      'Gardening',
      'Traditional Weaving',
      'Cooking Regional Dishes',
      'Morning Birdwatching',
      'Handicrafts',
    ];

    final availableMusic = [
      'Borgeet Flute',
      'Rabindra Sangeet',
      'Old Hindi Classics',
      'Bihu Folk Melodies',
      'Classical Sitar',
      'Morning Bhajans',
    ];

    final availablePlaces = [
      'Tezpur Ghats',
      'Assam Chai',
      'Pitha & Laru',
      'Veranda Swing',
      'Village Temple',
      'Brahmaputra River',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Familiar World & Heritage', style: AppTypography.patientHero),
        const SizedBox(height: 6),
        const Text(
          'Connecting through cherished memories, regional culture, and soothing melodies brings real joy.',
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 24),
        const Text('Cherished Interests & Hobbies', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 8),
        _buildMultiSelectChips(availableInterests, _selectedInterests),
        const SizedBox(height: 24),
        const Text('Favourite Music & Melodies', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 8),
        _buildMultiSelectChips(availableMusic, _selectedMusic),
        const SizedBox(height: 24),
        const Text('Familiar Places, Foods & Traditions', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 8),
        _buildMultiSelectChips(availablePlaces, _selectedPlacesAndFoods),
        const SizedBox(height: 24),
        const Text('Preferred Interaction Style', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            {'key': 'quiet', 'label': 'Quiet & Calm'},
            {'key': 'warm_and_guided', 'label': 'Warm & Guided'},
            {'key': 'music_centered', 'label': 'Music-Centered'},
            {'key': 'conversational', 'label': 'Conversational & Storytelling'},
          ].map((style) {
            final isSelected = _interactionStyle == style['key'];
            return ChoiceChip(
              label: Text(style['label']!),
              selected: isSelected,
              selectedColor: AppColors.forestPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setState(() => _interactionStyle = style['key']!),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips(List<String> options, Set<String> currentSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((item) {
        final isSelected = currentSelected.contains(item);
        return FilterChip(
          label: Text(item),
          selected: isSelected,
          selectedColor: AppColors.sageLight,
          checkmarkColor: AppColors.forestDark,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.forestDark : AppColors.textPrimary,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.sage : AppColors.borderSoft,
              width: 1.2,
            ),
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                currentSelected.add(item);
              } else {
                currentSelected.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // --- Step 4: Daily Routines & Caregiver Availability ---
  Widget _buildStep4Routines() {
    final availableAnchors = [
      'Morning Assam tea on veranda',
      'Evening family prayers',
      'Listening to morning radio',
      'Gentle walk in the garden',
      'Afternoon quiet rest',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Rhythm & Routine', style: AppTypography.patientHero),
        const SizedBox(height: 6),
        const Text(
          'Grounding activities in familiar daily anchors reduces anxiety and creates comfortable expectations.',
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 24),
        const Text('Best Time of Day for Activities', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            'Morning (9 AM - 11 AM)',
            'Afternoon (3 PM - 5 PM)',
            'Evening (6 PM - 8 PM)',
          ].map((time) {
            final isSelected = _preferredTimeOfDay == time;
            return ChoiceChip(
              label: Text(time),
              selected: isSelected,
              selectedColor: AppColors.forestPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setState(() => _preferredTimeOfDay = time),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Daily Routine Anchors', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 8),
        _buildMultiSelectChips(availableAnchors, _selectedRoutineAnchors),
        const SizedBox(height: 24),
        const Text('When Can You (Caregiver) Join Together?', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            'Always present',
            'Evenings & Weekends',
            'Weekends only',
            'Occasionally / Independent mostly',
          ].map((sched) {
            final isSelected = _caregiverAvailability == sched;
            return ChoiceChip(
              label: Text(sched),
              selected: isSelected,
              selectedColor: AppColors.forestPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => setState(() => _caregiverAvailability = sched),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Step 5: Recent Observations & Voice Note ---
  Widget _buildStep5Observations() {
    final availableMoods = [
      'calm',
      'engaged',
      'joyful',
      'tired',
      'anxious',
      'withdrawn',
      'quiet',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Observations', style: AppTypography.patientHero),
        const SizedBox(height: 6),
        const Text(
          'How have they seemed lately? This helps AI select the most reassuring starter activities.',
          style: AppTypography.caregiverBody,
        ),
        const SizedBox(height: 24),
        const Text('Recent Demeanor & Mood', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableMoods.map((mood) {
            final isSelected = _selectedMoodTags.contains(mood);
            return FilterChip(
              label: Text(mood[0].toUpperCase() + mood.substring(1)),
              selected: isSelected,
              selectedColor: AppColors.sageLight,
              checkmarkColor: AppColors.forestDark,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.forestDark : AppColors.textPrimary,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedMoodTags.add(mood);
                  } else {
                    _selectedMoodTags.remove(mood);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('What Seems to Help or Comfort Them?', style: AppTypography.caregiverSubheading),
        const SizedBox(height: 8),
        TextField(
          controller: _whatHelpedController,
          maxLines: 3,
          style: AppTypography.caregiverBody.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Sipping warm tea, looking at old family albums, soft music...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSoft),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Optional Voice Note Recording Tile
        CalmCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.mic, color: AppColors.forestPrimary, size: 24),
                  SizedBox(width: 10),
                  Text('Optional Caregiver Voice Note', style: AppTypography.caregiverSubheading),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'You can speak naturally about their day or personality. Audio is transcribed securely on device.',
                style: AppTypography.caregiverCaption,
              ),
              const SizedBox(height: 16),
              ElderButton(
                label: _isRecordingVoice ? 'Stop & Transcribe Voice Note' : 'Record Voice Observation',
                icon: _isRecordingVoice ? Icons.stop_circle : Icons.mic,
                variant: _isRecordingVoice ? ElderButtonVariant.peach : ElderButtonVariant.secondary,
                height: 52,
                onPressed: _handleVoiceRecording,
              ),
              if (_voiceNoteController.text.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWarm,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transcribed Voice Note:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.forestDark),
                      ),
                      const SizedBox(height: 4),
                      Text(_voiceNoteController.text, style: AppTypography.caregiverBody),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- SCR-10: Profile Ready Celebratory Screen ---
  Widget _buildProfileReadyScreen() {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.sageLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.sage, width: 2.2),
                  ),
                  child: const Icon(Icons.check, size: 54, color: AppColors.forestDark),
                ),
                const SizedBox(height: 28),
                Text(
                  'Profile Ready for ${_nameController.text}',
                  style: AppTypography.patientHero.copyWith(color: AppColors.forestPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Personalized activities have been organized with gentle care. Grounded in familiar memories, morning tea routines, and soothing melodies.',
                  style: AppTypography.patientBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.sageDark, size: 26),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'No tests, no grades. Activities are crafted solely for joyful engagement and connection.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElderButton(
                  label: 'View AI Recommendations & Domains',
                  icon: Icons.auto_awesome,
                  variant: ElderButtonVariant.primary,
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.aiProcessing);
                  },
                ),
                const SizedBox(height: 12),
                ElderButton(
                  label: 'Go to Today’s Journey Directly',
                  icon: Icons.play_arrow,
                  variant: ElderButtonVariant.secondary,
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
