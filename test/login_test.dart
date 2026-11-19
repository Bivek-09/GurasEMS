// Tests for login validation, loading behaviour and the recovery/help flows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';

import 'test_helpers.dart';

/// Opens the app and waits for the login screen to settle.
Future<void> _openLogin(WidgetTester tester) async {
  useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
  await tester.pumpWidget(const GurasEmsApp());
  await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
  await tester.pumpAndSettle();
}

Future<void> _fill(
  WidgetTester tester, {
  required String id,
  required String password,
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), id);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.pump();
}

void main() {
  testWidgets('empty fields block sign-in and explain what is missing', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your student ID or email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a short password is rejected inline', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    await _fill(tester, id: 'STU-2083-0156', password: '123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('valid credentials sign in and show a loading state', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    await _fill(tester, id: 'STU-2083-0156', password: 'student123');
    await tester.tap(find.text('Sign in'));

    // The button swaps to a spinner while the async development auth runs.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('forgot password opens the recovery flow', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('Contact office'), findsOneWidget);
  });

  testWidgets('help opens sign-in instructions', (WidgetTester tester) async {
    await _openLogin(tester);

    await tester.tap(find.text('Need help signing in?'));
    await tester.pumpAndSettle();

    expect(find.text('Sign-in help'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });
}
