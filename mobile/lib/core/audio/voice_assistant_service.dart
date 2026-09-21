import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

enum MicPermissionState { notDetermined, granted, denied }

/// Pool of warm celebration phrases for patient-facing activities.
enum CelebrationPool {
  goodJob,
  cardFlipped,
  allMatched,
  roundComplete,
  activityDone,
  memoryFound,
  encouragement,
  gentle,
}

/// Voice assistant service managing:
/// - Screen text-to-speech with natural calm pacing
/// - Guide Mode: one-tap activation that auto-narrates the entire session
/// - Sequence speaking: queue multiple phrases with breathing gaps
/// - Celebration pool: warm, culturally resonant phrases for dementia care
/// - Voice recording with transcription fallback (caregiver notes)
class VoiceAssistantService extends ChangeNotifier {
  static final VoiceAssistantService instance = VoiceAssistantService._internal();
  VoiceAssistantService._internal();

  static const MethodChannel _ttsChannel = MethodChannel('com.example.mobile/tts');
  final _random = Random();

  // ============================================================
  // CORE STATE
  // ============================================================
  bool _isSpeaking = false;
  String _currentSpeakingText = '';
  double _speechRate = 0.82; // Slightly slower for elders — calm and unhurried
  double _volume = 1.0;
  Timer? _ttsTimer;

  // ============================================================
  // GUIDE MODE — one button activates complete end-to-end narration
  // ============================================================
  bool _isGuideMode = false;

  bool get isGuideMode => _isGuideMode;

  void setGuideMode(bool enabled) {
    _isGuideMode = enabled;
    notifyListeners();
    persistGuideMode();
    if (enabled) {
      speak('Voice guide is now active. I will be with you every step of the way.');
    } else {
      stopSpeaking();
    }
  }

  void toggleGuideMode() => setGuideMode(!_isGuideMode);

