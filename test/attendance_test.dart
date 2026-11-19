// Widget tests for the GurasEMS Attendance screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/attendance_screen.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/profile_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets(
    'dashboard Academics tab opens the attendance screen and interacts',
    (WidgetTester tester) async {
      useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
      await tester.pumpWidget(const GurasEmsApp());

      await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
      await tester.pumpAndSettle();
      await signIn(tester);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // 1 ─ Open Attendance via bottom nav 'Academics' tab
      await tester.ensureVisible(find.text('Academics'));
      await tester.tap(find.text('Academics'));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceScreen), findsOneWidget);
      expect(find.text('Attendance'), findsWidgets);
      expect(find.text('Bhadra 2083 (BS)'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('18'), findsWidgets); // Present count & day 18
      expect(find.text('20'), findsWidgets); // Total count & day 20

      // 2 ─ Switch month to Shrawan
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Shrawan 2083 (BS)'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('19'), findsWidgets); // Present count & day 19

      // 3 ─ Switch month to Bhadra then Ashoj
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Bhadra 2083 (BS)'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Ashoj 2083 (BS)'), findsOneWidget);
      expect(find.text('89%'), findsOneWidget);

      // Switch back to Bhadra for day inspection
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Bhadra 2083 (BS)'), findsOneWidget);

      // 4 ─ Tap a day cell to inspect attendance bottom sheet
      // Day 19 in Bhadra is Absent
      await tester.tap(find.text('19'));
      await tester.pumpAndSettle();

      expect(find.text('Bhadra 2083 (BS) · Day 19'), findsOneWidget);
      expect(find.text('Absent'), findsWidgets);
      expect(find.text('Unexcused Absence'), findsOneWidget);

      // Dismiss bottom sheet
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Unexcused Absence'), findsNothing);

      // 5 ─ Top bar back button returns to dashboard
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AttendanceScreen), findsNothing);
    },
  );

  testWidgets(
    'dashboard Quick Actions Attendance tile opens attendance screen',
    (WidgetTester tester) async {
      useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
      await tester.pumpWidget(const GurasEmsApp());

      await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
      await tester.pumpAndSettle();
      await signIn(tester);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Tap Attendance tile in Quick Actions Grid
      await tester.ensureVisible(find.text('Attendance'));
      await tester.tap(find.text('Attendance'));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceScreen), findsOneWidget);

      // Bottom nav Home tab returns to HomeScreen
      await tester.ensureVisible(find.text('Home'));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AttendanceScreen), findsNothing);
    },
  );

  testWidgets('bottom nav switching between Attendance and Profile', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();

    // Go to Attendance
    await tester.tap(find.text('Academics'));
    await tester.pumpAndSettle();
    expect(find.byType(AttendanceScreen), findsOneWidget);

    // Tap Profile from Attendance bottom nav
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(AttendanceScreen), findsNothing);
  });
}
