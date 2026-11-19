// Widget tests for the GurasEMS Academic Information screen and its route.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/academic_information_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/profile_screen.dart';

import 'test_helpers.dart';

Widget _host() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: AcademicInformationScreen(),
);

void main() {
  testWidgets('summary card and the six enrolled subjects render', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('Academic Information'), findsOneWidget);
    expect(find.text('Sujan Karki'), findsOneWidget);
    expect(find.text('3.65'), findsOneWidget);
    expect(find.text('STU-2083-0156'), findsOneWidget);
    expect(find.text('Subjects (6)'), findsOneWidget);

    // The six curriculum cards.
    expect(find.text('Compulsory Mathematics'), findsOneWidget);
    expect(find.text('Science & Technology'), findsOneWidget);
    expect(find.text('English Literature'), findsOneWidget);
    expect(find.text('Nepali (नेपाली)'), findsOneWidget);
    expect(find.text('Social Studies'), findsOneWidget);
    expect(find.text('Computer Science'), findsOneWidget);

    // The first card starts expanded, so its action row is built; a collapsed
    // card's row is not.
    expect(find.text('View Syllabus & Notes'), findsOneWidget);
    expect(find.text('View Lab Exercises & Tasks'), findsNothing);

    expect(find.text('Exam Routine'), findsOneWidget);
    expect(find.text('Mark Sheet'), findsOneWidget);
    expectNoOverflow(tester, 'the academic information screen');
  });

  testWidgets('a subject accordion collapses and expands', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('View Syllabus & Notes'), findsOneWidget);

    await tester.tap(find.text('Compulsory Mathematics'));
    await tester.pumpAndSettle();
    expect(find.text('View Syllabus & Notes'), findsNothing);

    await tester.tap(find.text('Compulsory Mathematics'));
    await tester.pumpAndSettle();
    expect(find.text('View Syllabus & Notes'), findsOneWidget);
  });

  testWidgets('tabs switch to faculty and history', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    expect(find.text('Mr. Ramesh Adhikari'), findsOneWidget);
    expect(find.text('Dr. Anita Sharma'), findsOneWidget);
    expect(find.text('Compulsory Mathematics'), findsNothing);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Previous Terms & Grades'), findsOneWidget);
    expect(find.text('First Terminal Exam (2083 BS)'), findsOneWidget);
    expect(find.text('Grade 9 - Final Board Exam'), findsOneWidget);
    expectNoOverflow(tester, 'the history tab');
  });

  testWidgets('the syllabus action opens the subject sheet and downloads', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Syllabus & Notes'));
    await tester.pumpAndSettle();

    expect(find.text('CHAPTERS & SYLLABUS UNITS'), findsOneWidget);
    expect(find.text('Unit 1: Sets & Real Numbers'), findsOneWidget);
    expect(
      find.text('Unit 5: Trigonometry: Heights & Distances'),
      findsOneWidget,
    );
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    await tester.tap(find.text('Download Lecture Notes (.PDF)'));
    await tester.pumpAndSettle();
    expect(
      find.text('Downloading complete notes and lecture materials...'),
      findsOneWidget,
    );
  });

  testWidgets('the exam routine shortcut opens the routine sheet', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Exam Routine'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exam Routine'));
    await tester.pumpAndSettle();

    expect(find.text('Term II Examination Routine'), findsOneWidget);
    expect(find.text('DAY 1 • MANGSIR 28'), findsOneWidget);
    expect(find.text('Room 101'), findsOneWidget);

    await tester.ensureVisible(find.text('Download Routine (PDF)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download Routine (PDF)'));
    await tester.pumpAndSettle();
    expect(
      find.text('Downloading Term II Exam Routine PDF...'),
      findsOneWidget,
    );
  });

  testWidgets('the mark sheet shortcut opens the interim transcript', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Mark Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Term II Terminal Mark Sheet (Interim)'), findsOneWidget);
    expect(find.text('A+ (92 / 100)'), findsOneWidget);

    await tester.tap(find.text('Download PDF Transcript'));
    await tester.pumpAndSettle();
    expect(find.text('Downloading Official Transcript PDF...'), findsOneWidget);
  });

  testWidgets('faculty query validates an empty note then sends', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Faculty'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Query to Mr. Ramesh Adhikari'), findsOneWidget);

    // Sending an empty note is refused.
    await tester.tap(find.text('Send Message'));
    await tester.pumpAndSettle();
    expect(
      find.text('Please enter a short message for the teacher.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextField).last,
      'Please clarify the homework deadline.',
    );
    await tester.tap(find.text('Send Message'));
    await tester.pumpAndSettle();
    expect(find.text('Message sent successfully to teacher!'), findsOneWidget);
  });

  testWidgets('the profile menu opens academic information and back returns', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();

    // Profile is the fourth bottom-nav destination.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Academic Information'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Academic Information'));
    await tester.pumpAndSettle();
    expect(find.byType(AcademicInformationScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(AcademicInformationScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
