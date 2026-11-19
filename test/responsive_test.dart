// Responsive-layout tests.
//
// Renders the splash and login screens across a spread of device shapes —
// small phones, tablets, landscape, and notched/Dynamic-Island devices — and
// fails on any framework exception, which is how a `RenderFlex` overflow or a
// SafeArea mistake surfaces in a widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/academic_information_screen.dart';
import 'package:gurasems/screens/attendance_screen.dart';
import 'package:gurasems/screens/classes_screen.dart';
import 'package:gurasems/screens/fees_screen.dart';
import 'package:gurasems/screens/guardian_information_screen.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/library_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/notices_screen.dart';
import 'package:gurasems/screens/transport_screen.dart';
import 'package:gurasems/widgets/app_bottom_nav.dart';
import 'package:gurasems/widgets/app_top_bar.dart';

import 'test_helpers.dart';

void main() {
  for (final TestDevice device in testDevices) {
    testWidgets('${device.name} renders splash and login without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(const GurasEmsApp());
      await tester.pump();

      // Splash: brand stack, both images, nothing clipped.
      expect(find.text('GurasEMS'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expectNoOverflow(tester, '${device.name} splash');

      // Then the login screen.
      await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} login');
    });

    testWidgets('${device.name} renders the dashboard without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(const GurasEmsApp());
      await tester.pump();

      await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
      await tester.pumpAndSettle();

      // Credentials are not wired up yet, so drive the same navigation the
      // Sign In button performs. It scrolls into view first because on a short
      // landscape viewport the button sits below the fold.
      await tester.ensureVisible(find.text('Sign in'));
      await tester.pumpAndSettle();
      await signIn(tester);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AppTopBar), findsOneWidget);
      expect(find.byType(AppBottomNav), findsOneWidget);
      expectNoOverflow(tester, '${device.name} dashboard');
    });

    testWidgets('${device.name} renders attendance without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AttendanceScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceScreen), findsOneWidget);
      expect(find.text('Attendance'), findsWidgets);
      expect(find.text('Bhadra 2083 (BS)'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} attendance');
    });

    testWidgets('${device.name} renders fees without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FeesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FeesScreen), findsOneWidget);
      expect(find.text('Total Fee'), findsOneWidget);
      expect(find.text('Annual Fee'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} fees');

      // Expanding the breakdown exercises the taller summary layout too.
      await tester.ensureVisible(find.text('Details'));
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.text('Simulation:'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} fees breakdown');
    });

    testWidgets('${device.name} renders classes without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ClassesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ClassesScreen), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Mathematics'), findsWidgets);
      expectNoOverflow(tester, '${device.name} timetable');

      // The month grid is the densest layout and must also fit.
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(find.text('Ashoj 2083 Calendar Overview'), findsOneWidget);
      expect(find.text('26 Teaching Days'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} timetable month');
    });

    testWidgets('${device.name} renders library without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LibraryScreen), findsOneWidget);
      expect(find.text('All Books'), findsOneWidget);
      expect(find.text('Physics Fundamentals Vol 1'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} library catalogue');

      // The issued list is the other dense layout.
      await tester.tap(find.text('Issued Books'));
      await tester.pumpAndSettle();
      expect(find.text('3 Books Borrowed'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} library issued');
    });

    testWidgets('${device.name} renders notices without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: NoticesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NoticesScreen), findsOneWidget);
      expect(find.text('Dashain Holiday Notice'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} notices');

      // The search drawer and the detail sheet are the two densest states.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expectNoOverflow(tester, '${device.name} notices search');

      await tester.tap(find.text('Dashain Holiday Notice'));
      await tester.pumpAndSettle();
      expect(find.text('Acknowledge & Close'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} notices detail');
    });

    testWidgets('${device.name} renders guardian info without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: GuardianInformationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GuardianInformationScreen), findsOneWidget);
      expect(find.text('Father / Primary Guardian'), findsOneWidget);
      expect(find.text('Mother / Secondary Guardian'), findsOneWidget);
      expect(find.text('Emergency Contact'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} guardian info');

      // The edit drawer is the densest state.
      await tester.ensureVisible(find.text('Edit Information'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Information'));
      await tester.pumpAndSettle();
      expect(find.text('Save Changes'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} guardian edit drawer');
    });

    testWidgets('${device.name} renders transport without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: TransportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TransportScreen), findsOneWidget);
      expect(find.text('Bus No. 3'), findsOneWidget);
      expect(find.text('Ram Sharma'), findsOneWidget);
      expect(find.text('Live Route Progress'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} transport');

      // The radar sheet is the densest state.
      await tester.ensureVisible(find.text('Live Radar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Live Radar'));
      await tester.pumpAndSettle();
      expect(find.text('Live GPS Radar'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} transport radar');

      // The emergency sheet is the other dense state.
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Emergency'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Emergency'));
      await tester.pumpAndSettle();
      expect(find.text('Transport Emergency Alert'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} transport emergency');
    });

    testWidgets('${device.name} renders academic info without overflow', (
      WidgetTester tester,
    ) async {
      useViewport(tester, device);
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AcademicInformationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AcademicInformationScreen), findsOneWidget);
      expect(find.text('Academic Information'), findsOneWidget);
      expect(find.text('Subjects (6)'), findsOneWidget);
      expect(find.text('Exam Routine'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} academic subjects');

      // The faculty roster is the densest tab.
      await tester.tap(find.text('Faculty'));
      await tester.pumpAndSettle();
      expect(find.text('Mr. Ramesh Adhikari'), findsOneWidget);
      expect(find.text('Dr. Anita Sharma'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} academic faculty');

      // The history tab is the other dense state with timeline chips.
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Previous Terms & Grades'), findsOneWidget);
      expect(find.text('First Terminal Exam (2083 BS)'), findsOneWidget);
      expectNoOverflow(tester, '${device.name} academic history');
    });
  }
}
