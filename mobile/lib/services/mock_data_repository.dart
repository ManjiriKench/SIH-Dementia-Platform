import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/navigation/app_routes.dart';
import '../models/activity_item.dart';
import '../models/caregiver_feedback.dart';
import '../models/cognitive_domain.dart';
import '../models/dashboard_data.dart';
import '../models/memory_item.dart';
import '../models/patient_profile.dart';

/// Rich mock data repository infused with authentic North Eastern Indian
/// and familiar cultural anchors (Assam tea gardens, folk melodies, regional crafts).
class MockDataRepository {
  MockDataRepository._();

  static PatientProfile createSamplePatient() {
    return PatientProfile(
      id: 'patient_bonti_01',
      preferredName: 'Bonti Baruah',
      ageRange: '70-75 years',
      preferredLanguage: 'en',
      relationshipToCaregiver: 'Daughter (Priyanka)',
      profilePhotoUrl: null,
      readingComfort: 'prefers_large_text',
      hearingSupport: 'uses_hearing_aid',
      visualSupport: 'large_elements_needed',
      speechComfort: 'expressive',
      touchMobility: 'gentle_broad_tap',
      independentPlay: 'gentle_supervision',
      attentionSpan: '5_10_minutes',
      areasToSupport: const [
        CognitiveDomainType.memory,
        CognitiveDomainType.orientation,
        CognitiveDomainType.attention,
      ],
      safeActivityTypes: const [
        'matching_nature',
        'music_listening',
        'photo_conversation',
        'routine_sorting'
      ],
      activitiesToAvoid: const ['time_pressure', 'rapid_flashing'],
      interestsAndHobbies: const [
        'Assam Tea Gardens',
        'Traditional Weaving',
        'Morning Garden Walks',
        'Rabindra Sangeet'
      ],
      favoriteMusicGenres: const [
        'Borgeet Flute',
        'Rabindra Sangeet',
        'Old Hindi Classics'
      ],
      familiarPlacesAndFoods: const [
        'Tezpur Ghats',
        'Assam Chai',
        'Pitha & Laru',
        'Veranda Swing'
      ],
      interactionStyle: 'warm_and_guided',
      preferredTimeOfDay: 'Morning (9 AM - 11 AM)',
      dailyRoutineAnchors: const [
        'Morning Assam tea on veranda',
        'Listening to morning radio',
        'Evening family prayers'
      ],
      caregiverAvailability: 'Evenings & Weekends',
      recentMoodTags: const ['calm', 'engaged'],
      observationNote: 'Smiles warmly when hearing familiar songs from Tezpur.',
      whatHelpedNote: 'Allowing unhurried time to touch and explore each card.',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    );
  }

