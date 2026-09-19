import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_item.dart';
import '../models/session_event.dart';
import 'mock_data_repository.dart';

/// Service managing the active activity session lifecycle and hidden telemetry recording.
/// Strictly keeps performance indicators non-visible to the elder patient.
class SessionService extends ChangeNotifier {
  static final SessionService instance = SessionService._internal();
  SessionService._internal() {
    _loadHistoryFromDisk();
  }

  static const String _sessionsStorageKey = 'smriti_completed_sessions_history';

  ActivityItem? _activeActivity;
  String? _patientId;
  DateTime? _sessionStartTime;
  int _hintsUsed = 0;
  int _pauseCount = 0;
  final List<int> _responseLatenciesMs = [];
  final List<SessionEvent> _completedSessionsHistory = [];
  SessionEvent? _lastCompletedSession;

  ActivityItem? get activeActivity => _activeActivity;
  bool get isSessionActive => _activeActivity != null;
  DateTime? get sessionStartTime => _sessionStartTime;
  int get hintsUsed => _hintsUsed;
  int get pauseCount => _pauseCount;
  List<SessionEvent> get completedSessionsHistory => List.unmodifiable(_completedSessionsHistory);
  SessionEvent? get lastCompletedSession => _lastCompletedSession;

  Duration? get activeSessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  Future<void> _loadHistoryFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_sessionsStorageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final decoded = jsonDecode(savedJson) as List<dynamic>;
        _completedSessionsHistory.clear();
        for (final item in decoded) {
          _completedSessionsHistory.add(SessionEvent.fromJson(item as Map<String, dynamic>));
        }
        if (_completedSessionsHistory.isNotEmpty) {
          _lastCompletedSession = _completedSessionsHistory.last;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading session history: $e');
    }
  }

  Future<void> _persistHistoryToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _completedSessionsHistory.map((s) => s.toJson()).toList();
      await prefs.setString(_sessionsStorageKey, jsonEncode(listJson));
    } catch (e) {
      debugPrint('Error saving session history: $e');
    }
  }

  /// Clears session history from memory and local disk (for clean demo presentation)
  Future<void> clearHistory() async {
    _completedSessionsHistory.clear();
    _lastCompletedSession = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionsStorageKey);
    } catch (e) {
      debugPrint('Error clearing session history: $e');
    }
    notifyListeners();
  }

  void startSession(ActivityItem activity, String patientId) {
    _activeActivity = activity;
    _patientId = patientId;
    _sessionStartTime = DateTime.now();
    _hintsUsed = 0;
    _pauseCount = 0;
    _responseLatenciesMs.clear();
    notifyListeners();
  }

  void startActivityByTitle({required String activityTitle, String? patientId}) {
    final catalog = MockDataRepository.getCatalogActivities();
    final lowerTitle = activityTitle.toLowerCase();
    final activity = catalog.firstWhere(
      (a) => a.title.toLowerCase().contains(lowerTitle) || lowerTitle.contains(a.title.toLowerCase()),
      orElse: () => catalog.first,
    );
    startSession(activity, patientId ?? 'pat_default');
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
    _lastCompletedSession = event;
    _activeActivity = null;
    _sessionStartTime = null;
    notifyListeners();
    _persistHistoryToDisk();
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
