import 'package:flutter/foundation.dart';
import '../models/patient_profile.dart';
import 'mock_data_repository.dart';

/// Service managing patient profile state, onboarding progress, and draft edits.
class ProfileService extends ChangeNotifier {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();

  PatientProfile? _activeProfile;
  bool _isLoading = false;

  PatientProfile? get activeProfile => _activeProfile;
  bool get hasProfile => _activeProfile != null;
  bool get isLoading => _isLoading;

  /// Loads initial profile or default mock profile
  Future<void> loadProfile({bool useMock = true}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    if (useMock && _activeProfile == null) {
      _activeProfile = MockDataRepository.createSamplePatient();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sets or saves a completed profile from caregiver onboarding
  void saveProfile(PatientProfile profile) {
    _activeProfile = profile;
    notifyListeners();
  }

  /// Updates specific fields of the active profile
  void updateProfile(PatientProfile updated) {
    _activeProfile = updated;
    notifyListeners();
  }

  /// Clears active profile (for testing fresh onboarding)
  void clearProfile() {
    _activeProfile = null;
    notifyListeners();
  }
}
