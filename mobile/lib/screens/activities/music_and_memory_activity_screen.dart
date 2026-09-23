import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/safety/game_safety_manager.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/exit_activity_button.dart';
import '../../widgets/common/voice_instruction_bar.dart';
import '../../services/profile_service.dart';
import '../../services/session_service.dart';
import '../patient_activity/activity_completion_screen.dart';

/// Connection Together Activity 2: Music & Memory (Heartfelt Melodies).
/// Plays real soothing melodies via native AudioTrack and offers tranquil conversation prompts.
/// Voice assistant speaks once gently and pauses while the melody plays.
class MusicAndMemoryActivityScreen extends StatefulWidget {
  const MusicAndMemoryActivityScreen({super.key});

  @override
  State<MusicAndMemoryActivityScreen> createState() => _MusicAndMemoryActivityScreenState();
}

class _MusicAndMemoryActivityScreenState extends State<MusicAndMemoryActivityScreen> {
  static const MethodChannel _audioChannel = MethodChannel('com.example.mobile/audio');

  int _currentSongIndex = 0;
  bool _isPlaying = false;
  double _playbackSeconds = 0.0;
  final double _totalSeconds = 120.0;
  Timer? _playbackTimer;
  bool _isSpeakingPrompt = false;
  late final GameSafetyManager _safetyManager;

  final List<Map<String, dynamic>> _songs = [
    {
      'title': 'Borgeet Bamboo Flute (Morning Raga Bhupali)',
      'artist': 'Traditional Assam Folk Ensemble',
      'genre': 'Devotional Flute',
      'icon': Icons.music_note_rounded,
      'color': AppColors.forestPrimary,
      'bgGradient': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      'prompt': 'Does this gentle flute tune remind you of early mornings, birds singing, or festivals in Tezpur?',
      'caregiverNote': 'Humming along or gently tapping fingers to the rhythm is wonderful engagement.',
    },
    {
      'title': 'Rabindra Sangeet & Sitar (Anandadhara)',
      'artist': 'Acoustic Sitar & Esraj',
      'genre': 'Bengal & Assam Classics',
      'icon': Icons.graphic_eq_rounded,
      'color': AppColors.domainLanguage,
      'bgGradient': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
      'prompt': 'Listen to the soothing sitar strings. Who in the family loved playing or singing this melody?',
      'caregiverNote': 'Let the melody play quietly. Acknowledge whatever peaceful feelings arise.',
    },
  ];

