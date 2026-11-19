// Widget tests for the GurasEMS Library screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/library_screen.dart';
import 'package:gurasems/screens/login_screen.dart';

import 'test_helpers.dart';

/// Signs in from the splash screen and lands on the dashboard.
Future<void> _signIn(WidgetTester tester) async {
  await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
  await tester.pumpAndSettle();
  await signIn(tester);
  await tester.pumpAndSettle();
}

/// Opens the library through the dashboard's Library quick action.
Future<void> _openLibrary(WidgetTester tester) async {
  useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
  await tester.pumpWidget(const GurasEmsApp());
  await _signIn(tester);

  await tester.ensureVisible(find.text('Library'));
  await tester.tap(find.text('Library'));
  await tester.pumpAndSettle();
  expect(find.byType(LibraryScreen), findsOneWidget);
}

/// Switches the library to its borrowed-books tab.
Future<void> _openIssuedTab(WidgetTester tester) async {
  await tester.tap(find.text('Issued Books'));
  await tester.pumpAndSettle();
}

/// Lets a toast's timer elapse so it cannot shadow a later tap.
Future<void> _drainToast(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 2500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dashboard Library tile opens the catalogue', (
    WidgetTester tester,
  ) async {
    await _openLibrary(tester);

    expect(
      find.descendant(
        of: find.byType(LibraryScreen),
        matching: find.text('Library'),
      ),
      findsOneWidget,
    );

    // The reference opens on the All Books tab.
    expect(find.text('Issued Books'), findsOneWidget);
    expect(find.text('All Books'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);

    // The catalogue rows, with their availability badges and actions.
    expect(find.text('RACK A-12'), findsOneWidget);
    expect(find.text('Physics Fundamentals Vol 1'), findsOneWidget);
    expect(find.text('Author: H. C. Verma'), findsOneWidget);
    expect(find.text('Available (4)'), findsOneWidget);
    expect(find.text('Advanced Coordinate Geometry'), findsOneWidget);
    expect(find.text('Reserved (1 left)'), findsOneWidget);
    expect(find.text('Shakespeare: Selected Plays'), findsOneWidget);
    expect(find.text('Request Book'), findsNWidgets(3));
    expect(find.text('Details'), findsNWidgets(3));

    expectNoOverflow(tester, 'library catalogue');
  });

  testWidgets('Issued Books tab shows the borrowed summary and cards', (
    WidgetTester tester,
  ) async {
    await _openLibrary(tester);
    await _openIssuedTab(tester);

    // Borrowed / quota summary with the overdue chip.
    expect(find.text('3 Books Borrowed'), findsOneWidget);
    expect(find.text('Quota limit: 4 books'), findsOneWidget);
    expect(find.text('1 Overdue'), findsOneWidget);

    // The three loans, each with its due-date badge.
    expect(find.text('Mathematics Grade 10'), findsOneWidget);
    expect(find.text('Science Practical Book'), findsOneWidget);
    expect(find.text('English Literature'), findsOneWidget);
    expect(find.text('Issued: 2083-06-10'), findsOneWidget);
    expect(find.text('Due in 5 days'), findsOneWidget);
    expect(find.text('Overdue 7 days'), findsOneWidget);
    expect(find.text('Due in 20 days'), findsOneWidget);
    expect(find.textContaining('Overdue fines accrue'), findsOneWidget);

    // The catalogue search field is gone while the issued list shows.
    expect(find.byType(TextField), findsNothing);

    expectNoOverflow(tester, 'library issued');
  });

  testWidgets('tapping an issued book opens the detail sheet and renews', (
    WidgetTester tester,
  ) async {
    await _openLibrary(tester);
    await _openIssuedTab(tester);

    await tester.tap(find.text('Mathematics Grade 10'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics Grade 10'), findsWidgets);
    expect(find.text('Grade 10 Textbook Board'), findsOneWidget);
    expect(find.text('Due in 5 days'), findsWidgets);
    expect(find.text('Accession No.'), findsOneWidget);
    expect(find.text('LIB-2083-9942'), findsOneWidget);
    expect(find.text('Issued On'), findsOneWidget);
    expect(find.text('2083-06-10'), findsOneWidget);
    expect(find.text('Due Date'), findsOneWidget);
    expect(find.text('2083-09-10'), findsOneWidget);
    expect(find.text('Borrow Renewals Left'), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);
    expect(find.text('Renew Borrowing'), findsOneWidget);

    await tester.tap(find.text('Renew Borrowing'));
    await tester.pumpAndSettle();
    expect(find.text('Book renewal submitted successfully.'), findsOneWidget);

    await _drainToast(tester);
  });

  testWidgets('the options sheet reports each action through a toast', (
    WidgetTester tester,
  ) async {
    await _openLibrary(tester);
    await _openIssuedTab(tester);

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Student ID: STU-2083-0156'), findsOneWidget);
    expect(find.text('Renew Borrow Period (+14 days)'), findsOneWidget);
    expect(find.text('View Full Book History'), findsOneWidget);
    expect(find.text('Report Damaged / Lost Book'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Renew Borrow Period (+14 days)'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Renewal requested for Mathematics Grade 10! Extended by 14 days.',
      ),
      findsOneWidget,
    );

    await _drainToast(tester);
  });

  testWidgets('search and category chips filter the catalogue', (
    WidgetTester tester,
  ) async {
    await _openLibrary(tester);

    // 1 — Free-text search narrows to the matching title.
    await tester.enterText(find.byType(TextField), 'Shakespeare');
    await tester.pumpAndSettle();
    expect(find.text('Shakespeare: Selected Plays'), findsOneWidget);
    expect(find.text('Physics Fundamentals Vol 1'), findsNothing);

    // 2 — Clearing restores the full list.
    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();
    expect(find.text('Physics Fundamentals Vol 1'), findsOneWidget);

    // 3 — A category chip narrows by bucket.
    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();
    expect(find.text('Advanced Coordinate Geometry'), findsOneWidget);
    expect(find.text('Physics Fundamentals Vol 1'), findsNothing);
    expect(find.text('Shakespeare: Selected Plays'), findsNothing);

    expectNoOverflow(tester, 'library filtered');
  });

  testWidgets('reserve and details actions report through a toast', (
    WidgetTester tester,
  ) async {
    await _openLibrary(tester);

    // 1 — Request Book reserves the title.
    await tester.tap(find.text('Request Book').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Reservation request sent for "Physics Fundamentals Vol 1".'),
      findsOneWidget,
    );
    await _drainToast(tester);

    // 2 — Details opens the preview sheet.
    await tester.tap(find.text('Details').first);
    await tester.pumpAndSettle();
    expect(find.text('In Library'), findsOneWidget);
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('RACK A-12'), findsWidgets);
    expect(find.text('Lending Term'), findsOneWidget);
    expect(find.text('7-day lending term'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Lending Term'), findsNothing);
  });

  testWidgets('back returns to the dashboard', (WidgetTester tester) async {
    await _openLibrary(tester);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LibraryScreen), findsNothing);
  });
}