  /// Persists guide mode state so it survives app restarts.
  Future<void> persistGuideMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('smriti_guide_mode', _isGuideMode);
    } catch (e) {
      debugPrint('[Voice] Failed to persist guide mode: $e');
    }
  }

  /// Loads guide mode state from SharedPreferences on app start.
  Future<void> loadGuideMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool('smriti_guide_mode') ?? false;
      if (saved != _isGuideMode) {
        _isGuideMode = saved;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Voice] Failed to load guide mode: $e');
    }
  }

  /// Greets the patient with a time-of-day appropriate warm greeting.
  Future<void> greetPatient(String patientName) async {
    if (!_isGuideMode) return;
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      timeGreeting = 'Good evening';
    } else {
      timeGreeting = 'Welcome back';
    }
    await speakSequence([
      '$timeGreeting, $patientName! It is lovely to see you.',
      'Let us have a peaceful and joyful session together today.',
    ], gapBetweenMs: 700);
  }

  // ============================================================
  // VOICE RECORDING STATE (Caregiver feedback & notes)
  // ============================================================
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  MicPermissionState _micPermission = MicPermissionState.granted;
  bool _isTranscribing = false;

  // ============================================================
  // GETTERS
  // ============================================================
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

  // ============================================================
  // CORE SPEAK — speaks one piece of text with calm pacing
  // ============================================================
  Future<void> speak(String text) async {
    stopSpeaking();
    _isSpeaking = true;
    _currentSpeakingText = text;
    notifyListeners();

    try {
      final lang = AppStrings.currentLanguage;
      await _ttsChannel.invokeMethod('speak', {
        'text': text,
        'rate': _speechRate,
        'language': lang,
        'volume': _volume,
      });
    } catch (e) {
      debugPrint('[Voice] TTS channel: $e');
    }

    // Estimate duration from word count + natural trailing pause
    final words = text.split(' ').length;
    final durationMs = ((words / (2.1 * _speechRate)) * 1000).clamp(2500.0, 14000.0).toInt();

    _ttsTimer = Timer(Duration(milliseconds: durationMs), () {
      _isSpeaking = false;
      _currentSpeakingText = '';
      notifyListeners();
    });
  }

  // ============================================================
  // SPEAK WITH PAUSE — adds a natural breathing gap before speaking
  // ============================================================
  Future<void> speakWithPause(String text, {int pauseMs = 800}) async {
    await Future.delayed(Duration(milliseconds: pauseMs));
    await speak(text);
  }

  // ============================================================
  // SPEAK SEQUENCE — narrates a list of lines one after another
  // ============================================================
  Future<void> speakSequence(List<String> lines, {int gapBetweenMs = 600}) async {
    for (final line in lines) {
      if (!_isGuideMode && !_isSpeaking) return;
      await speak(line);
      final words = line.split(' ').length;
      final durationMs = ((words / (2.1 * _speechRate)) * 1000).clamp(2500.0, 14000.0).toInt();
      await Future.delayed(Duration(milliseconds: durationMs + gapBetweenMs));
    }
  }

  // ============================================================
  // GUIDE MODE SPEAK — only speaks if Guide Mode is active
  // ============================================================
  Future<void> guideSpeak(String text, {int pauseMs = 500}) async {
    if (!_isGuideMode) return;
    await speakWithPause(text, pauseMs: pauseMs);
  }

  // ============================================================
  // GUIDE MODE SEQUENCE — only runs if Guide Mode is active
  // ============================================================
  Future<void> guideSequence(List<String> lines, {int gapMs = 600}) async {
    if (!_isGuideMode) return;
    await speakSequence(lines, gapBetweenMs: gapMs);
  }

  // ============================================================
  // INTRODUCE SELF — warm first-time greeting to patient
  // ============================================================
  Future<void> introduceSelf(String patientName) async {
    await speakSequence([
      'Hello $patientName. I am your gentle voice companion today.',
      'I will read everything for you and stay with you every step of the way.',
      'There is no rush at all. Let us begin whenever you are ready.',
    ], gapBetweenMs: 800);
  }

  // ============================================================
  // CELEBRATION POOL — warm, culturally resonant encouragement
  // ============================================================
  static const Map<CelebrationPool, List<String>> _celebrations = {
    CelebrationPool.goodJob: [
      'Wonderful! You are doing beautifully.',
      'Shabash! That is perfect.',
      'Very good. What a lovely answer.',
      'That is exactly right. Well done!',
      'Beautiful. You remembered that perfectly.',
    ],
    CelebrationPool.cardFlipped: [
      'Oh! Who do you see there?',
      'Look carefully. Who is this?',
      'A familiar face! Take your time.',
      'Can you remember them?',
    ],
    CelebrationPool.allMatched: [
      'You found everyone! How wonderful.',
      'All matched! What a beautiful memory.',
      'You remembered all of them. Truly lovely.',
    ],
    CelebrationPool.roundComplete: [
      'Well done! You have finished this round.',
      'Shabash! Ready for the next one?',
      'Wonderful effort. Let us continue gently.',
    ],
    CelebrationPool.activityDone: [
      'You did a wonderful job today. What a peaceful, beautiful time.',
      'That was lovely. You should feel very proud of yourself.',
      'What a gentle, joyful journey. Thank you for sharing this time.',
    ],
    CelebrationPool.memoryFound: [
      'What a warm memory. Hold that feeling.',
      'That is a cherished moment. Thank you for remembering.',
      'What a beautiful thought.',
    ],
    CelebrationPool.encouragement: [
      'Take your time. There is no rush here.',
      'You are doing wonderfully. Keep going.',
      'Every step is perfect, at any pace.',
      'You are doing great. I am right here with you.',
    ],
    CelebrationPool.gentle: [
      'No worries at all. Let us try again gently.',
      'That is perfectly fine. Let us continue together.',
      'It is all right. We are in no hurry today.',
    ],
  };

  /// Speaks a random warm phrase from the chosen celebration pool.
  Future<void> celebrateAction(CelebrationPool pool) async {
    final phrases = _celebrations[pool] ?? _celebrations[CelebrationPool.encouragement]!;
    final phrase = phrases[_random.nextInt(phrases.length)];
    await speak(phrase);
  }

  /// Celebrate only in guide mode.
  Future<void> guideCelebrate(CelebrationPool pool) async {
    if (!_isGuideMode) return;
    await celebrateAction(pool);
  }

  // ============================================================
  // STOP
  // ============================================================
  void stopSpeaking() {
    _ttsTimer?.cancel();
    try {
      _ttsChannel.invokeMethod('stop');
    } catch (_) {}
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

  // ============================================================
  // VOICE RECORDING (Caregiver mode — voice notes & feedback)
  // ============================================================
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
    return 'Grandmother appeared calm and recognized the tea garden photo. She hummed along to the tune for a few seconds.';
  }

  void toggleMicPermission() {
    _micPermission = _micPermission == MicPermissionState.granted
        ? MicPermissionState.denied
        : MicPermissionState.granted;
    notifyListeners();
  }
}
