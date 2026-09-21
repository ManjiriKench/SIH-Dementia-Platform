import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/voice_assistant_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_routes.dart';
import '../../services/profile_service.dart';

/// Smriti Splash Screen.
/// Pure, calm, unhurried — just the name and lotus in the center.
/// - Returning users: gentle glow + fetching, then directly to journey.
/// - First-time users: name fades in, then "Start" appears softly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _buttonController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;
  bool _showStartButton = false;
  bool _isReturningUser = false;

  @override
  void initState() {
    super.initState();

    // Logo animation — slow gentle fade & gentle scale
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Button animation — slides up gently
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    _logoController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkUserFlow();
      }
    });
  }

  Future<void> _checkUserFlow() async {
    await ProfileService.instance.loadProfile(useMock: false);
    final hasProfile = ProfileService.instance.hasProfile;

    if (hasProfile) {
      if (!mounted) return;
      setState(() => _isReturningUser = true);
      final profile = ProfileService.instance.activeProfile;
      if (profile != null) {
        VoiceAssistantService.instance.greetPatient(profile.preferredName);
      }
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
    } else {
      // Show logo, then reveal Start button
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _showStartButton = true);
      _buttonController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _logoController,
          builder: (context, _) {
            return Opacity(
              opacity: _logoFade.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Lotus icon — large, warm, centered
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarm,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.forestPrimary.withValues(alpha: 0.25),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestPrimary.withValues(alpha: 0.12),
                            blurRadius: 36,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 62,
                        color: AppColors.forestPrimary,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // App name — large, warm, confident
                    Text(
                      AppStrings.get('app_title'),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestPrimary,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline — warm, readable
                    Text(
                      AppStrings.get('tagline'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // ASTEYA Co-branding Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.forestPrimary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.eco_rounded,
                            size: 14,
                            color: AppColors.forestPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AN ASTEYA INITIATIVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: AppColors.forestDark.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Returning user state
                    if (_isReturningUser) ...[
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.forestPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppStrings.get('fetching_profile'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],

                    // First-time user: Start button slides up
                    if (_showStartButton && !_isReturningUser)
                      AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, _) {
                          return Opacity(
                            opacity: _buttonFade.value,
                            child: SlideTransition(
                              position: _buttonSlide,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 62,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.of(context)
                                            .pushReplacementNamed(AppRoutes.caregiverWelcome),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.forestPrimary,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shadowColor: AppColors.forestPrimary.withValues(alpha: 0.35),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          AppStrings.get('start_button'),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    if (!_showStartButton && !_isReturningUser)
                      const SizedBox(height: 90),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
