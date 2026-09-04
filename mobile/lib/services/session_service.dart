import 'package:flutter/foundation.dart';
import '../models/activity_item.dart';
import '../models/session_event.dart';

/// Service managing the active activity session lifecycle and hidden telemetry recording.
/// Strictly keeps performance indicators non-visible to the elder patient.
class SessionService extends ChangeNotifier {
  static final SessionService instance = SessionService._internal();
  SessionService._internal();

  ActivityItem? _activeActivity;
  String? _patientId;
  DateTime? _sessionStartTime;
  int _hintsUsed = 0;
  int _pauseCount = 0;
  final List<int> _responseLatenciesMs = [];
  final List<SessionEvent> _completedSessionsHistory = [];

  ActivityItem? get activeActivity => _activeActivity;
  bool get isSessionActive => _activeActivity != null;
  int get hintsUsed => _hintsUsed;
  int get pauseCount => _pauseCount;
  List<SessionEvent> get completedSessionsHistory => List.unmodifiable(_completedSessionsHistory);

  void startSession(ActivityItem activity, String patientId) {
    _activeActivity = activity;
    _patientId = patientId;
    _sessionStartTime = DateTime.now();
    _hintsUsed = 0;
    _pauseCount = 0;
    _responseLatenciesMs.clear();
    notifyListeners();
  }

  void recordHint() {
    _hintsUsed++;
    notifyListeners();
  }

  void recordPause() {
    _pauseCount++;
    notifyListeners();
  }

  void recordActionLatency(int latencyMs) {
    _responseLatenciesMs.add(latencyMs);
  }

  /// Concludes session and saves hidden telemetry for caregiver insights & AI tuning
  SessionEvent? completeSession() {
    if (_activeActivity == null || _sessionStartTime == null) return null;

    final avgLatency = _responseLatenciesMs.isEmpty
        ? 3200
        : (_responseLatenciesMs.reduce((a, b) => a + b) / _responseLatenciesMs.length).round();

    final event = SessionEvent(
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      patientId: _patientId ?? 'patient_default',
      activityId: _activeActivity!.id,
      domain: _activeActivity!.domain,
      modality: _activeActivity!.modality,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      isCompleted: true,
      successRate: 1.0, // Non-punitive
      averageResponseTimeMs: avgLatency,
      hintsUsed: _hintsUsed,
      pauseCount: _pauseCount,
      difficultyLevel: _activeActivity!.difficultyLabel,
      contentType: _activeActivity!.culturalTags.join(', '),
      usedAudioGuidance: true,
      isQueuedOffline: false,
    );

    _completedSessionsHistory.add(event);
    _activeActivity = null;
    _sessionStartTime = null;
    notifyListeners();
    return event;
  }

  void resetSession() {
    _activeActivity = null;
    _sessionStartTime = null;
    _hintsUsed = 0;
    _pauseCount = 0;
    _responseLatenciesMs.clear();
    notifyListeners();
  }
}
