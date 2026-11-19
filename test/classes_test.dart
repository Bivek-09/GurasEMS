// Widget tests for the GurasEMS Timetable (Classes) screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/classes_screen.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';

import 'test_helpers.dart';

/// Signs in from the splash screen and lands on the dashboard.
Future<void> _signIn(WidgetTester tester) async {
  await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
  await tester.pumpAndSettle();
  await signIn(tester);
  await tester.pumpAndSettle();
}

/// Opens the timetable through the dashboard's Classes quick action.
Future<void> _openClasses(WidgetTester tester) async {
  useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
  await tester.pumpWidget(const GurasEmsApp());
  await _signIn(tester);

  await tester.ensureVisible(find.text('Classes'));
  await tester.tap(find.text('Classes'));
  await tester.pumpAndSettle();
  expect(find.byType(ClassesScreen), findsOneWidget);
}

/// Runs the jump-to-today highlight timer to completion so no timer outlives
/// the test.
Future<void> _drainHighlight(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1600));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dashboard Classes tile opens the timetable week view', (
    WidgetTester tester,
  ) async {
    await _openClasses(tester);

    // The app bar carries the screen title.
    expect(
      find.descendant(
        of: find.byType(ClassesScreen),
        matching: find.text('Timetable'),
      ),
      findsOneWidget,
    );

    // Week / Month segmented control and the range sub-header.
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('ASHOJ 2083 (BS) • TERM II'), findsOneWidget);
    expect(find.text('Today: Mon 15'), findsOneWidget);

    // The whole working week is laid out, Monday first.
    for (final String day in <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri']) {
      expect(find.text(day), findsOneWidget);
    }
    expect(find.text('Mathematics'), findsNWidgets(2));
    expect(find.text('Science'), findsNWidgets(2));
    expect(find.text('English'), findsNWidgets(2));
    expect(find.text('Physical Training'), findsOneWidget);
    expect(find.text('09:00 - 09:45'), findsWidgets);

    expectNoOverflow(tester, 'timetable week');
  });

  testWidgets('Month toggle reveals the calendar and its notice', (
    WidgetTester tester,
  ) async {
    await _openClasses(tester);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();

    expect(find.text('MONTHLY CALENDAR VIEW'), findsOneWidget);
    expect(find.text('Ashoj 2083'), findsOneWidget);
    expect(find.text('Ashoj 2083 Calendar Overview'), findsOneWidget);
    expect(find.text('26 Teaching Days'), findsOneWidget);
    expect(find.text('Monthly Assessment Notice'), findsOneWidget);
    expect(
      find.text('Tap any active day to view schedule details.'),
      findsOneWidget,
    );
    // The week list is gone while the month grid is showing.
    expect(find.text('Mathematics'), findsNothing);

    expectNoOverflow(tester, 'timetable month');

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(find.text('Today: Mon 15'), findsOneWidget);
    expect(find.text('Mathematics'), findsNWidgets(2));
  });

  testWidgets('tapping a period opens the lecture detail sheet', (
    WidgetTester tester,
  ) async {
    await _openClasses(tester);

    await tester.tap(find.text('Mathematics').first);
    await tester.pumpAndSettle();

    // The sheet summarises the period and its lecture.
    expect(find.text('Lecture Detail'), findsOneWidget);
    expect(find.text('Mathematics'), findsWidgets);
    expect(find.text('09:00 - 09:45'), findsWidgets);
    expect(find.text('Classroom:'), findsOneWidget);
    expect(find.text('Room 101'), findsWidgets);
    expect(find.text('Instructor:'), findsOneWidget);
    expect(find.text('Mr. Ramesh Karki'), findsOneWidget);
    expect(find.text('Topic:'), findsOneWidget);
    expect(find.text('Algebra & Quadratic Equations'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('Lecture Detail'), findsNothing);

    expectNoOverflow(tester, 'timetable detail sheet');
  });

  testWidgets('the calendar control jumps back to the week view', (
    WidgetTester tester,
  ) async {
    await _openClasses(tester);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(find.text('Ashoj 2083 Calendar Overview'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Today: Mon 15'), findsOneWidget);
    expect(find.text('Ashoj 2083 Calendar Overview'), findsNothing);

    await _drainHighlight(tester);
    expectNoOverflow(tester, 'timetable jump to today');
  });

  testWidgets('the dashboard Timetable tile opens the same screen', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());
    await _signIn(tester);

    await tester.ensureVisible(find.text('Timetable'));
    await tester.tap(find.text('Timetable'));
    await tester.pumpAndSettle();

    expect(find.byType(ClassesScreen), findsOneWidget);
    expect(find.text('Mathematics'), findsNWidgets(2));
  });

  testWidgets("dashboard Today's Classes View All opens the timetable and back "
      'returns home', (WidgetTester tester) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());
    await _signIn(tester);

    await tester.ensureVisible(find.text('View All'));
    await tester.tap(find.text('View All'));
    await tester.pumpAndSettle();
    expect(find.byType(ClassesScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ClassesScreen), findsNothing);
  });
}
