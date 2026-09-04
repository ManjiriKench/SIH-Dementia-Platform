import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../services/memory_service.dart';
import '../../services/profile_service.dart';

/// App Splash screen initializing offline cache, services, and establishing a calm tone.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeIn),
    );

    _pulseController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize background offline services safely
    MemoryService.instance.initialize();
    
    // Smooth, calm unhurried splash duration
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // Navigate to Language Selection on first launch
    Navigator.of(context).pushReplacementNamed(AppRoutes.language);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // Calm botanical icon representing gentle growth & memory
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWarm,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.sage.withValues(alpha: 0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.forestPrimary.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.spa,
                            size: 58,
                            color: AppColors.forestPrimary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          AppStrings.get('app_title'),
                          style: AppTypography.patientHero.copyWith(
                            fontSize: 32,
                            color: AppColors.forestPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.get('tagline'),
                          style: AppTypography.patientBody.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        // Offline & Privacy Reassurance Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sageLight.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.sage.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.offline_bolt_outlined,
                                size: 18,
                                color: AppColors.forestDark,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Works 100% Offline • Private & Safe',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
