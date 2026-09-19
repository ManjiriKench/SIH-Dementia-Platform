import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/activities/build_the_day_activity_screen.dart';
import 'screens/activities/colour_word_focus_activity_screen.dart';
import 'screens/activities/family_match_activity_screen.dart';
import 'screens/activities/familiar_object_match_activity_screen.dart';
import 'screens/activities/look_and_talk_activity_screen.dart';
import 'screens/activities/music_and_memory_activity_screen.dart';
import 'screens/activities/remember_recall_activity_screen.dart';
import 'screens/activities/story_from_photo_activity_screen.dart';
import 'screens/ai_processing/ai_processing_screen.dart';
import 'screens/ai_processing/domain_overview_screen.dart';
import 'screens/backend_test/backend_test_screen.dart';
import 'screens/dashboard/caregiver_dashboard_screen.dart';
import 'screens/feedback/caregiver_feedback_screen.dart';
import 'screens/journey/todays_journey_screen.dart';
import 'screens/language/language_selection_screen.dart';
import 'screens/memory/personal_memory_space_screen.dart';
import 'screens/onboarding/caregiver_onboarding_screen.dart';
import 'screens/onboarding/caregiver_welcome_screen.dart';
import 'screens/patient_activity/activity_completion_screen.dart';
import 'screens/patient_activity/activity_shell_screen.dart';
import 'screens/role/role_selection_screen.dart';
import 'screens/session_mode/caregiver_presence_selection_screen.dart';
import 'screens/session_mode/independent_mode_entry_screen.dart';
import 'screens/session_mode/together_mode_entry_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/system_states/patient_system_states_screen.dart';
import 'services/profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStrings.loadSavedLanguage();
  runApp(const DementiaAssistApp());
}

class DementiaAssistApp extends StatelessWidget {
  const DementiaAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, currentLanguage, _) {
        return ListenableBuilder(
          listenable: ProfileService.instance,
          builder: (context, _) {
            final isLarge = ProfileService.instance.activeProfile?.readingComfort == 'prefers_large_text';
            final textScale = isLarge ? 1.15 : 1.0;

            return MaterialApp(
              key: ValueKey(currentLanguage),
              title: 'Smriti',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.caregiverWelcome: (context) => const CaregiverWelcomeScreen(),
            AppRoutes.language: (context) => const LanguageSelectionScreen(),
            AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),
            AppRoutes.caregiverOnboarding: (context) => const CaregiverOnboardingScreen(),
            AppRoutes.aiProcessing: (context) => const AiProcessingScreen(),
            AppRoutes.domainOverview: (context) => const DomainOverviewScreen(),
            AppRoutes.todaysJourney: (context) => const TodaysJourneyScreen(),
            AppRoutes.memoryVault: (context) => const PersonalMemorySpaceScreen(),
            AppRoutes.sessionTriage: (context) => const CaregiverPresenceSelectionScreen(),
            AppRoutes.togetherModeEntry: (context) => const TogetherModeEntryScreen(),
            AppRoutes.independentModeEntry: (context) => const IndependentModeEntryScreen(),
            AppRoutes.activityShell: (context) => const ActivityShellScreen(),

            // 8 Specific Dementia Activity Screens
            AppRoutes.lookAndTalk: (context) => const LookAndTalkActivityScreen(),
            AppRoutes.musicAndMemory: (context) => const MusicAndMemoryActivityScreen(),
            AppRoutes.storyFromPhoto: (context) => const StoryFromPhotoActivityScreen(),
            AppRoutes.familyMatch: (context) => const FamilyMatchActivityScreen(),
            AppRoutes.buildTheDay: (context) => const BuildTheDayActivityScreen(),
            AppRoutes.familiarObjectMatch: (context) => const FamiliarObjectMatchActivityScreen(),
            AppRoutes.rememberRecall: (context) => const RememberRecallActivityScreen(),
            AppRoutes.colourWordFocus: (context) => const ColourWordFocusActivityScreen(),

            // Backwards compatibility aliases
            AppRoutes.independentMatch: (context) => const FamiliarObjectMatchActivityScreen(),
            AppRoutes.cognitiveTogether: (context) => const FamilyMatchActivityScreen(),
            AppRoutes.connectionMusic: (context) => const MusicAndMemoryActivityScreen(),

            // Session completion, feedback, dashboard & system showcase
            AppRoutes.sessionCompletion: (context) => const ActivityCompletionScreen(),
            AppRoutes.caregiverFeedback: (context) => const CaregiverFeedbackScreen(),
            AppRoutes.caregiverDashboard: (context) => const CaregiverDashboardScreen(),
            AppRoutes.systemStatesShowcase: (context) => const PatientSystemStatesScreen(),
            '/backend_test': (context) => const BackendTestScreen(),
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => const ActivityShellScreen(),
          ),
        );
          },
        );
      },
    );
  }
}