  @override
  void initState() {
    super.initState();
    SessionService.instance.startActivityByTitle(activityTitle: 'Heartfelt Melodies');
    _safetyManager = GameSafetyManager(
      activityTitle: 'Heartfelt Melodies',
      onEndGameGracefully: _endGameGracefully,
      onAutoSkip: _nextSong,
    );
    _safetyManager.onQuestionStart();
    _startPlayback();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.stopSpeaking();
        VoiceAssistantService.instance.guideSpeak(
          'Here is a peaceful tune for you. Relax and enjoy the music.',
        );
      }
    });
  }

  void _startPlayback() {
    _isPlaying = true;
    _playbackSeconds = 0.0;
    try {
      _audioChannel.invokeMethod('play', {'songIndex': _currentSongIndex});
    } catch (_) {}

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          if (_playbackSeconds < _totalSeconds) {
            _playbackSeconds += 1.0;
          } else {
            _playbackSeconds = 0.0;
          }
        });
      }
    });
  }

  void _togglePlayPause() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
    setState(() {
      _isPlaying = !_isPlaying;
    });

    try {
      if (_isPlaying) {
        _audioChannel.invokeMethod('play', {'songIndex': _currentSongIndex});
      } else {
        _audioChannel.invokeMethod('pause');
      }
    } catch (_) {}
  }

  void _speakPrompt(String text) async {
    HapticFeedback.lightImpact();
    setState(() => _isSpeakingPrompt = true);

    // Pause music briefly while reading prompt
    try {
      _audioChannel.invokeMethod('pause');
    } catch (_) {}

    await VoiceAssistantService.instance.speak(text);

    // Resume music if it was playing
    if (_isPlaying && mounted) {
      try {
        _audioChannel.invokeMethod('play', {'songIndex': _currentSongIndex});
      } catch (_) {}
    }
    if (mounted) setState(() => _isSpeakingPrompt = false);
  }

  void _endGameGracefully() {
    _playbackTimer?.cancel();
    try {
      _audioChannel.invokeMethod('stop');
    } catch (_) {}

    SessionService.instance.completeSession();
    if (VoiceAssistantService.instance.isGuideMode) {
      VoiceAssistantService.instance.stopSpeaking();
      VoiceAssistantService.instance.guideSpeak('That was a lovely, calming musical moment.');
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ActivityCompletionScreen(
            activityTitle: 'Heartfelt Melodies',
            nextActivityTitle: 'Build the Day',
            nextRoute: AppRoutes.buildTheDay,
          ),
        ),
      );
    }
  }

  void _onSkipPressed() {
    final ended = _safetyManager.handleSkip();
    if (!ended) {
      _nextSong();
    }
  }

  void _nextSong() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
    _playbackTimer?.cancel();

    if (_currentSongIndex < _songs.length - 1) {
      setState(() {
        _currentSongIndex++;
        _playbackSeconds = 0.0;
      });
      _safetyManager.onQuestionStart();
      _startPlayback();

      if (VoiceAssistantService.instance.isGuideMode) {
        VoiceAssistantService.instance.stopSpeaking();
        final next = _songs[_currentSongIndex];
        VoiceAssistantService.instance.guideSpeak(
          'Now playing ${next['title']}. Take a deep breath and listen.',
        );
      }
    } else {
      _endGameGracefully();
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    try {
      _audioChannel.invokeMethod('stop');
    } catch (_) {}
    _safetyManager.dispose();
    super.dispose();
  }

  String _formatTime(double sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec.toInt() % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final song = _songs[_currentSongIndex];
    final title = song['title'] as String;
    final artist = song['artist'] as String;
    final genre = song['genre'] as String;
    final icon = song['icon'] as IconData;
    final color = song['color'] as Color;
    final bgGradient = song['bgGradient'] as List<Color>;
    final prompt = song['prompt'] as String;
    final caregiverNote = song['caregiverNote'] as String;
    final patient = ProfileService.instance.activeProfile;
    final favoriteGenres = patient?.favoriteMusicGenres ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWarm,
        elevation: 0,
        leading: const ExitActivityButton(),
        leadingWidth: 88,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('Heartfelt Melodies', style: AppTypography.caregiverSubheading),
        ),
        actions: [
          const GuideModeSpeakerBadge(),
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Text(
              'Melody ${_currentSongIndex + 1} of ${_songs.length}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.forestDark),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Voice guidance bar
              const VoiceInstructionBar(
                instructionText: 'Listen to the soothing melody. Let any peaceful memories surface naturally.',
                autoPlay: false,
              ),
              const SizedBox(height: 14),

              // Personalized Favorite Music Genres from Profile
              if (favoriteGenres.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_rounded, size: 14, color: AppColors.forestPrimary),
                          const SizedBox(width: 6),
                          Text(
                            "${patient?.preferredName ?? 'Loved One'}'s Favorites:",
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.forestDark),
                          ),
                        ],
                      ),
                    ),
                    ...favoriteGenres.map((g) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.forestPrimary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            g,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.textPrimary),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              // Music Player Artwork & Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bgGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon with soft animated aura
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isPlaying)
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.15),
                            ),
                          ),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.9),
                            border: Border.all(color: color, width: 2.5),
                          ),
                          child: Icon(icon, size: 48, color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      title,
                      style: AppTypography.patientTitle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$artist • $genre',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Progress Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: color,
                        inactiveTrackColor: color.withValues(alpha: 0.2),
                        thumbColor: color,
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                      ),
                      child: Slider(
                        value: _playbackSeconds.clamp(0.0, _totalSeconds),
                        max: _totalSeconds,
                        onChanged: (val) {
                          setState(() => _playbackSeconds = val);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatTime(_playbackSeconds), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(_formatTime(_totalSeconds), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Big Play/Pause Button
                    ElevatedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 30),
                      label: Text(
                        _isPlaying ? 'Pause Melody' : 'Play Melody',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Reminiscence Prompt Card
              CalmCard(
                borderColor: color.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.forum_outlined, color: AppColors.forestPrimary, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Reminiscence Prompt',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.forestDark),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isSpeakingPrompt ? Icons.volume_up : Icons.volume_up_outlined,
                            color: AppColors.forestPrimary,
                          ),
                          tooltip: 'Listen to prompt',
                          onPressed: () => _speakPrompt(prompt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt,
                      style: AppTypography.patientBody.copyWith(
                        fontSize: 17,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Caregiver note
              CalmCard(
                backgroundColor: AppColors.surfaceWarm,
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite, size: 18, color: AppColors.forestPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        caregiverNote,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Next Song action
              ElderButton(
                label: _currentSongIndex < _songs.length - 1 ? 'Next Gentle Melody' : 'Finish Music Session',
                icon: Icons.arrow_forward,
                variant: ElderButtonVariant.primary,
                height: 56,
                onPressed: _nextSong,
              ),

              const SizedBox(height: 12),

              Center(
                child: SkipQuestionButton(
                  onSkip: _onSkipPressed,
                  label: 'Skip this melody',
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
