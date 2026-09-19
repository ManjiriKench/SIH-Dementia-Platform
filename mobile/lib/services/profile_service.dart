import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_profile.dart';
import 'mock_data_repository.dart';

/// Service managing patient profile state, onboarding progress, voice notes, and local disk persistence.
class ProfileService extends ChangeNotifier {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();

  static const String _profileStorageKey = 'smriti_active_patient_profile';
  static const String _voiceGeneralKey = 'smriti_voice_general';
  static const String _voiceObsKey = 'smriti_voice_obs';
  static const String _voiceDrKey = 'smriti_voice_dr';

  PatientProfile? _activeProfile;
  bool _isLoading = false;
  bool _hasCompletedOnboarding = false;

  // Voice recordings stored during profile setup
  String? generalVoiceNote;
  String? observationVoiceNote;
  String? doctorVoiceNote;

  PatientProfile? get activeProfile => _activeProfile;
  bool get hasProfile => _activeProfile != null;
  bool get isReturningUser => _activeProfile != null && _hasCompletedOnboarding;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;

  /// Loads saved profile from local disk, with fallback to default sample if requested
  Future<void> loadProfile({bool useMock = true}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_profileStorageKey);

      if (savedJson != null && savedJson.isNotEmpty) {
        final decoded = jsonDecode(savedJson) as Map<String, dynamic>;
        _activeProfile = PatientProfile.fromJson(decoded);
        _hasCompletedOnboarding = true;
        generalVoiceNote = prefs.getString(_voiceGeneralKey);
        observationVoiceNote = prefs.getString(_voiceObsKey);
        doctorVoiceNote = prefs.getString(_voiceDrKey);
      } else if (useMock && _activeProfile == null) {
        _activeProfile = MockDataRepository.createSamplePatient();
        _hasCompletedOnboarding = true;
      }
    } catch (e) {
      debugPrint('Error loading saved profile: $e');
      if (useMock && _activeProfile == null) {
        _activeProfile = MockDataRepository.createSamplePatient();
        _hasCompletedOnboarding = true;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sets or saves a completed profile from caregiver onboarding to memory and local disk
  void saveProfile(PatientProfile profile, {
    String? generalVoice,
    String? obsVoice,
    String? drVoice,
  }) {
    _activeProfile = profile;
    _hasCompletedOnboarding = true;
    if (generalVoice != null) generalVoiceNote = generalVoice;
    if (obsVoice != null) observationVoiceNote = obsVoice;
    if (drVoice != null) doctorVoiceNote = drVoice;
    notifyListeners();
    _persistProfileToDisk();
  }

  /// Updates specific fields of the active profile and syncs to disk
  void updateProfile(PatientProfile updated) {
    _activeProfile = updated;
    notifyListeners();
    _persistProfileToDisk();
  }

  Future<void> _persistProfileToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_activeProfile != null) {
        await prefs.setString(_profileStorageKey, jsonEncode(_activeProfile!.toJson()));
      }
      if (generalVoiceNote != null) await prefs.setString(_voiceGeneralKey, generalVoiceNote!);
      if (observationVoiceNote != null) await prefs.setString(_voiceObsKey, observationVoiceNote!);
      if (doctorVoiceNote != null) await prefs.setString(_voiceDrKey, doctorVoiceNote!);
    } catch (e) {
      debugPrint('Error persisting profile to disk: $e');
    }
  }

  /// Clears active profile (for testing fresh onboarding) from memory and disk
  void clearProfile() {
    _activeProfile = null;
    _hasCompletedOnboarding = false;
    generalVoiceNote = null;
    observationVoiceNote = null;
    doctorVoiceNote = null;
    notifyListeners();
    _clearProfileFromDisk();
  }

  /// Resets to clean Bonti Baruah demo profile for presentations
  Future<void> resetToDemoProfile() async {
    _activeProfile = MockDataRepository.createSamplePatient();
    _hasCompletedOnboarding = true;
    generalVoiceNote = null;
    observationVoiceNote = null;
    doctorVoiceNote = null;
    notifyListeners();
    await _persistProfileToDisk();
  }

  Future<void> _clearProfileFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileStorageKey);
      await prefs.remove(_voiceGeneralKey);
      await prefs.remove(_voiceObsKey);
      await prefs.remove(_voiceDrKey);
    } catch (e) {
      debugPrint('Error clearing profile from disk: $e');
    }
  }
}
