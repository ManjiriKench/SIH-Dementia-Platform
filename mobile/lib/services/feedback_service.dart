import 'package:flutter/foundation.dart';
import '../models/caregiver_feedback.dart';

/// Service managing post-session caregiver observations, voice notes,
/// pending session tasks, and offline queue synchronization.
class FeedbackService extends ChangeNotifier {
  static final FeedbackService instance = FeedbackService._internal();
  FeedbackService._internal();

  final List<CaregiverFeedback> _feedbackList = [];
  final List<String> _pendingSessionIds = ['sess_morning_tea_02']; // Sample pending reminder
  bool _isOffline = false;

  List<CaregiverFeedback> get feedbackList => List.unmodifiable(_feedbackList);
  List<String> get pendingSessionIds => List.unmodifiable(_pendingSessionIds);
  int get pendingCount => _pendingSessionIds.length;
  bool get isOffline => _isOffline;

  void toggleOfflineMode() {
    _isOffline = !_isOffline;
    // If going online, sync any pending offline items
    if (!_isOffline) {
      syncQueuedFeedback();
    }
    notifyListeners();
  }

  void addPendingSession(String sessionId) {
    if (!_pendingSessionIds.contains(sessionId)) {
      _pendingSessionIds.add(sessionId);
      notifyListeners();
    }
  }

  void submitFeedback(CaregiverFeedback feedback) {
    final status = _isOffline ? SyncStatus.pendingOffline : SyncStatus.synced;
    final finalized = feedback.copyWith(syncStatus: status);
    
    _feedbackList.insert(0, finalized);
    _pendingSessionIds.remove(feedback.sessionId);
    notifyListeners();
  }

  void syncQueuedFeedback() {
    bool updated = false;
    for (int i = 0; i < _feedbackList.length; i++) {
      if (_feedbackList[i].syncStatus == SyncStatus.pendingOffline) {
        _feedbackList[i] = _feedbackList[i].copyWith(syncStatus: SyncStatus.synced);
        updated = true;
      }
    }
    if (updated) {
      notifyListeners();
    }
  }
}
