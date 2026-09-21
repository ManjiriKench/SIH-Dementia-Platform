import 'package:flutter/foundation.dart';

/// Represents an alert raised due to observed patient fatigue, hesitation, or stress.
class PatientAlert {
  final String id;
  final String patientId;
  final String activityTitle;
  final String reason;
  final DateTime time;

  const PatientAlert({
    required this.id,
    required this.patientId,
    required this.activityTitle,
    required this.reason,
    required this.time,
  });
}

/// Singleton service managing alerts triggered during patient activities.
/// Alerts are displayed prominently as an alert banner at the top of the Caregiver Dashboard.
class AlertService extends ChangeNotifier {
  static final AlertService instance = AlertService._internal();
  AlertService._internal();

  final List<PatientAlert> _alerts = [];

  List<PatientAlert> get activeAlerts => List.unmodifiable(_alerts);

  void raiseAlert({
    required String patientId,
    required String activityTitle,
    required String reason,
  }) {
    // Avoid duplicate spam within 5 minutes for the same activity
    final now = DateTime.now();
    final duplicate = _alerts.any(
      (a) => a.activityTitle == activityTitle && now.difference(a.time).inMinutes < 5,
    );
    if (duplicate) return;

    _alerts.insert(
      0,
      PatientAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        activityTitle: activityTitle,
        reason: reason,
        time: now,
      ),
    );
    notifyListeners();
  }

  void clearAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void clearAll() {
    _alerts.clear();
    notifyListeners();
  }
}
