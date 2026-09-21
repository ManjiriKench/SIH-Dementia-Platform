import 'package:flutter/foundation.dart';

/// A single patient alert raised by the frustration/anxiety detection heuristic.
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

/// Service that manages local stress/frustration alerts raised during activities.
/// Alerts are surfaced on the Caregiver Dashboard as a prominent banner.
/// No push notification backend required — fully local for prototype.
class AlertService extends ChangeNotifier {
  static final AlertService instance = AlertService._internal();
  AlertService._internal();

  final List<PatientAlert> _alerts = [];

  List<PatientAlert> get activeAlerts => List.unmodifiable(_alerts);
  bool get hasAlerts => _alerts.isNotEmpty;

  /// Raise an alert (e.g. repeated frustration, long no-response).
  void raiseAlert({
    required String patientId,
    required String activityTitle,
    required String reason,
  }) {
    final alert = PatientAlert(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      activityTitle: activityTitle,
      reason: reason,
      time: DateTime.now(),
    );
    _alerts.add(alert);
    debugPrint('[AlertService] Alert raised: ${alert.reason} during ${alert.activityTitle}');
    notifyListeners();
  }

  /// Caregiver acknowledges and clears an alert.
  void clearAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  /// Clear all alerts (e.g., after a session ends without incident).
  void clearAll() {
    _alerts.clear();
    notifyListeners();
  }
}
