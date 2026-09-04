import 'dart:async';
import 'package:flutter/foundation.dart';

enum MicPermissionState { notDetermined, granted, denied }

/// Voice assistant service managing screen text-to-speech simulation,
/// instruction audio replay, and voice recording with transcription fallback.
class VoiceAssistantService extends ChangeNotifier {
  static final VoiceAssistantService instance = VoiceAssistantService._internal();
  VoiceAssistantService._internal();

  bool _isSpeaking = false;
  String _currentSpeakingText = '';
  double _speechRate = 0.85; // Calmer, slightly slower default rate for elders
  double _volume = 1.0;
  Timer? _ttsTimer;

  // Voice Recording state for Caregiver feedback & notes
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  MicPermissionState _micPermission = MicPermissionState.granted;
  bool _isTranscribing = false;

  bool get isSpeaking => _isSpeaking;
  String get currentSpeakingText => _currentSpeakingText;
  double get speechRate => _speechRate;
  double get volume => _volume;
  bool get isRecording => _isRecording;
  int get recordingSeconds => _recordingSeconds;
  MicPermissionState get micPermission => _micPermission;
  bool get isTranscribing => _isTranscribing;

  void setSpeechRate(double rate) {
    _speechRate = rate.clamp(0.5, 1.2);
    notifyListeners();
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Speaks the provided text with calm pacing.
  Future<void> speak(String text) async {
    stopSpeaking();
    _isSpeaking = true;
    _currentSpeakingText = text;
    notifyListeners();

    // Approximate duration based on word count and speech rate
    final words = text.split(' ').length;
    final durationSeconds = ((words / (2.2 * _speechRate)).clamp(2.5, 12.0)).toInt();

    _ttsTimer = Timer(Duration(seconds: durationSeconds), () {
      _isSpeaking = false;
      _currentSpeakingText = '';
      notifyListeners();
    });
  }

  void stopSpeaking() {
    _ttsTimer?.cancel();
    if (_isSpeaking) {
      _isSpeaking = false;
      _currentSpeakingText = '';
      notifyListeners();
    }
  }

  void replayCurrentInstruction() {
    if (_currentSpeakingText.isNotEmpty) {
      speak(_currentSpeakingText);
    }
  }

  // Voice Recording simulation for Caregiver Feedback
  Future<bool> startRecording() async {
    if (_micPermission != MicPermissionState.granted) {
      notifyListeners();
      return false;
    }
    _isRecording = true;
    _recordingSeconds = 0;
    notifyListeners();

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingSeconds++;
      notifyListeners();
    });
    return true;
  }

  Future<String> stopRecordingAndTranscribe() async {
    _recordingTimer?.cancel();
    _isRecording = false;
    _isTranscribing = true;
    notifyListeners();

    // Simulate transcription processing delay
    await Future.delayed(const Duration(milliseconds: 1400));
    _isTranscribing = false;
    notifyListeners();

    // Return realistic compassionate caregiver reflection note
    return "Grandmother appeared calm and recognized the tea garden photo. She hummed along to the tune for a few seconds.";
  }

  void toggleMicPermission() {
    _micPermission = _micPermission == MicPermissionState.granted
        ? MicPermissionState.denied
        : MicPermissionState.granted;
    notifyListeners();
  }
}
