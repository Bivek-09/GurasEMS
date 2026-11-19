// Widget tests for the GurasEMS Notices screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/notices_screen.dart';
import 'package:gurasems/widgets/app_bottom_nav.dart';
import 'package:gurasems/widgets/app_top_bar.dart';

import 'test_helpers.dart';

/// Signs in from the splash screen and lands on the dashboard.
Future<void> _signIn(WidgetTester tester) async {
  await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
  await tester.pumpAndSettle();
  await signIn(tester);
  await tester.pumpAndSettle();
}

/// Opens the notice board through the bottom-nav Notices tab.
Future<void> _openNotices(WidgetTester tester) async {
  useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
  await tester.pumpWidget(const GurasEmsApp());
  await _signIn(tester);

  await tester.tap(
    find.descendant(
      of: find.byType(AppBottomNav),
      matching: find.text('Notices'),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(NoticesScreen), findsOneWidget);
}

/// Reveals the collapsible search drawer.
Future<void> _openSearch(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.search_rounded));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bottom-nav Notices tab opens the notice board', (
    WidgetTester tester,
  ) async {
    await _openNotices(tester);

    // The four category filters.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Academic'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    // Every notice in the board.
    expect(find.text('Dashain Holiday Notice'), findsOneWidget);
    expect(find.text('Parent-Teacher Meeting'), findsOneWidget);
    expect(find.text('Exam Routine Published'), findsOneWidget);
    expect(find.text('Sports Week'), findsOneWidget);
    expect(find.text('Science Exhibition Registration'), findsOneWidget);
    expect(find.text('Library Book Returns'), findsOneWidget);

    // Two notices are pinned and the search drawer starts collapsed.
    expect(find.byIcon(Icons.push_pin), findsNWidgets(2));
    expect(find.byType(TextField), findsNothing);

    expectNoOverflow(tester, 'notices');
  });

  testWidgets('the dashboard bell also opens the notice board', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());
    await _signIn(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(AppTopBar),
        matching: find.byIcon(Icons.notifications_none_rounded),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NoticesScreen), findsOneWidget);
  });

  testWidgets('search drawer filters the board and clears', (
    WidgetTester tester,
  ) async {
    await _openNotices(tester);
    await _openSearch(tester);

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'sports');
    await tester.pumpAndSettle();
    expect(find.text('Sports Week'), findsOneWidget);
    expect(find.text('Dashain Holiday Notice'), findsNothing);

    // The clear affordance restores the full board.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Dashain Holiday Notice'), findsOneWidget);

    // Closing the drawer again hides the field.
    await tester.tap(find.byIcon(Icons.search_off_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('category pills filter the board', (WidgetTester tester) async {
    await _openNotices(tester);

    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();
    expect(find.text('Sports Week'), findsOneWidget);
    expect(find.text('Science Exhibition Registration'), findsOneWidget);
    expect(find.text('Dashain Holiday Notice'), findsNothing);
    expect(find.text('Library Book Returns'), findsNothing);

    // The pill row scrolls on a narrow phone, so bring "Other" into view first.
    await tester.ensureVisible(find.text('Other'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    expect(find.text('Library Book Returns'), findsOneWidget);
    expect(find.text('Sports Week'), findsNothing);

    expectNoOverflow(tester, 'notices filtered');
  });

  testWidgets('tapping a notice opens the detail sheet and downloads', (
    WidgetTester tester,
  ) async {
    await _openNotices(tester);

    await tester.tap(find.text('Dashain Holiday Notice'));
    await tester.pumpAndSettle();

    expect(find.text("Principal's Office"), findsOneWidget);
    expect(find.text('Dashain_Vacation_Circular_2083.pdf'), findsOneWidget);
    expect(find.textContaining('Download to view'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Acknowledge & Close'), findsOneWidget);

    // Downloading keeps the sheet open and flashes a toast above it.
    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(find.text('Downloading document...'), findsOneWidget);

    // Let the toast timer elapse before dismissing.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acknowledge & Close'));
    await tester.pumpAndSettle();
    expect(find.text('Acknowledge & Close'), findsNothing);
    expect(find.text('Download'), findsNothing);
  });

  testWidgets('an empty result shows the empty state', (
    WidgetTester tester,
  ) async {
    await _openNotices(tester);
    await _openSearch(tester);

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.text('No notices found'), findsOneWidget);
    expect(
      find.text('Try changing category filter or search keywords'),
      findsOneWidget,
    );
    expect(find.text('Dashain Holiday Notice'), findsNothing);
    expectNoOverflow(tester, 'notices empty');
  });

  testWidgets('back returns to the dashboard', (WidgetTester tester) async {
    await _openNotices(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NoticesScreen), findsNothing);
  });
}
