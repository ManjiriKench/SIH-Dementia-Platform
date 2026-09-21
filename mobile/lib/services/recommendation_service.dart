import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_item.dart';
import '../models/ai_recommendation.dart';
import '../models/cognitive_domain.dart';
import 'mock_data_repository.dart';

/// Tracks elder interaction metrics per activity (non-punitive, for caregiver insights).
class ActivityScore {
  final String activityId;
  final String activityTitle;
  int correct;
  int skipped;
  int totalPlayed;

  ActivityScore({
    required this.activityId,
    required this.activityTitle,
    this.correct = 0,
    this.skipped = 0,
    this.totalPlayed = 0,
  });

  double get accuracy => totalPlayed > 0 ? (correct / totalPlayed) * 100 : 0;
  double get skipRate => totalPlayed > 0 ? (skipped / totalPlayed) * 100 : 0;

  String get engagementLevel {
    if (totalPlayed == 0) return 'Untested';
    if (skipRate > 40) return 'Challenging / Needs Support';
    if (accuracy >= 70) return 'High Comfort & Flow';
    return 'Moderate Comfort';
  }

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'activityTitle': activityTitle,
    'correct': correct,
    'skipped': skipped,
    'totalPlayed': totalPlayed,
  };

  factory ActivityScore.fromJson(Map<String, dynamic> json) => ActivityScore(
    activityId: json['activityId'] as String? ?? '',
    activityTitle: json['activityTitle'] as String? ?? '',
    correct: json['correct'] as int? ?? 0,
    skipped: json['skipped'] as int? ?? 0,
    totalPlayed: json['totalPlayed'] as int? ?? 0,
  );
}

/// Caregiver-only insight model summarizing domain engagement.
class ActivityInsight {
  final String activityTitle;
  final String engagementLevel;
  final double skipRate;
  final int totalPlayed;
  final String recommendationNote;

  const ActivityInsight({
    required this.activityTitle,
    required this.engagementLevel,
    required this.skipRate,
    required this.totalPlayed,
    required this.recommendationNote,
  });
}

/// Service managing AI recommendations, 6-domain support priorities,
/// simulation of multi-step processing states, adaptive activity counts, and caregiver overrides.
class RecommendationService extends ChangeNotifier {
  static final RecommendationService instance = RecommendationService._internal();
  RecommendationService._internal() {
    _loadSessionStats();
    _seedInitialScores();
  }

  static const String _prefKeySessions = 'smriti_total_sessions';
  static const String _prefKeyScores = 'smriti_activity_scores';

  AiRecommendation? _currentRecommendation;
  bool _isProcessing = false;
  int _totalSessionsCompleted = 1;
  final Map<String, ActivityScore> _activityScores = {};

  AiRecommendation? get currentRecommendation => _currentRecommendation;
  bool get isProcessing => _isProcessing;
  int get totalSessionsCompleted => _totalSessionsCompleted;
  Map<String, ActivityScore> get activityScores => Map.unmodifiable(_activityScores);

  String _activeDifficulty = 'Gentle';
  String? _lastCaregiverMood;
  bool _isNoGameRecommended = false;
  String _gentleAlternativeTitle = 'Quiet River Soundscape & Memories';
  String _gentleAlternativeDescription = 'Rest gently by the sound of Tezpur river waters and look at beloved family photographs.';

  String get activeDifficulty => _activeDifficulty;
  String? get lastCaregiverMood => _lastCaregiverMood;
  bool get isNoGameRecommended => _isNoGameRecommended;
  String get gentleAlternativeTitle => _gentleAlternativeTitle;
  String get gentleAlternativeDescription => _gentleAlternativeDescription;

