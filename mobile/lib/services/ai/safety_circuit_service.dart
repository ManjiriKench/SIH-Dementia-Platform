/// Result of a safety circuit check.
class SafetyCheckResult {
  final bool allowCognitiveGame;
  final String recommendedMode; // "Cognitive_Engagement" or "Gentle_Connection"
  final String triggerType;     // "none", "caregiver_mood", "acute_fatigue", "repeated_abandonment"
  final String message;
  final String fallbackActivityTitle;
  final String fallbackType;

  const SafetyCheckResult({
    required this.allowCognitiveGame,
    required this.recommendedMode,
    required this.triggerType,
    required this.message,
    this.fallbackActivityTitle = "Borgeet Flute Melody",
    this.fallbackType = "audio",
  });

  Map<String, dynamic> toJson() => {
    'allow_cognitive_game': allowCognitiveGame,
    'recommended_mode': recommendedMode,
    'trigger_type': triggerType,
    'message': message,
    'fallback_activity_title': fallbackActivityTitle,
    'fallback_type': fallbackType,
  };
}

/// Zero-Latency, On-Device Safety Interceptor for Smriti.
///
/// Ensures "No Game Today" is a gentle, first-class recommendation whenever
/// agitation, acute exhaustion, or repeated errors are detected.
class SafetyCircuitService {
  static final SafetyCircuitService _instance = SafetyCircuitService._internal();
  factory SafetyCircuitService() => _instance;
  SafetyCircuitService._internal();

  static const Set<String> _agitatedMoods = {
    'Anxious',
    'Agitated',
    'Tired',
    'Withdrawn',
    'Irritated',
    'Restless',
  };

  /// Evaluates pre-session caregiver mood check.
  SafetyCheckResult evaluatePreSessionMood(String caregiverMood) {
    if (_agitatedMoods.contains(caregiverMood)) {
      return SafetyCheckResult(
        allowCognitiveGame: false,
        recommendedMode: 'Gentle_Connection',
        triggerType: 'caregiver_mood',
        message: 'Caregiver noted patient feels ${caregiverMood.toLowerCase()}. Cognitive games are gently paused today. Enjoy peaceful connection instead.',
        fallbackActivityTitle: 'Borgeet Flute Melody',
        fallbackType: 'audio',
      );
    }

    return const SafetyCheckResult(
      allowCognitiveGame: true,
      recommendedMode: 'Cognitive_Engagement',
      triggerType: 'none',
      message: 'Patient is in a receptive state for gentle cognitive play.',
    );
  }

  /// Evaluates real-time mid-game trial telemetry.
  SafetyCheckResult evaluateMidSessionFriction({
    required int currentErrorStreak,
    required int currentLatencyMs,
    double targetLatencySec = 2.5,
    int abandonmentCountToday = 0,
  }) {
    final double targetMs = targetLatencySec * 1000.0;
    final bool isLatencySpiked = currentLatencyMs > (targetMs * 3.5);
    final bool isErrorStreakHigh = currentErrorStreak >= 3;
    final bool isRepeatedAbandonment = abandonmentCountToday >= 2;

    if (isRepeatedAbandonment) {
      return const SafetyCheckResult(
        allowCognitiveGame: false,
        recommendedMode: 'Gentle_Connection',
        triggerType: 'repeated_abandonment',
        message: 'Multiple early exits detected today. Pausing challenge to keep interactions joyful and strain-free.',
        fallbackActivityTitle: 'Gentle Tea & Family Walk',
        fallbackType: 'caregiver_prompt',
      );
    }

    if (isErrorStreakHigh && isLatencySpiked) {
      return const SafetyCheckResult(
        allowCognitiveGame: false,
        recommendedMode: 'Gentle_Connection',
        triggerType: 'acute_fatigue',
        message: 'You did wonderfully trying today! Let us take a peaceful break with our family photos.',
        fallbackActivityTitle: 'Family Photo Stroll',
        fallbackType: 'reminiscence',
      );
    }

    return const SafetyCheckResult(
      allowCognitiveGame: true,
      recommendedMode: 'Cognitive_Engagement',
      triggerType: 'none',
      message: 'Session is progressing smoothly.',
    );
  }
}
