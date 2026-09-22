import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';
import '../models/appointment.dart';

/// Manages medications and doctor appointments locally via SharedPreferences.
class CarePlanService extends ChangeNotifier {
  static final CarePlanService instance = CarePlanService._internal();
  CarePlanService._internal() { _load(); }

  static const String _medsKey = 'smriti_medications';
  static const String _apptKey = 'smriti_appointments';

  final List<Medication> _medications = [];
  final List<Appointment> _appointments = [];

  List<Medication> get medications => List.unmodifiable(_medications);
  List<Appointment> get appointments => List.unmodifiable(_appointments);
  List<Appointment> get upcomingAppointments =>
      _appointments.where((a) => a.isUpcoming).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final medsJson = prefs.getString(_medsKey);
      if (medsJson != null) {
        final list = jsonDecode(medsJson) as List<dynamic>;
        _medications.clear();
        _medications.addAll(list.map((e) => Medication.fromJson(e as Map<String, dynamic>)));
      } else {
        // Seed with demo data
        _medications.addAll([
          Medication(id: 'med_1', name: 'Aricept (Donepezil)', dosage: '5mg', timing: 'Evening with dinner'),
          Medication(id: 'med_2', name: 'Vitamin D3', dosage: '1000 IU', timing: 'Morning with breakfast'),
          Medication(id: 'med_3', name: 'Omega-3', dosage: '1 capsule', timing: 'With lunch'),
        ]);
      }

      final apptJson = prefs.getString(_apptKey);
      if (apptJson != null) {
        final list = jsonDecode(apptJson) as List<dynamic>;
        _appointments.clear();
        _appointments.addAll(list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)));
      } else {
        _appointments.add(Appointment(
          id: 'appt_1', title: 'Neurology Follow-up',
          doctorName: 'Dr. Sharma', location: 'GMCH, Guwahati',
          scheduledAt: DateTime.now().add(const Duration(days: 7)),
          notes: 'Bring medication records',
        ));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[CarePlanService] Load error: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_medsKey, jsonEncode(_medications.map((m) => m.toJson()).toList()));
      await prefs.setString(_apptKey, jsonEncode(_appointments.map((a) => a.toJson()).toList()));
    } catch (e) {
      debugPrint('[CarePlanService] Save error: $e');
    }
  }

  void addMedication(Medication med) {
    _medications.add(med);
    _save();
    notifyListeners();
  }

  void toggleMedicationTaken(String id) {
    final idx = _medications.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      _medications[idx].isTakenToday = !_medications[idx].isTakenToday;
      _save();
      notifyListeners();
    }
  }

  void removeMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    _save();
    notifyListeners();
  }

  void addAppointment(Appointment appt) {
    _appointments.add(appt);
    _save();
    notifyListeners();
  }

  void removeAppointment(String id) {
    _appointments.removeWhere((a) => a.id == id);
    _save();
    notifyListeners();
  }

  void resetMedicationsTaken() {
    for (final m in _medications) { m.isTakenToday = false; }
    _save();
    notifyListeners();
  }

  void clearAll() {
    _medications.clear();
    _appointments.clear();
    _save();
    notifyListeners();
  }

  Future<void> resetToDemo() async {
    _medications.clear();
    _medications.addAll([
      Medication(id: 'med_1', name: 'Aricept (Donepezil)', dosage: '5mg', timing: 'Evening with dinner'),
      Medication(id: 'med_2', name: 'Vitamin D3', dosage: '1000 IU', timing: 'Morning with breakfast'),
      Medication(id: 'med_3', name: 'Omega-3', dosage: '1 capsule', timing: 'With lunch'),
    ]);
    _appointments.clear();
    _appointments.add(Appointment(
      id: 'appt_1',
      title: 'Neurology Follow-up',
      doctorName: 'Dr. Sharma',
      location: 'GMCH, Guwahati',
      scheduledAt: DateTime.now().add(const Duration(days: 7)),
      notes: 'Bring medication records',
    ));
    await _save();
    notifyListeners();
  }
}
