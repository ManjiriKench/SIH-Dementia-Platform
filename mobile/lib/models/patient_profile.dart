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

  // Extended Personal & Familiar Context
  final List<String> familiarPeople; // e.g. ["Priyanka (Daughter)", "Grandchildren"]
  final List<String> familiarPlaces; // e.g. ["Tezpur Riverside", "Veranda Swing"]
  final List<String> importantMemories; // e.g. ["Bihu Festival", "Family Tea Garden Trips"]
  final List<String> personalityTraits; // e.g. ["Gentle & Observant", "Loves Music"]
  final String? doctorRecommendations; // e.g. "Encourage unpaced relaxation, avoid time pressure"

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
    this.familiarPeople = const ['Priyanka (Daughter)', 'Arup (Son)'],
    this.familiarPlaces = const ['Tezpur Riverside', 'Veranda Swing'],
    this.importantMemories = const ['Magh Bihu Feast', 'Tezpur Home'],
    this.personalityTraits = const ['Gentle & Observant', 'Nature Lover'],
    this.doctorRecommendations,
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
    List<String>? familiarPeople,
    List<String>? familiarPlaces,
    List<String>? importantMemories,
    List<String>? personalityTraits,
    String? doctorRecommendations,
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
      familiarPeople: familiarPeople ?? this.familiarPeople,
      familiarPlaces: familiarPlaces ?? this.familiarPlaces,
      importantMemories: importantMemories ?? this.importantMemories,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      doctorRecommendations: doctorRecommendations ?? this.doctorRecommendations,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'preferredName': preferredName,
    'ageRange': ageRange,
    'preferredLanguage': preferredLanguage,
    'relationshipToCaregiver': relationshipToCaregiver,
    'profilePhotoUrl': profilePhotoUrl,
    'readingComfort': readingComfort,
    'hearingSupport': hearingSupport,
    'visualSupport': visualSupport,
    'speechComfort': speechComfort,
    'touchMobility': touchMobility,
    'independentPlay': independentPlay,
    'attentionSpan': attentionSpan,
    'areasToSupport': areasToSupport.map((e) => e.name).toList(),
    'safeActivityTypes': safeActivityTypes,
    'activitiesToAvoid': activitiesToAvoid,
    'interestsAndHobbies': interestsAndHobbies,
    'favoriteMusicGenres': favoriteMusicGenres,
    'familiarPlacesAndFoods': familiarPlacesAndFoods,
    'interactionStyle': interactionStyle,
    'preferredTimeOfDay': preferredTimeOfDay,
    'dailyRoutineAnchors': dailyRoutineAnchors,
    'caregiverAvailability': caregiverAvailability,
    'recentMoodTags': recentMoodTags,
    'observationNote': observationNote,
    'whatHelpedNote': whatHelpedNote,
    'familiarPeople': familiarPeople,
    'familiarPlaces': familiarPlaces,
    'importantMemories': importantMemories,
    'personalityTraits': personalityTraits,
    'doctorRecommendations': doctorRecommendations,
    'isComplete': isComplete,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String? ?? 'pat_default',
      preferredName: json['preferredName'] as String? ?? 'Bonti Baruah',
      ageRange: json['ageRange'] as String? ?? '70-79 years',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      relationshipToCaregiver: json['relationshipToCaregiver'] as String? ?? 'Caregiver',
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      readingComfort: json['readingComfort'] as String? ?? 'prefers_large_text',
      hearingSupport: json['hearingSupport'] as String? ?? 'normal',
      visualSupport: json['visualSupport'] as String? ?? 'large_elements_needed',
      speechComfort: json['speechComfort'] as String? ?? 'expressive',
      touchMobility: json['touchMobility'] as String? ?? 'gentle_broad_tap',
      independentPlay: json['independentPlay'] as String? ?? 'gentle_supervision',
      attentionSpan: json['attentionSpan'] as String? ?? '5_10_minutes',
      areasToSupport: (json['areasToSupport'] as List<dynamic>?)
              ?.map((e) => CognitiveDomainType.values.firstWhere(
                    (t) => t.name == e.toString(),
                    orElse: () => CognitiveDomainType.memory,
                  ))
              .toList() ??
          const [CognitiveDomainType.memory, CognitiveDomainType.orientation],
      safeActivityTypes: (json['safeActivityTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['matching', 'music_listening', 'photo_stories'],
      activitiesToAvoid: (json['activitiesToAvoid'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['fast_timers', 'complex_spelling'],
      interestsAndHobbies: (json['interestsAndHobbies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Gardening', 'Classical Songs'],
      favoriteMusicGenres: (json['favoriteMusicGenres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Rabindra Sangeet', 'Old Classics'],
      familiarPlacesAndFoods: (json['familiarPlacesAndFoods'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Veranda Swing', 'Chai'],
      interactionStyle: json['interactionStyle'] as String? ?? 'warm_and_guided',
      preferredTimeOfDay: json['preferredTimeOfDay'] as String? ?? 'Morning (9 AM - 11 AM)',
      dailyRoutineAnchors: (json['dailyRoutineAnchors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Morning Assam chai', 'Evening prayers'],
      caregiverAvailability: json['caregiverAvailability'] as String? ?? 'Evenings only',
      recentMoodTags: (json['recentMoodTags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['calm', 'engaged'],
      observationNote: json['observationNote'] as String?,
      whatHelpedNote: json['whatHelpedNote'] as String?,
      familiarPeople: (json['familiarPeople'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Priyanka (Daughter)', 'Arup (Son)'],
      familiarPlaces: (json['familiarPlaces'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Tezpur Riverside', 'Veranda Swing'],
      importantMemories: (json['importantMemories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Family Tea Garden Trips'],
      personalityTraits: (json['personalityTraits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Gentle & Observant'],
      doctorRecommendations: json['doctorRecommendations'] as String?,
      isComplete: json['isComplete'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
