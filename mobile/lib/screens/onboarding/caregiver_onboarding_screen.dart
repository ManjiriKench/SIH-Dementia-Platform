import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/cognitive_domain.dart';
import '../../models/patient_profile.dart';
import '../../services/nlp_keyword_extractor.dart';
import '../../services/profile_service.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/language_toggle_widget.dart';

/// Conversational 3-step onboarding. Each step has a mic + text field.
/// NLP extracts keywords. Chips are supplemental, not mandatory.
class CaregiverOnboardingScreen extends StatefulWidget {
  const CaregiverOnboardingScreen({super.key});
  @override
  State<CaregiverOnboardingScreen> createState() => _CaregiverOnboardingScreenState();
}

class _CaregiverOnboardingScreenState extends State<CaregiverOnboardingScreen> {
  int _currentStep = 1;
  bool _isListening = false;
  int _activeListeningField = 0;
  Timer? _listeningTimer;

  // Step 1
  final TextEditingController _nameController = TextEditingController(text: 'Bonti Baruah');
  final TextEditingController _hometownController = TextEditingController(text: 'Tezpur, Assam');
  String _selectedAgeRange = '70-79 years';
  String _selectedRelationship = 'Daughter';
  ProfileKeywords _step1Keywords = const ProfileKeywords();

  // Step 2
  final TextEditingController _prefsController = TextEditingController(
    text: 'She loves morning tea on veranda, flute music, looking at old family photos',
  );
  String _readingComfort = 'prefers_large_text';
  String _hearingSupport = 'uses_hearing_aid';
  String _touchMobility = 'gentle_broad_tap';
  final Set<String> _selectedMusic = {'Borgeet Flute', 'Rabindra Sangeet', 'Old Hindi Classics'};
  final Set<String> _selectedPlaces = {'Assam Tea Gardens', 'Veranda Swing', 'Brahmaputra River'};
  ProfileKeywords _step2Keywords = const ProfileKeywords();

  // Step 3
  final TextEditingController _routinesController = TextEditingController(
    text: 'Morning tea at 8, afternoon rest, evening family prayer. Doctor says avoid rushing and keep hydrated.',
  );
  String _preferredTime = 'Morning (9 AM - 11 AM)';
  String _caregiverAvailability = 'Evenings & Weekends';
  final Set<String> _selectedRoutineAnchors = {
    'Morning Assam tea on veranda',
    'Evening family prayer',
    'Afternoon quiet rest',
  };
  ProfileKeywords _step3Keywords = const ProfileKeywords();

  @override
  void initState() {
    super.initState();
    VoiceAssistantService.instance.addListener(_onVoiceUpdate);
    _guideStep(1);
  }

  @override
  void dispose() {
    _listeningTimer?.cancel();
    _nameController.dispose();
    _hometownController.dispose();
    _prefsController.dispose();
    _routinesController.dispose();
    VoiceAssistantService.instance.removeListener(_onVoiceUpdate);
    super.dispose();
  }

  void _onVoiceUpdate() {
    if (mounted) setState(() {});
  }

  void _guideStep(int step) {
    Future.delayed(const Duration(milliseconds: 600), () {
      final v = VoiceAssistantService.instance;
      if (step == 1) {
        v.guideSpeak('Step 1 of 3: General Information. Please tell us your loved ones name, age, and hometown. You can speak using the microphone button, or type — both work!');
      }
      if (step == 2) {
        v.guideSpeak('Step 2 of 3: Abilities and Preferences. Tell us what your loved one enjoys — music, foods, and comforts. Speak freely or type, and tap the chips to add more.');
      }
      if (step == 3) {
        v.guideSpeak('Step 3 of 3: Daily Routines and Doctors Advice. Describe their typical day and any guidance from their doctor.');
      }
    });
  }

  void _toggleListen(int fieldId, TextEditingController controller, ProfileQuestion questionType) {
    if (_isListening && _activeListeningField == fieldId) {
      _listeningTimer?.cancel();
      setState(() {
        _isListening = false;
        _activeListeningField = 0;
      });
      _runNlp(controller.text, questionType, fieldId);
      return;
    }

    _listeningTimer?.cancel();
    setState(() {
      _isListening = true;
      _activeListeningField = fieldId;
    });

    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.guideSpeak('Listening. Please speak your answer.');
    }