  static List<ActivityItem> getCatalogActivities() {
    return [
      const ActivityItem(
        id: 'act_nature_match',
        title: 'Heritage & Nature Match',
        patientFriendlyTitle: 'Familiar Nature Match',
        subtitle: 'Notice and pair gentle leaves, flowers, and traditional brass lamps.',
        domain: CognitiveDomainType.visuospatial,
        modality: ActivityModality.independent,
        difficultyLabel: 'Gentle',
        estimatedDurationMinutes: 3,
        requiresCaregiver: false,
        supportsPersonalizedMedia: false,
        supportsAudioGuidance: true,
        culturalTags: ['Tea Leaf', 'Diya', 'Lotus', 'Bells'],
        icon: Icons.filter_vintage_outlined,
        themeColor: AppColors.domainVisuospatial,
        routeName: AppRoutes.independentMatch,
      ),
      const ActivityItem(
        id: 'act_family_together',
        title: 'Cherished Family & Milestones',
        patientFriendlyTitle: 'Family Photos Together',
        subtitle: 'Look at familiar faces together with gentle hints and storytelling prompts.',
        domain: CognitiveDomainType.memory,
        modality: ActivityModality.cognitiveTogether,
        difficultyLabel: 'Gentle Guided',
        estimatedDurationMinutes: 5,
        requiresCaregiver: true,
        supportsPersonalizedMedia: true,
        supportsAudioGuidance: true,
        culturalTags: ['Family Moments', 'Tezpur Home', 'Grandchildren'],
        icon: Icons.people_outline,
        themeColor: AppColors.domainMemory,
        routeName: AppRoutes.cognitiveTogether,
      ),
      const ActivityItem(
        id: 'act_listen_remember',
        title: 'Listen & Remember — Gentle Melodies',
        patientFriendlyTitle: 'Heartfelt Melodies',
        subtitle: 'Relax with soothing flute music and nostalgic conversation cues.',
        domain: CognitiveDomainType.language,
        modality: ActivityModality.connectionTogether,
        difficultyLabel: 'Relaxed',
        estimatedDurationMinutes: 6,
        requiresCaregiver: false,
        supportsPersonalizedMedia: true,
        supportsAudioGuidance: true,
        culturalTags: ['Borgeet', 'Flute', 'Old Melodies'],
        icon: Icons.music_note_outlined,
        themeColor: AppColors.domainLanguage,
        routeName: AppRoutes.connectionMusic,
      ),
      const ActivityItem(
        id: 'act_morning_sequence',
        title: 'Daily Tea & Morning Rituals',
        patientFriendlyTitle: 'Morning Tea Routine',
        subtitle: 'Sort the gentle steps of preparing morning Assam tea.',
        domain: CognitiveDomainType.executive,
        modality: ActivityModality.independent,
        difficultyLabel: 'Gentle',
        estimatedDurationMinutes: 4,
        requiresCaregiver: false,
        culturalTags: ['Tea Leaves', 'Kettle', 'Morning Sunshine'],
        icon: Icons.emoji_food_beverage_outlined,
        themeColor: AppColors.domainExecutive,
        routeName: AppRoutes.independentMatch,
      ),
    ];
  }

