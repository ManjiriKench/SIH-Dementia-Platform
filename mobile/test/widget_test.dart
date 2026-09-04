import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/core/navigation/app_routes.dart';
import 'package:mobile/screens/ai_processing/domain_overview_screen.dart';
import 'package:mobile/screens/journey/todays_journey_screen.dart';
import 'package:mobile/screens/language/language_selection_screen.dart';
import 'package:mobile/screens/onboarding/caregiver_onboarding_screen.dart';
import 'package:mobile/screens/role/role_selection_screen.dart';
import 'package:mobile/screens/splash/splash_screen.dart';

void main() {
  testWidgets('Splash screen displays branding and offline badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SplashScreen(),
        routes: {
          AppRoutes.language: (context) => const Scaffold(),
        },
      ),
    );

    await tester.pump();
    expect(find.text(AppStrings.get('app_title')), findsOneWidget);
    expect(find.byIcon(Icons.spa), findsOneWidget);
    expect(find.text('Works 100% Offline • Private & Safe'), findsOneWidget);

    // Drain timer to complete navigation
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Language selection screen displays all 3 languages', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LanguageSelectionScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Choose Your Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिंदी'), findsOneWidget);
    expect(find.text('অসমীয়া'), findsOneWidget);
  });

  testWidgets('Role selection screen shows Caregiver and Patient entries', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RoleSelectionScreen(),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.get('role_caregiver')), findsOneWidget);
    expect(find.text(AppStrings.get('role_patient')), findsOneWidget);
    expect(find.text('Plain-Language Privacy & Zero Medical Claims Notice'), findsOneWidget);
  });

  testWidgets('Caregiver onboarding screen renders Step 1 and advances to Step 2', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CaregiverOnboardingScreen(),
      ),
    );
    await tester.pump();

    // Verify Step 1 content
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.text('Who are we caring for?'), findsOneWidget);
    expect(find.text('Preferred Name or Warm Greeting'), findsOneWidget);

    // Tap Next Step to go to Step 2
    await tester.tap(find.text('Next Step'));
    await tester.pump();

    // Verify Step 2 content with "I am unsure" options
    expect(find.text('Step 2 of 5'), findsOneWidget);
    expect(find.text('Comfort & Support Needs'), findsOneWidget);
    expect(find.text('I am unsure right now'), findsWidgets);
  });

  testWidgets('Domain overview screen displays all 6 domains', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DomainOverviewScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Six Cognitive Domains'), findsOneWidget);
    expect(find.text('Remember'), findsOneWidget);
    expect(find.text('Notice'), findsOneWidget);
    expect(find.text('Talk & Share'), findsOneWidget);
    expect(find.text('Plan & Sort'), findsOneWidget);
    expect(find.text('Today & Places'), findsOneWidget);
    expect(find.text('Explore & Match'), findsOneWidget);
  });

  testWidgets('Todays Journey screen renders garden path and activities', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TodaysJourneyScreen(),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.get('todays_journey')), findsOneWidget);
    expect(find.text('Is a caregiver with you right now?'), findsOneWidget);
    expect(find.text(AppStrings.get('yes_together')), findsOneWidget);
    expect(find.text(AppStrings.get('no_independent')), findsOneWidget);
  });
}
