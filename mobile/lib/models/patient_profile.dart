import 'cognitive_domain.dart';

/// Comprehensive patient profile capturing baseline abilities, preferences,
/// routines, and caregiver observations without diagnostic labeling.
class PatientProfile {
  final String id;
  
  // Basic Information
  final String preferredName;
  final String ageRange; // e.g. "65-74 years", "75-84 years", "85+"
  final String preferredLanguage; // 'en', 'hi', 'as'
  final String relationshipToCaregiver; // e.g. "Daughter", "Son", "Spouse", "Nurse"
  final String? profilePhotoUrl;

  // Baseline Abilities & Support Needs (Non-diagnostic, caregiver-informed)
  final String readingComfort; // 'fluent', 'prefers_large_text', 'prefers_spoken_only', 'unsure'
  final String hearingSupport; // 'normal', 'uses_hearing_aid', 'needs_high_volume', 'unsure'
  final String visualSupport;  // 'standard', 'high_contrast_needed', 'large_elements_needed', 'unsure'
  final String speechComfort;  // 'expressive', 'prefers_short_words', 'mostly_listening', 'unsure'
  final String touchMobility;  // 'accurate_tap', 'gentle_broad_tap', 'tremor_support_needed', 'unsure'
  final String independentPlay;// 'fully_independent', 'gentle_supervision', 'together_only', 'unsure'
  final String attentionSpan;  // '3_5_minutes', '5_10_minutes', 'relaxed_unpaced', 'unsure'
  final List<CognitiveDomainType> areasToSupport;
  final List<String> safeActivityTypes;
  final List<String> activitiesToAvoid;

  // Preferences & Cultural Anchors
  final List<String> interestsAndHobbies; // e.g. "Gardening", "Assam Tea Culture", "Cooking", "Textiles"
  final List<String> favoriteMusicGenres; // e.g. "Borgeet", "Rabindra Sangeet", "Old Hindi Melodies", "Flute"
  final List<String> familiarPlacesAndFoods;// e.g. "Guwahati Ghats", "Pitha", "Masor Tenga", "Chai at veranda"
  final String interactionStyle; // 'quiet', 'warm_and_guided', 'music_centered', 'conversational'

  // Routines & Daily Anchors
  final String preferredTimeOfDay; // 'Morning (9 AM - 11 AM)', 'Afternoon (3 PM - 5 PM)', 'Evening'
  final List<String> dailyRoutineAnchors; // e.g. "Morning chai", "Evening prayer", "Veranda walk"
  final String caregiverAvailability; // 'Always present', 'Evenings only', 'Weekends'

  // Recent Observations
  final List<String> recentMoodTags; // 'calm', 'engaged', 'tired', 'anxious', 'quiet', 'withdrawn'
  final String? observationNote;
  final String? whatHelpedNote;

  // Metadata
  final bool isComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientProfile({
    required this.id,
    required this.preferredName,
    required this.ageRange,
    this.preferredLanguage = 'en',
    required this.relationshipToCaregiver,
    this.profilePhotoUrl,
    this.readingComfort = 'prefers_large_text',
    this.hearingSupport = 'normal',
    this.visualSupport = 'large_elements_needed',
    this.speechComfort = 'expressive',
    this.touchMobility = 'gentle_broad_tap',
    this.independentPlay = 'gentle_supervision',
    this.attentionSpan = '5_10_minutes',
    this.areasToSupport = const [
      CognitiveDomainType.memory,
      CognitiveDomainType.orientation,
    ],
    this.safeActivityTypes = const ['matching', 'music_listening', 'photo_stories'],
    this.activitiesToAvoid = const ['fast_timers', 'complex_spelling'],
    this.interestsAndHobbies = const ['Assam Tea Gardens', 'Gardening', 'Classical Songs'],
    this.favoriteMusicGenres = const ['Rabindra Sangeet', 'Bihu Folk Melodies', 'Old Classics'],
    this.familiarPlacesAndFoods = const ['Brahmaputra Riverside', 'Pitha', 'Masor Tenga'],
    this.interactionStyle = 'warm_and_guided',
    this.preferredTimeOfDay = 'Morning (9 AM - 11 AM)',
    this.dailyRoutineAnchors = const ['Morning Assam chai', 'Evening prayers', 'Garden walk'],
    this.caregiverAvailability = 'Evenings only',
    this.recentMoodTags = const ['calm', 'engaged'],
    this.observationNote,
    this.whatHelpedNote = 'Listening to soft flute music and looking at old photographs together brings a smile.',
    this.isComplete = true,
    required this.createdAt,
    required this.updatedAt,
  });

  PatientProfile copyWith({
    String? preferredName,
    String? ageRange,
    String? preferredLanguage,
    String? relationshipToCaregiver,
    String? profilePhotoUrl,
    String? readingComfort,
    String? hearingSupport,
    String? visualSupport,
    String? speechComfort,
    String? touchMobility,
    String? independentPlay,
    String? attentionSpan,
    List<CognitiveDomainType>? areasToSupport,
    List<String>? safeActivityTypes,
    List<String>? activitiesToAvoid,
    List<String>? interestsAndHobbies,
    List<String>? favoriteMusicGenres,
    List<String>? familiarPlacesAndFoods,
    String? interactionStyle,
    String? preferredTimeOfDay,
    List<String>? dailyRoutineAnchors,
    String? caregiverAvailability,
    List<String>? recentMoodTags,
    String? observationNote,
    String? whatHelpedNote,
    bool? isComplete,
  }) {
    return PatientProfile(
      id: id,
      preferredName: preferredName ?? this.preferredName,
      ageRange: ageRange ?? this.ageRange,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      relationshipToCaregiver: relationshipToCaregiver ?? this.relationshipToCaregiver,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      readingComfort: readingComfort ?? this.readingComfort,
      hearingSupport: hearingSupport ?? this.hearingSupport,
      visualSupport: visualSupport ?? this.visualSupport,
      speechComfort: speechComfort ?? this.speechComfort,
      touchMobility: touchMobility ?? this.touchMobility,
      independentPlay: independentPlay ?? this.independentPlay,
      attentionSpan: attentionSpan ?? this.attentionSpan,
      areasToSupport: areasToSupport ?? this.areasToSupport,
      safeActivityTypes: safeActivityTypes ?? this.safeActivityTypes,
      activitiesToAvoid: activitiesToAvoid ?? this.activitiesToAvoid,
      interestsAndHobbies: interestsAndHobbies ?? this.interestsAndHobbies,
      favoriteMusicGenres: favoriteMusicGenres ?? this.favoriteMusicGenres,
      familiarPlacesAndFoods: familiarPlacesAndFoods ?? this.familiarPlacesAndFoods,
      interactionStyle: interactionStyle ?? this.interactionStyle,
      preferredTimeOfDay: preferredTimeOfDay ?? this.preferredTimeOfDay,
      dailyRoutineAnchors: dailyRoutineAnchors ?? this.dailyRoutineAnchors,
      caregiverAvailability: caregiverAvailability ?? this.caregiverAvailability,
      recentMoodTags: recentMoodTags ?? this.recentMoodTags,
      observationNote: observationNote ?? this.observationNote,
      whatHelpedNote: whatHelpedNote ?? this.whatHelpedNote,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