  static List<MemoryItem> getSampleMemories() {
    return [
      MemoryItem(
        id: 'mem_01',
        title: 'Grandmother’s Veranda in Tezpur',
        type: MemoryType.place,
        relationOrContext: 'Where she loved having morning ginger chai looking at the garden.',
        iconOrImagePath: 'assets/images/veranda.jpg',
        tags: ['Home', 'Tezpur', 'Garden'],
        allowedUsage: ['recognition', 'conversation'],
        dateAdded: DateTime.now().subtract(const Duration(days: 10)),
      ),
      MemoryItem(
        id: 'mem_02',
        title: 'Priyanka’s College Graduation',
        type: MemoryType.photo,
        relationOrContext: 'With granddaughter Priyanka wearing the muga silk sari.',
        iconOrImagePath: 'assets/images/graduation.jpg',
        tags: ['Family', 'Milestone', 'Priyanka'],
        allowedUsage: ['recognition', 'conversation'],
        dateAdded: DateTime.now().subtract(const Duration(days: 8)),
      ),
      MemoryItem(
        id: 'mem_03',
        title: 'Golden Assam Tea Harvest Song',
        type: MemoryType.music,
        relationOrContext: 'Traditional folk flute melody played during autumn.',
        tags: ['Music', 'Flute', 'Autumn'],
        allowedUsage: ['music_together', 'conversation'],
        dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      ),
      MemoryItem(
        id: 'mem_04',
        title: 'Making Til Pitha on Magh Bihu',
        type: MemoryType.story,
        relationOrContext: 'Gathering around the kitchen fire in January to roll sweet sesame pithas.',
        tags: ['Festival', 'Bihu', 'Tradition'],
        allowedUsage: ['conversation'],
        dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  static DashboardData getSampleDashboardData(String patientName) {
    return DashboardData(
      patientName: patientName,
      completedTodayCount: 2,
      targetDailyActivities: 3,
      pendingFeedbackCount: 1,
      recommendedNextActivities: getCatalogActivities().take(2).toList(),
      weeklyConsistency: const [
        DailyContextPoint(
          dayLabel: 'Mon',
          completedActivitiesCount: 2,
          engagementLevel: 4.2,
          primaryMood: 'calm',
          hadTogetherSession: true,
          hadMusicActivity: false,
        ),
        DailyContextPoint(
          dayLabel: 'Tue',
          completedActivitiesCount: 3,
          engagementLevel: 4.8,
          primaryMood: 'joyful',
          hadTogetherSession: true,
          hadMusicActivity: true,
        ),
        DailyContextPoint(
          dayLabel: 'Wed',
          completedActivitiesCount: 2,
          engagementLevel: 3.5,
          primaryMood: 'tired',
          hadTogetherSession: false,
          hadMusicActivity: true,
        ),
        DailyContextPoint(
          dayLabel: 'Thu',
          completedActivitiesCount: 3,
          engagementLevel: 4.6,
          primaryMood: 'engaged',
          hadTogetherSession: true,
          hadMusicActivity: false,
        ),
        DailyContextPoint(
          dayLabel: 'Fri',
          completedActivitiesCount: 2,
          engagementLevel: 4.0,
          primaryMood: 'calm',
          hadTogetherSession: false,
          hadMusicActivity: true,
        ),
        DailyContextPoint(
          dayLabel: 'Sat',
          completedActivitiesCount: 3,
          engagementLevel: 4.9,
          primaryMood: 'joyful',
          hadTogetherSession: true,
          hadMusicActivity: true,
        ),
        DailyContextPoint(
          dayLabel: 'Sun (Today)',
          completedActivitiesCount: 2,
          engagementLevel: 4.5,
          primaryMood: 'calm',
          hadTogetherSession: true,
          hadMusicActivity: true,
        ),
      ],
      domainExposure: const [
        DomainExposureMetric(
          domain: CognitiveDomainType.memory,
          domainName: 'Memory & Recognition',
          sessionsCountThisWeek: 5,
          comfortSummary: 'Comfortable with family photos & familiar places',
        ),
        DomainExposureMetric(
          domain: CognitiveDomainType.attention,
          domainName: 'Attention & Focus',
          sessionsCountThisWeek: 4,
          comfortSummary: 'Unhurried focus during morning hours',
        ),
        DomainExposureMetric(
          domain: CognitiveDomainType.language,
          domainName: 'Language & Communication',
          sessionsCountThisWeek: 6,
          comfortSummary: 'Shared pleasant memories during music time',
        ),
        DomainExposureMetric(
          domain: CognitiveDomainType.executive,
          domainName: 'Executive Function',
          sessionsCountThisWeek: 3,
          comfortSummary: 'Gentle routine sequencing was well-received',
        ),
        DomainExposureMetric(
          domain: CognitiveDomainType.orientation,
          domainName: 'Orientation & Daily Context',
          sessionsCountThisWeek: 4,
          comfortSummary: 'Recognized morning tea & evening prayer anchors',
        ),
        DomainExposureMetric(
          domain: CognitiveDomainType.visuospatial,
          domainName: 'Visuospatial Skills',
          sessionsCountThisWeek: 4,
          comfortSummary: 'High comfort with nature & flower matching',
        ),
      ],
      recentFeedback: [
        CaregiverFeedback(
          id: 'fb_01',
          sessionId: 'sess_prev_01',
          patientId: 'patient_bonti_01',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          observationTags: const ['calm', 'engaged'],
          comfortRating: 'yes',
          whatHelped: 'Recognized the photo of Tezpur river ghat and smiled.',
          transcriptionText: 'She seemed peaceful and enjoyed pointing at the water.',
          enjoyedMusicOrMemory: true,
          recommendationPreference: 'keep_similar',
          syncStatus: SyncStatus.synced,
        ),
      ],
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
    );
  }
}
