// Widget tests for the GurasEMS Results screen and its navigation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/results_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('dashboard Quick Actions Results tile opens the results screen', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap the Results tile in the Quick Actions grid.
    await tester.ensureVisible(find.text('Results'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Results'));
    await tester.pumpAndSettle();

    // The results screen is showing its content.
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(find.text('First Terminal Exam'), findsOneWidget);
    expect(find.text('Percentage'), findsOneWidget);
    expect(find.text('GPA'), findsOneWidget);
    expect(find.text('View Full Marksheet'), findsOneWidget);
    expectNoOverflow(tester, 'the results screen');

    // Bottom nav Home tab returns to the dashboard.
    await tester.ensureVisible(find.text('Home'));
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ResultsScreen), findsNothing);
  });

  testWidgets('results term selector switches the metric row', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ResultsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('86.5%'), findsOneWidget);
    expect(find.text('3.6'), findsOneWidget);

    // Open the term list and pick the annual exam.
    await tester.tap(find.text('First Terminal Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annual Examination 2083'));
    await tester.pumpAndSettle();

    expect(find.text('91.0%'), findsOneWidget);
    expect(find.text('3.82'), findsOneWidget);
  });
}