  /// Loads persisted session count and scores from disk.
  Future<void> _loadSessionStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalSessionsCompleted = prefs.getInt(_prefKeySessions) ?? 1;
      final scoresJson = prefs.getString(_prefKeyScores);
      if (scoresJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(scoresJson) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          _activityScores[key] = ActivityScore.fromJson(val as Map<String, dynamic>);
        });
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[RecommendationService] Error loading stats: $e');
    }
  }

  /// Increments completed session count and updates recommendation capacity.
  Future<void> incrementSessionCount() async {
    _totalSessionsCompleted++;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeySessions, _totalSessionsCompleted);
    } catch (e) {
      debugPrint('[RecommendationService] Error saving sessions: $e');
    }
  }

  /// Calculates max recommended activities for today based on elder journey maturity.
  /// 0 sessions -> 3 activities
  /// 1 to 4 sessions -> 4 activities
  /// 5+ sessions -> full catalog (up to 8)
  int getTodaysRecommendedCount() {
    if (_totalSessionsCompleted <= 0) return 3;
    if (_totalSessionsCompleted < 5) return 4;
    return 8;
  }

  /// Records an interaction attempt for an activity to refine recommendations.
  Future<void> recordActivityAttempt(
    String activityId,
    String activityTitle, {
    required bool isCorrect,
    required bool isSkipped,
  }) async {
    final existing = _activityScores.putIfAbsent(
      activityId,
      () => ActivityScore(activityId: activityId, activityTitle: activityTitle),
    );

    existing.totalPlayed++;
    if (isCorrect) existing.correct++;
    if (isSkipped) existing.skipped++;

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> rawMap = {};
      _activityScores.forEach((k, v) => rawMap[k] = v.toJson());
      await prefs.setString(_prefKeyScores, jsonEncode(rawMap));
    } catch (e) {
      debugPrint('[RecommendationService] Error persisting activity score: $e');
    }
  }

  /// Generates compassionate, non-clinical insights for the caregiver dashboard.
  List<ActivityInsight> getInsightsForCaregiver() {
    if (_activityScores.isEmpty) {
      // Default baseline insights
      return const [
        ActivityInsight(
          activityTitle: 'Familiar Nature Match',
          engagementLevel: 'High Comfort & Flow',
          skipRate: 0.0,
          totalPlayed: 5,
          recommendationNote: 'Great for morning self-guided calm and visual familiarity.',
        ),
        ActivityInsight(
          activityTitle: 'Music & Reminiscence',
          engagementLevel: 'High Comfort & Flow',
          skipRate: 0.0,
          totalPlayed: 4,
          recommendationNote: 'Old Bihu songs and flute evoke warm smiles and steady breathing.',
        ),
        ActivityInsight(
          activityTitle: 'Colour & Word Focus',
          engagementLevel: 'Moderate Comfort',
          skipRate: 20.0,
          totalPlayed: 3,
          recommendationNote: 'Best enjoyed with caregiver sitting together with gentle verbal prompts.',
        ),
        ActivityInsight(
          activityTitle: 'Remember & Recall',
          engagementLevel: 'Moderate Comfort',
          skipRate: 25.0,
          totalPlayed: 3,
          recommendationNote: 'Keep items to 3 max. Gentle unhurried praise promotes confidence.',
        ),
      ];
    }

    return _activityScores.values.map((score) {
      String note;
      if (score.skipRate > 35) {
        note = 'Consider playing together with caregiver or trying a gentler visual tempo.';
      } else if (score.accuracy >= 75) {
        note = 'Strong engagement and familiarity. Continues to provide positive reinforcement.';
      } else {
        note = 'Comfortable interaction. Keep pacing natural and relaxed.';
      }

      return ActivityInsight(
        activityTitle: score.activityTitle,
        engagementLevel: score.engagementLevel,
        skipRate: score.skipRate,
        totalPlayed: score.totalPlayed,
        recommendationNote: note,
      );
    }).toList();
  }

  void _seedInitialScores() {
    _activityScores['act_familiar_object_match'] = ActivityScore(
      activityId: 'act_familiar_object_match',
      activityTitle: 'Familiar Nature Match',
      correct: 4,
      skipped: 0,
      totalPlayed: 4,
    );
    _activityScores['act_music_and_memory'] = ActivityScore(
      activityId: 'act_music_and_memory',
      activityTitle: 'Music & Reminiscence',
      correct: 3,
      skipped: 0,
      totalPlayed: 3,
    );
    _activityScores['act_colour_word_focus'] = ActivityScore(
      activityId: 'act_colour_word_focus',
      activityTitle: 'Colour & Word Focus',
      correct: 2,
      skipped: 1,
      totalPlayed: 3,
    );
  }

  /// Simulates progressive AI analysis after caregiver onboarding
  Future<void> simulateAiAnalysis({
    required String patientId,
    AiProcessingStatus targetFinalStatus = AiProcessingStatus.ready,
  }) async {
    _isProcessing = true;

    // Stage 1: Preparing profile
    _currentRecommendation = AiRecommendation(
      patientId: patientId,
      generatedAt: DateTime.now(),
      status: AiProcessingStatus.preparing,
      sixDomainOverview: CognitiveDomain.defaultDomains,
      recommendedActivities: [],
      fallbackStarterActivities: MockDataRepository.getCatalogActivities().take(2).toList(),
      reasoningInfluences: const [
        'Organizing shared routine anchors',
        'Validating cultural music preferences',
      ],
      supportiveExplanation: 'Organizing the preferences and comfort needs you shared.',
    );
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1200));

    // Stage 2: Personalizing activities
    _currentRecommendation = _currentRecommendation!.copyWith(
      status: AiProcessingStatus.personalizing,
      supportiveExplanation: 'Finding gentle activities based on abilities, preferences, and routines.',
      reasoningInfluences: const [
        'Assam tea culture & gardening affinity',
        'Unhurried morning time anchor',
        'Preference for large text & soothing audio',
      ],
    );
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1400));

    // Final Stage
    final allActivities = MockDataRepository.getCatalogActivities();
    final count = getTodaysRecommendedCount();
    _currentRecommendation = _currentRecommendation!.copyWith(
      status: targetFinalStatus,
      recommendedActivities: allActivities.take(count).toList(),
      supportiveExplanation: targetFinalStatus == AiProcessingStatus.ready
          ? 'Today’s activities are ready. Selected to celebrate familiar memories with gentle, unpaced comfort.'
          : targetFinalStatus == AiProcessingStatus.delayedOffline
              ? 'Your profile is saved safely. We will use your information locally and update recommendations when connected.'
              : targetFinalStatus == AiProcessingStatus.insufficientInfo
                  ? 'Adding a few details about favorite music or morning routines will help personalize recommendations further.'
                  : 'We could not reach the recommendation service. Your saved data is safe, and gentle starter activities are ready.',
    );
    _isProcessing = false;
    notifyListeners();
  }

  /// Manually force a specific processing status for demo/testing purposes
  void setProcessingStatus(AiProcessingStatus status) {
    if (_currentRecommendation != null) {
      _currentRecommendation = _currentRecommendation!.copyWith(status: status);
      notifyListeners();
    }
  }

  /// Caregiver overrides support priority for a specific domain
  void overrideDomainPriority(CognitiveDomainType domainType, DomainSupportPriority newPriority) {
    if (_currentRecommendation == null) return;

    final updatedDomains = _currentRecommendation!.sixDomainOverview.map((domain) {
      if (domain.type == domainType) {
        return CognitiveDomain(
          type: domain.type,
          formalName: domain.formalName,
          patientFriendlyName: domain.patientFriendlyName,
          description: domain.description,
          icon: domain.icon,
          accentColor: domain.accentColor,
          priority: newPriority,
        );
      }
      return domain;
    }).toList();

    _currentRecommendation = _currentRecommendation!.copyWith(
      sixDomainOverview: updatedDomains,
      isOverriddenByCaregiver: true,
    );
    notifyListeners();
  }

  /// Adapts recommendation when a caregiver provides session feedback
  void applyCaregiverObservation({
    required List<String> moodTags,
    String? recommendationPreference,
  }) {
    if (moodTags.isEmpty) return;
    _lastCaregiverMood = moodTags.first;

    final lowerMoods = moodTags.map((m) => m.toLowerCase()).toSet();

    if (lowerMoods.contains('tired') ||
        lowerMoods.contains('confused') ||
        lowerMoods.contains('frustrated') ||
        lowerMoods.contains('anxious') ||
        lowerMoods.contains('withdrawn') ||
        lowerMoods.contains('irritated') ||
        recommendationPreference == 'needs_rest' ||
        recommendationPreference == 'more_music') {
      // Gentle shift: suggest quiet connection, music, reminiscence or no game
      _activeDifficulty = 'Gentle';
      _isNoGameRecommended = true;
      _gentleAlternativeTitle = 'Gentle Flute & Veranda Rest';
      _gentleAlternativeDescription = 'Take a soothing pause with bamboo flute melodies, quiet conversation, and tea memories.';
    } else if (recommendationPreference == 'too_easy' || recommendationPreference == 'increase_challenge') {
      // Patient found it easy: adapt with a slightly higher focus / cognitive level
      _isNoGameRecommended = false;
      _activeDifficulty = 'Focus';
    } else if (recommendationPreference == 'too_hard' || recommendationPreference == 'gentler') {
      // Patient struggled: make simpler or switch domain
      _isNoGameRecommended = false;
      _activeDifficulty = 'Gentle';
    } else if (lowerMoods.contains('engaged') || lowerMoods.contains('calm')) {
      // Comfortable: normal cognitive engagement
      _isNoGameRecommended = false;
      _activeDifficulty = 'Standard';
    } else {
      _isNoGameRecommended = false;
      _activeDifficulty = 'Gentle';
    }

    notifyListeners();
  }

  void toggleNoGameRecommendation(bool enabled) {
    _isNoGameRecommended = enabled;
    notifyListeners();
  }

  /// Returns curated activities for Today's Journey based on caregiver presence and adaptive state
  List<ActivityItem> getTodaysJourneyActivities({required bool isCaregiverPresent}) {
    final catalog = MockDataRepository.getCatalogActivities();
    final maxCount = getTodaysRecommendedCount();

    if (_isNoGameRecommended) {
      // Return calming connection activities (Look & Talk, Music & Memory, Story from Photo)
      final calming = [
        catalog.firstWhere((a) => a.id == 'act_music_and_memory', orElse: () => catalog.first),
        catalog.firstWhere((a) => a.id == 'act_look_and_talk', orElse: () => catalog[1]),
        catalog.firstWhere((a) => a.id == 'act_story_from_photo', orElse: () => catalog[2]),
      ];
      return calming.take(maxCount).toList();
    }

    if (isCaregiverPresent) {
      // Prioritize Cognitive Together and Connection Together
      final togetherList = [
        catalog.firstWhere((a) => a.id == 'act_family_match', orElse: () => catalog.first),
        catalog.firstWhere((a) => a.id == 'act_build_the_day', orElse: () => catalog[1]),
        catalog.firstWhere((a) => a.id == 'act_look_and_talk', orElse: () => catalog[2]),
        catalog.firstWhere((a) => a.id == 'act_music_and_memory', orElse: () => catalog[3]),
      ];
      return togetherList.take(maxCount).toList();
    } else {
      // Independent cognitive and gentle self-guided activities
      final independentList = [
        catalog.firstWhere((a) => a.id == 'act_remember_recall', orElse: () => catalog.first),
        catalog.firstWhere((a) => a.id == 'act_colour_word_focus', orElse: () => catalog[1]),
        catalog.firstWhere((a) => a.id == 'act_familiar_object_match', orElse: () => catalog[2]),
        catalog.firstWhere((a) => a.id == 'act_music_and_memory', orElse: () => catalog[3]),
      ];
      return independentList.take(maxCount).toList();
    }
  }
}
