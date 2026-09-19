import 'activity_item.dart';
import 'cognitive_domain.dart';

/// Hidden session telemetry payload captured during activity execution.
/// Used strictly for caregiver insights and AI personalization.
/// NEVER exposed to the elder patient as a score or grade.
class SessionEvent {
  final String sessionId;
  final String patientId;
  final String activityId;
  final CognitiveDomainType domain;
  final ActivityModality modality;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  
  // Hidden non-stress performance metrics
  final double successRate;       // 0.0 - 1.0 (internal metric only)
  final int averageResponseTimeMs;// internal reaction pace
  final int hintsUsed;            // Caregiver hints or audio hints
  final int pauseCount;
  final String difficultyLevel;
  final String contentType;       // 'memory_based', 'music_based', 'nature_cultural'
  final bool usedAudioGuidance;
  final bool isQueuedOffline;

  const SessionEvent({
    required this.sessionId,
    required this.patientId,
    required this.activityId,
    required this.domain,
    required this.modality,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
    this.successRate = 1.0,
    this.averageResponseTimeMs = 3500,
    this.hintsUsed = 0,
    this.pauseCount = 0,
    this.difficultyLevel = 'Gentle',
    this.contentType = 'nature_cultural',
    this.usedAudioGuidance = true,
    this.isQueuedOffline = false,
  });

  Duration get sessionDuration => endTime.difference(startTime);

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'patientId': patientId,
    'activityId': activityId,
    'domain': domain.name,
    'modality': modality.name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isCompleted': isCompleted,
    'successRate': successRate,
    'averageResponseTimeMs': averageResponseTimeMs,
    'hintsUsed': hintsUsed,
    'pauseCount': pauseCount,
    'difficultyLevel': difficultyLevel,
    'contentType': contentType,
    'usedAudioGuidance': usedAudioGuidance,
    'isQueuedOffline': isQueuedOffline,
  };

  factory SessionEvent.fromJson(Map<String, dynamic> json) {
    return SessionEvent(
      sessionId: json['sessionId'] as String? ?? 'sess_default',
      patientId: json['patientId'] as String? ?? 'pat_default',
      activityId: json['activityId'] as String? ?? 'act_default',
      domain: CognitiveDomainType.values.firstWhere(
        (d) => d.name == json['domain'],
        orElse: () => CognitiveDomainType.memory,
      ),
      modality: ActivityModality.values.firstWhere(
        (m) => m.name == json['modality'],
        orElse: () => ActivityModality.independent,
      ),
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? true,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 1.0,
      averageResponseTimeMs: json['averageResponseTimeMs'] as int? ?? 3500,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      pauseCount: json['pauseCount'] as int? ?? 0,
      difficultyLevel: json['difficultyLevel'] as String? ?? 'Gentle',
      contentType: json['contentType'] as String? ?? 'nature_cultural',
      usedAudioGuidance: json['usedAudioGuidance'] as bool? ?? true,
      isQueuedOffline: json['isQueuedOffline'] as bool? ?? false,
    );
  }
}
