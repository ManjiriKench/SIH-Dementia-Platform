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
}
