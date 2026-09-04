import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/ai_processing/ai_processing_screen.dart';
import 'screens/ai_processing/domain_overview_screen.dart';
import 'screens/backend_test/backend_test_screen.dart';
import 'screens/language/language_selection_screen.dart';
import 'screens/onboarding/caregiver_onboarding_screen.dart';
import 'screens/role/role_selection_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DementiaAssistApp());
}

class DementiaAssistApp extends StatelessWidget {
  const DementiaAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dementia Assist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.language: (context) => const LanguageSelectionScreen(),
        AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),
        AppRoutes.caregiverOnboarding: (context) => const CaregiverOnboardingScreen(),
        AppRoutes.aiProcessing: (context) => const AiProcessingScreen(),
        AppRoutes.domainOverview: (context) => const DomainOverviewScreen(),
        '/backend_test': (context) => const BackendTestScreen(),
      },
    );
  }
}