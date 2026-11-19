// Widget tests for the GurasEMS splash -> login flow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/personal_information_screen.dart';
import 'package:gurasems/screens/profile_screen.dart';
import 'package:gurasems/screens/splash_screen.dart';
import 'package:gurasems/widgets/app_bottom_nav.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('edit personal information updates the card', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PersonalInformationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Sheet opens showing the current record.
    await tester.ensureVisible(find.text('Edit Information'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Information'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Personal Information'), findsOneWidget);

    // Edit the full name and save.
    await tester.enterText(find.byType(TextFormField).first, 'Bibhushan Thapa');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Card now shows the new name; the sheet is gone.
    expect(find.text('Bibhushan Thapa'), findsOneWidget);
    expect(find.text('Edit Personal Information'), findsNothing);
  });

  testWidgets('dashboard Profile tab opens the profile screen', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign in'));
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    // The Profile tab is the only bottom destination wired so far.
    await tester.ensureVisible(find.text('Profile'));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Sujan Karki'), findsOneWidget);

    // The profile app bar's back control returns to the dashboard.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
  });

  testWidgets('full flow: splash -> login -> dashboard', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    // 1 ─ App opens on the splash.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);

    // 2 ─ Splash plays out and hands off to login.
    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);

    // 3 ─ Sign In opens the dashboard.
    await signIn(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expectNoOverflow(tester, 'the dashboard');

    // 4 ─ Every dashboard section is on screen.
    expect(find.text('Sujan Karki'), findsOneWidget);
    expect(find.text('Keep learning\nand keep growing'), findsOneWidget);
    expect(find.text('Today\'s Classes'), findsOneWidget);
    // The classes card shows the next lecture's subject.
    expect(find.text('Mathematics'), findsWidgets);
    expect(find.byType(AppBottomNav), findsOneWidget);

    // 5 ─ Login was replaced, not stacked: back leaves the app, not the login.
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('More tile opens the services sheet and routes to the profile', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());
    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);

    await tester.ensureVisible(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    // The sheet lists only destinations that already exist off the grid.
    expect(find.text('More Services'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);

    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();

    // The sheet is gone; the profile replaced it on the stack.
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('More Services'), findsNothing);
  });

  testWidgets('splash plays its sequence then hands off to login', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());
    await tester.pump();

    // 1 ─ The splash is the entry route and the brand stack is present.
    expect(find.text('GurasEMS'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Your Learning Journey\nin One Place'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.byType(LoginScreen), findsNothing);
    expectNoOverflow(tester, 'the splash screen');

    // 2 ─ Wait out the choreography and the hold that follows it.
    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();

    // 3 ─ Login is showing and the splash has been torn down.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('GurasEMS'), findsNothing);
    expect(find.text('Student'), findsNothing);
    expectNoOverflow(tester, 'the transition to login');

    // 4 ─ The splash was removed from the stack, so back can never reach it.
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('login exposes the expected form controls', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());
    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    expectNoOverflow(tester, 'the login screen');

    expect(find.text('Student ID or email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);

    // The password visibility toggle actually flips the field's obscure state.
    bool isObscured() => tester
        .widget<EditableText>(
          find.descendant(
            of: find.byType(TextField).last,
            matching: find.byType(EditableText),
          ),
        )
        .obscureText;

    expect(isObscured(), isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(isObscured(), isFalse);
  });
}
