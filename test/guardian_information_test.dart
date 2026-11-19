// Widget tests for the GurasEMS Guardian Information screen and its flows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/guardian_information_screen.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/profile_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('profile menu opens guardian information and shows all cards', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    // Profile tab -> Profile screen -> Guardian Information.
    await tester.ensureVisible(find.text('Profile'));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Guardian Information'));
    await tester.tap(find.text('Guardian Information'));
    await tester.pumpAndSettle();

    // The screen and its reference content are showing.
    expect(find.byType(GuardianInformationScreen), findsOneWidget);
    expect(find.text('Guardian Information'), findsWidgets);
    expect(find.text('STUDENT PROFILE'), findsOneWidget);
    expect(find.text('Sujan Karki (Grade 10 - A)'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Father / Primary Guardian'), findsOneWidget);
    expect(find.text('Hari Karki'), findsOneWidget);
    expect(find.text('Mother / Secondary Guardian'), findsOneWidget);
    expect(find.text('Sita Karki'), findsOneWidget);
    expect(find.text('Emergency Contact'), findsOneWidget);
    expect(find.text('Hari Karki (Father)'), findsOneWidget);
    expect(find.text('Edit Information'), findsOneWidget);
    expectNoOverflow(tester, 'the guardian information screen');

    // Bottom nav Home tab returns to the dashboard.
    await tester.ensureVisible(find.text('Home'));
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(GuardianInformationScreen), findsNothing);
  });

  testWidgets('edit sheet updates the guardian cards', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GuardianInformationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Open the edit drawer.
    await tester.ensureVisible(find.text('Edit Information'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Information'));
    await tester.pumpAndSettle();

    expect(
      find.text('Update contacts or request profile update'),
      findsOneWidget,
    );
    expect(find.text('FATHER / PRIMARY GUARDIAN'), findsOneWidget);
    expect(find.text('MOTHER / SECONDARY GUARDIAN'), findsOneWidget);

    // Change the father's name and the mother's phone.
    await tester.enterText(find.byType(TextFormField).at(0), 'Bibhushan Thapa');
    await tester.enterText(find.byType(TextFormField).at(6), '9800000000');

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Cards reflect the saved record; the drawer is gone.
    expect(find.text('Bibhushan Thapa'), findsOneWidget);
    // The number appears on the mother card and as the secondary emergency.
    expect(find.text('9800000000'), findsNWidgets(2));
    expect(find.text('FATHER / PRIMARY GUARDIAN'), findsNothing);

    // The emergency card derives its person/number from the edited father.
    expect(find.text('Bibhushan Thapa (Father)'), findsOneWidget);
    expect(find.byType(GuardianInformationScreen), findsOneWidget);
  });

  testWidgets('call buttons open the confirmation sheet', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GuardianInformationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Father's call button.
    await tester.ensureVisible(find.text('Call').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call').first);
    await tester.pumpAndSettle();

    expect(find.text('Call Hari Karki'), findsOneWidget);
    expect(find.text('+977 9851023456'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Call Hari Karki'), findsNothing);
  });
}