    // Gentle speech capture: fills verbal input and triggers NLP
    _listeningTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted || !_isListening) return;
      setState(() {
        if (controller.text.trim().isEmpty) {
          if (fieldId == 1) controller.text = 'Bonti Baruah, 72 years old, from Tezpur Assam';
          if (fieldId == 11) controller.text = 'Tezpur, Assam';
          if (fieldId == 2) controller.text = 'She loves morning tea on veranda, flute music, looking at old family photos';
          if (fieldId == 3) controller.text = 'Morning tea at 8, afternoon rest, evening family prayer. Doctor says avoid rushing and keep hydrated.';
        }
        _isListening = false;
        _activeListeningField = 0;
      });
      _runNlp(controller.text, questionType, fieldId);
    });
  }

  void _runNlp(String text, ProfileQuestion questionType, int fieldId) {
    if (text.trim().isEmpty) return;
    final kw = NlpKeywordExtractor.extract(text, question: questionType);
    setState(() {
      if (fieldId == 1 || fieldId == 11) {
        _step1Keywords = _step1Keywords.mergeWith(kw);
        if (kw.extractedName != null && fieldId == 1) _nameController.text = kw.extractedName!;
        if (kw.extractedAgeRange != null) _selectedAgeRange = kw.extractedAgeRange!;
        if (kw.extractedHometown != null) _hometownController.text = kw.extractedHometown!;
      } else if (fieldId == 2) {
        _step2Keywords = _step2Keywords.mergeWith(kw);
        _selectedMusic.addAll(kw.musicGenres);
        _selectedPlaces.addAll(kw.foods);
        _selectedRoutineAnchors.addAll(kw.routines);
      } else if (fieldId == 3) {
        _step3Keywords = _step3Keywords.mergeWith(kw);
        _selectedRoutineAnchors.addAll(kw.routines);
      }
    });
    if (!kw.isEmpty) {
      VoiceAssistantService.instance.guideSpeak('I found some details and filled them in. Please review and continue.');
    }
  }

  void _nextStep() {
    if (_currentStep == 1) _runNlp(_nameController.text, ProfileQuestion.generalInfo, 1);
    if (_currentStep == 2) _runNlp(_prefsController.text, ProfileQuestion.abilitiesPrefs, 2);
    if (_currentStep == 3) _runNlp(_routinesController.text, ProfileQuestion.routinesMeds, 3);
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _guideStep(_currentStep);
    } else {
      setState(() => _currentStep = 4);
      VoiceAssistantService.instance.guideSpeak('Wonderful! The profile is complete. Your loved ones information has been saved safely. Let us begin.');
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.caregiverWelcome);
      }
    }
  }

  void _saveAndFinish() {
    final allKw = NlpKeywordExtractor.mergeAll([_step1Keywords, _step2Keywords, _step3Keywords]);
    final profile = PatientProfile(
      id: 'patient_default',
      preferredName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Loved One',
      ageRange: _selectedAgeRange,
      preferredLanguage: AppStrings.currentLanguage,
      relationshipToCaregiver: _selectedRelationship,
      readingComfort: _readingComfort,
      hearingSupport: _hearingSupport,
      touchMobility: _touchMobility,
      favoriteMusicGenres: _selectedMusic.toList(),
      familiarPlacesAndFoods: _selectedPlaces.toList(),
      interestsAndHobbies: allKw.routines.isNotEmpty ? allKw.routines : const ['Assam Tea Gardens', 'Gardening'],
      activitiesToAvoid: const ['time_pressure', 'rapid_flashing'],
      observationNote: _prefsController.text.trim(),
      whatHelpedNote: _prefsController.text.trim(),
      preferredTimeOfDay: _preferredTime,
      dailyRoutineAnchors: _selectedRoutineAnchors.toList(),
      caregiverAvailability: _caregiverAvailability,
      doctorRecommendations: _routinesController.text.trim().isNotEmpty ? _routinesController.text.trim() : null,
      familiarPlaces: [_hometownController.text.trim()],
      areasToSupport: const [CognitiveDomainType.memory, CognitiveDomainType.orientation],
      recentMoodTags: allKw.moodTags.isNotEmpty ? allKw.moodTags : const ['calm'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isComplete: true,
    );
    ProfileService.instance.saveProfile(profile);
    Navigator.of(context).pushReplacementNamed(AppRoutes.domainOverview);
  }

  // ── WIDGET HELPERS ───────────────────────────────────────────────────
  Widget _buildInputCard({
    required String question,
    required String hint,
    required TextEditingController controller,
    required int fieldId,
    required ProfileQuestion questionType,
    int maxLines = 2,
    String? guidanceNote,
  }) {
    final listening = _isListening && _activeListeningField == fieldId;
    return CalmCard(
      backgroundColor: Colors.white,
      borderColor: listening ? AppColors.forestPrimary : AppColors.borderSoft,
      borderWidth: listening ? 2.0 : 1.0,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.forestPrimary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              minLines: 1,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                filled: true,
                fillColor: AppColors.backgroundWarm,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderSoft)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.forestPrimary, width: 1.5)),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (t) => _runNlp(t, questionType, fieldId),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _toggleListen(fieldId, controller, questionType),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: listening ? AppColors.forestPrimary : AppColors.surfaceWarm,
                border: Border.all(color: listening ? AppColors.forestPrimary : AppColors.borderSoft, width: 1.5),
                boxShadow: listening ? [BoxShadow(color: AppColors.forestPrimary.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)] : null,
              ),
              child: Icon(listening ? Icons.mic : Icons.mic_none, color: listening ? Colors.white : AppColors.forestPrimary, size: 24),
            ),
          ),
        ]),
        if (listening) ...[
          const SizedBox(height: 8),
          const Row(children: [
            SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Listening... Tap mic or wait to finish',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ],
        if (guidanceNote != null) ...[
          const SizedBox(height: 8),
          Text(guidanceNote, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ],
      ]),
    );
  }

  Widget _buildChipRow({
    required String label,
    required List<Map<String, String>> options,
    required String selected,
    required void Function(String) onSelect,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final s = selected == opt['code'];
          return ChoiceChip(
            label: Text(
              opt['label']!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: s ? FontWeight.w700 : FontWeight.w500,
                color: s ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
            ),
            selected: s,
            selectedColor: AppColors.surfaceWarm,
            backgroundColor: Colors.white,
            side: BorderSide(color: s ? AppColors.forestPrimary : AppColors.borderSoft, width: s ? 2 : 1),
            onSelected: (_) => setState(() => onSelect(opt['code']!)),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildFilterRow({
    required String label,
    required List<String> options,
    required Set<String> selected,
    required void Function(String, bool) onSelect,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final s = selected.contains(opt);
          return FilterChip(
            label: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: s ? FontWeight.w700 : FontWeight.w500,
                color: s ? AppColors.forestPrimary : AppColors.textSecondary,
              ),
            ),
            selected: s,
            selectedColor: AppColors.surfaceWarm,
            backgroundColor: Colors.white,
            side: BorderSide(color: s ? AppColors.forestPrimary : AppColors.borderSoft, width: s ? 2 : 1),
            onSelected: (v) => setState(() => onSelect(opt, v)),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('General Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      const Text('Speak or type. We pick out the key details automatically.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
      const SizedBox(height: 20),
      _buildInputCard(
        question: 'What is your loved ones name, age, and hometown?',
        hint: 'e.g. Bonti Baruah, 72 years old, from Tezpur Assam',
        controller: _nameController,
        fieldId: 1,
        questionType: ProfileQuestion.generalInfo,
        guidanceNote: 'Speaking naturally fills all fields at once.',
      ),
      const SizedBox(height: 16),
      _buildChipRow(
        label: 'Age Range',
        options: [
          {'code': '60-69 years', 'label': '60-69'},
          {'code': '70-79 years', 'label': '70-79'},
          {'code': '80-89 years', 'label': '80-89'},
          {'code': '90+ years', 'label': '90+'},
        ],
        selected: _selectedAgeRange,
        onSelect: (v) => _selectedAgeRange = v,
      ),
      const SizedBox(height: 16),
      _buildChipRow(
        label: 'Your Relationship to Them',
        options: [
          {'code': 'Daughter', 'label': 'Daughter'},
          {'code': 'Son', 'label': 'Son'},
          {'code': 'Spouse', 'label': 'Spouse'},
          {'code': 'Grandchild', 'label': 'Grandchild'},
          {'code': 'Nurse / Caregiver', 'label': 'Nurse / Caregiver'},
        ],
        selected: _selectedRelationship,
        onSelect: (v) => _selectedRelationship = v,
      ),
      const SizedBox(height: 16),
      _buildInputCard(
        question: 'Where is their familiar hometown or a cherished place?',
        hint: 'e.g. Tezpur Assam or near the Brahmaputra river',
        controller: _hometownController,
        fieldId: 11,
        questionType: ProfileQuestion.generalInfo,
        maxLines: 1,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: ['Tezpur', 'Guwahati', 'Jorhat', 'Dibrugarh', 'Shillong', 'Kolkata']
            .map((p) => ActionChip(
                  label: Text(p, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.borderSoft),
                  onPressed: () => setState(() => _hometownController.text = p),
                ))
            .toList(),
      ),
    ]);
  }

  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Abilities, Preferences and Observations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      const Text('Describe comforts and favourites. Chips update automatically from your words.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
      const SizedBox(height: 20),
      _buildInputCard(
        question: 'What does your loved one enjoy? What brings them comfort?',
        hint: 'e.g. She loves morning tea on veranda, flute music, looking at old family photos and pitha sweets',
        controller: _prefsController,
        fieldId: 2,
        questionType: ProfileQuestion.abilitiesPrefs,
        maxLines: 3,
        guidanceNote: 'Your words are analysed to personalise activities. Just speak or type naturally.',
      ),
      const SizedBox(height: 16),
      _buildChipRow(
        label: 'Reading and Text Comfort',
        options: [
          {'code': 'prefers_large_text', 'label': 'Needs large text'},
          {'code': 'prefers_spoken_only', 'label': 'Voice is best'},
          {'code': 'fluent', 'label': 'Reads comfortably'},
          {'code': 'unsure', 'label': 'Unsure'},
        ],
        selected: _readingComfort,
        onSelect: (v) => _readingComfort = v,
      ),
      const SizedBox(height: 14),
      _buildChipRow(
        label: 'Hearing Support',
        options: [
          {'code': 'normal', 'label': 'Clear hearing'},
          {'code': 'uses_hearing_aid', 'label': 'Uses hearing aid'},
          {'code': 'needs_high_volume', 'label': 'Needs high volume'},
          {'code': 'unsure', 'label': 'Unsure'},
        ],
        selected: _hearingSupport,
        onSelect: (v) => _hearingSupport = v,
      ),
      const SizedBox(height: 14),
      _buildChipRow(
        label: 'Touch and Screen Mobility',
        options: [
          {'code': 'accurate_tap', 'label': 'Standard tap'},
          {'code': 'gentle_broad_tap', 'label': 'Broad gentle tap'},
          {'code': 'tremor_support_needed', 'label': 'Tremor support'},
          {'code': 'unsure', 'label': 'Unsure'},
        ],
        selected: _touchMobility,
        onSelect: (v) => _touchMobility = v,
      ),
      const SizedBox(height: 14),
      _buildFilterRow(
        label: 'Beloved Music (auto-detected, tap to add more)',
        options: const [
          'Borgeet Flute',
          'Rabindra Sangeet',
          'Bihu Folk Melodies',
          'Old Hindi Classics',
          'Bhajan / Kirtan',
          'Devotional Bhajans',
        ],
        selected: _selectedMusic,
        onSelect: (item, val) {
          if (val) {
            _selectedMusic.add(item);
          } else {
            _selectedMusic.remove(item);
          }
        },
      ),
      const SizedBox(height: 14),
      _buildFilterRow(
        label: 'Cherished Places and Foods (auto-detected, tap to add more)',
        options: const [
          'Assam Tea Gardens',
          'Veranda Swing',
          'Brahmaputra River',
          'Pitha and Laru',
          'Masor Tenga',
          'Assam Chai',
        ],
        selected: _selectedPlaces,
        onSelect: (item, val) {
          if (val) {
            _selectedPlaces.add(item);
          } else {
            _selectedPlaces.remove(item);
          }
        },
      ),
    ]);
  }

  Widget _buildStep3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Routines, Doctor Advice and Medications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      const Text('Describe their daily rhythm and any doctor guidance. We use this to pace activities gently.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
      const SizedBox(height: 20),
      _buildInputCard(
        question: 'Describe their daily routine and any doctor or clinician advice.',
        hint: 'e.g. Morning tea at 8, afternoon nap, evening prayers. Doctor says avoid rushing, keep hydrated, 10mg Aricept at night',
        controller: _routinesController,
        fieldId: 3,
        questionType: ProfileQuestion.routinesMeds,
        maxLines: 4,
        guidanceNote: 'Mentioning medications by name will add them to the caregiver medication reminder list.',
      ),
      const SizedBox(height: 16),
      _buildChipRow(
        label: 'Best Time for Activities',
        options: const [
          {'code': 'Morning (9 AM - 11 AM)', 'label': 'Morning'},
          {'code': 'Afternoon (3 PM - 5 PM)', 'label': 'Afternoon'},
          {'code': 'Evening (6 PM - 8 PM)', 'label': 'Evening'},
        ],
        selected: _preferredTime,
        onSelect: (v) => _preferredTime = v,
      ),
      const SizedBox(height: 14),
      _buildFilterRow(
        label: 'Daily Routine Anchors (auto-detected, tap to add more)',
        options: const [
          'Morning Assam tea on veranda',
          'Afternoon quiet rest',
          'Evening family prayer',
          'Garden walk',
          'Listening to morning radio',
          'Watching evening news',
        ],
        selected: _selectedRoutineAnchors,
        onSelect: (item, val) {
          if (val) {
            _selectedRoutineAnchors.add(item);
          } else {
            _selectedRoutineAnchors.remove(item);
          }
        },
      ),
      const SizedBox(height: 14),
      _buildChipRow(
        label: 'Caregiver Presence',
        options: const [
          {'code': 'Always present with loved one', 'label': 'Always with them'},
          {'code': 'Evenings & Weekends', 'label': 'Evenings and Weekends'},
          {'code': 'Occasional check-in', 'label': 'Occasional check-in'},
        ],
        selected: _caregiverAvailability,
        onSelect: (v) => _caregiverAvailability = v,
      ),
    ]);
  }

  Widget _buildCompletion() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Loved One';
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.forestPrimary.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestPrimary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite_rounded, color: AppColors.forestPrimary, size: 48),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.get('profile_complete_title'), style: AppTypography.patientHero.copyWith(fontSize: 26, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(AppStrings.get('profile_complete_subtitle'), style: AppTypography.caregiverBody.copyWith(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            CalmCard(
              backgroundColor: Colors.white,
              borderColor: AppColors.forestPrimary.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                _summaryRow(Icons.person, 'Profile: $name ($_selectedAgeRange)'),
                const Divider(height: 18),
                _summaryRow(Icons.music_note, 'Music: ${_selectedMusic.take(2).join(', ')}'),
                const SizedBox(height: 8),
                _summaryRow(Icons.wb_sunny_outlined, 'Best time: $_preferredTime'),
                const SizedBox(height: 8),
                _summaryRow(Icons.place_outlined, 'From: ${_hometownController.text}'),
              ]),
            ),
            const SizedBox(height: 32),
            ElderButton(
              label: AppStrings.get('start_todays_journey'),
              icon: Icons.play_arrow_rounded,
              variant: ElderButtonVariant.primary,
              height: 56,
              onPressed: _saveAndFinish,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String text) => Row(children: [
        Icon(icon, color: AppColors.forestPrimary, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary))),
      ]);

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 4) {
      return _buildCompletion();
    }

    final isGuideMode = VoiceAssistantService.instance.isGuideMode;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.forestPrimary, size: 26),
          tooltip: 'Back',
          onPressed: _previousStep,
        ),
        title: Text(
          'Step $_currentStep of 3',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isGuideMode)
            Tooltip(
              message: 'Voice Guidance Active',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forestPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.forestPrimary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded, color: AppColors.forestPrimary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Voice ON',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const LanguageToggleWidget(compact: true),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [1, 2, 3].map((step) {
                  final active = step <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active ? AppColors.forestPrimary : AppColors.borderSoft,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _currentStep == 1
                    ? _buildStep1()
                    : _currentStep == 2
                        ? _buildStep2()
                        : _buildStep3(),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    Expanded(
                      flex: 1,
                      child: ElderButton(
                        label: 'Back',
                        variant: ElderButtonVariant.peach,
                        height: 52,
                        onPressed: _previousStep,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElderButton(
                      label: _currentStep == 3 ? 'Finish & Create Profile' : 'Continue',
                      icon: _currentStep == 3 ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                      variant: ElderButtonVariant.primary,
                      height: 52,
                      onPressed: _nextStep,
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
}
