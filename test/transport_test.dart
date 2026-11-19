// Widget tests for the GurasEMS Transport screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/transport_screen.dart';

import 'test_helpers.dart';

/// Signs in from the splash screen and lands on the dashboard.
Future<void> _signIn(WidgetTester tester) async {
  await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Sign in'));
  await tester.pumpAndSettle();
  await signIn(tester);
  await tester.pumpAndSettle();
}

/// Opens the transport tracker through the dashboard's Transport quick action.
Future<void> _openTransport(WidgetTester tester) async {
  useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
  await tester.pumpWidget(const GurasEmsApp());
  await _signIn(tester);

  await tester.ensureVisible(find.text('Transport'));
  await tester.tap(find.text('Transport'));
  await tester.pumpAndSettle();
  expect(find.byType(TransportScreen), findsOneWidget);
}

/// Lets a toast's timer elapse so it cannot shadow a later tap.
Future<void> _drainToast(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 2500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dashboard Transport tile opens the live tracker', (
    WidgetTester tester,
  ) async {
    await _openTransport(tester);

    // Title and live-tracking header.
    expect(find.text('Transport'), findsOneWidget);

    // Bus card: identity, status and live speed.
    expect(find.text('Bus No. 3'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Current Speed'), findsOneWidget);
    expect(find.text('28 km/h'), findsOneWidget);

    // Driver, route, departure and pickup details.
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Ram Sharma'), findsOneWidget);
    expect(find.text('9841234567'), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);
    expect(find.text('Biratnagar'), findsOneWidget);
    expect(find.text('School'), findsNWidgets(2));
    expect(find.text('7:20 AM'), findsOneWidget);
    expect(find.text('ON'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('Main Chowk'), findsNWidgets(2));
    expect(find.text('Your Stop'), findsOneWidget);

    // Route progress with the three stops and the info bubble.
    expect(find.text('Live Route Progress'), findsOneWidget);
    expect(find.text('ETA: 2 mins'), findsOneWidget);
    expect(find.text('Depot'), findsOneWidget);
    expect(find.text('7:00 AM'), findsOneWidget);
    expect(find.textContaining('Scheduled 7:20 AM'), findsOneWidget);
    expect(find.text('0.2 km away'), findsOneWidget);

    // Quick actions and the attendant card.
    expect(find.text('Emergency'), findsOneWidget);
    expect(find.text('Report Issue'), findsOneWidget);
    expect(find.text('Live Radar'), findsOneWidget);
    expect(find.text('Expand GPS View'), findsOneWidget);
    expect(find.text('Sanjay Chaudhary'), findsOneWidget);
    expect(find.text('Bus Attendant • Helper'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);

    expectNoOverflow(tester, 'transport');
  });

  testWidgets('the ETA badge advances the journey and stops jump to a leg', (
    WidgetTester tester,
  ) async {
    await _openTransport(tester);

    // Default milestone is the pickup stop.
    expect(find.text('ETA: 2 mins'), findsOneWidget);

    // Advancing runs the bus on to the school.
    await tester.tap(find.text('ETA: 2 mins'));
    await tester.pumpAndSettle();
    expect(find.text('ETA: 1 min'), findsOneWidget);
    expect(
      find.text('Simulation updated: Bus reached milestone 3'),
      findsOneWidget,
    );
    await _drainToast(tester);

    // Tapping a stop selects that leg directly.
    await tester.tap(find.text('Depot'));
    await tester.pumpAndSettle();
    expect(find.text('ETA: 12 mins'), findsOneWidget);
    expect(find.text('Depot: Departed 7:00 AM on schedule'), findsOneWidget);
    await _drainToast(tester);

    expectNoOverflow(tester, 'transport milestone');
  });

  testWidgets('calling the driver confirms through a toast', (
    WidgetTester tester,
  ) async {
    await _openTransport(tester);

    await tester.tap(find.byIcon(Icons.call_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Call Driver'), findsOneWidget);
    expect(find.text('Call Now'), findsOneWidget);
    expect(find.text('+977 9841234567'), findsOneWidget);

    await tester.tap(find.text('Call Now'));
    await tester.pumpAndSettle();
    expect(
      find.text('Dialing Ram Sharma (+977 9841234567)...'),
      findsOneWidget,
    );
    await _drainToast(tester);
  });

  testWidgets('contacting the attendant confirms through a toast', (
    WidgetTester tester,
  ) async {
    await _openTransport(tester);

    await tester.tap(find.text('Contact'));
    await tester.pumpAndSettle();

    expect(find.text('Contact Bus Attendant'), findsOneWidget);
    expect(find.text('Call Attendant'), findsOneWidget);
    expect(find.text('+977 9801239876'), findsOneWidget);

    await tester.tap(find.text('Call Attendant'));
    await tester.pumpAndSettle();
    expect(
      find.text('Calling Attendant Sanjay Chaudhary (+977 9801239876)...'),
      findsOneWidget,
    );
    await _drainToast(tester);
  });

  testWidgets('the emergency sheet dispatches the selected reason', (
    WidgetTester tester,
  ) async {
    await _openTransport(tester);

    await tester.ensureVisible(find.text('Emergency'));
    await tester.tap(find.text('Emergency'));
    await tester.pumpAndSettle();

    expect(find.text('Transport Emergency Alert'), findsOneWidget);
    expect(find.text('Submit Urgent Alert'), findsOneWidget);

    await tester.tap(find.textContaining('Medical Help'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Urgent Alert'));
    await tester.pumpAndSettle();

    expect(
      find.text('SOS Sent: "Medical / Urgent Need" dispatched!'),
      findsOneWidget,
    );
    await _drainToast(tester);
  });

  testWidgets('the radar sheet zooms and toggles its layer', (
    WidgetTester tester,
  ) async {
    await _openTransport(tester);

    await tester.ensureVisible(find.text('Live Radar'));
    await tester.tap(find.text('Live Radar'));
    await tester.pumpAndSettle();

    expect(find.text('Live GPS Radar'), findsOneWidget);
    expect(find.text('Back to Route Summary'), findsOneWidget);
    expect(find.text('Layer: Streets'), findsOneWidget);

    // Zoom in.
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(find.text('Map Zoom: 115%'), findsOneWidget);
    await _drainToast(tester);

    // Switch to the satellite layer.
    await tester.tap(find.text('Layer: Streets'));
    await tester.pumpAndSettle();
    expect(find.text('Switched to Satellite View'), findsOneWidget);
    expect(find.text('Layer: Satellite'), findsOneWidget);
    await _drainToast(tester);

    // Closing returns to the tracker.
    await tester.tap(find.text('Back to Route Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Live GPS Radar'), findsNothing);
  });

  testWidgets('the live-tracking toggle pauses and resumes the feed', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _openTransport(tester);

    await tester.tap(find.bySemanticsLabel('Live Tracking Status'));
    await tester.pumpAndSettle();
    expect(find.text('Live GPS Simulation: Paused'), findsOneWidget);
    await _drainToast(tester);

    await tester.tap(find.bySemanticsLabel('Live Tracking Status'));
    await tester.pumpAndSettle();
    expect(find.text('Live GPS Simulation: Active'), findsOneWidget);
    await _drainToast(tester);

    handle.dispose();
  });

  testWidgets('back returns to the dashboard', (WidgetTester tester) async {
    await _openTransport(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(TransportScreen), findsNothing);
  });
}
