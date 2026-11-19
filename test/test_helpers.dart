// Shared helpers for the GurasEMS widget tests.
//
// Not named `*_test.dart` on purpose: `flutter test` only picks up files that
// end in `_test.dart`, so this is imported rather than executed directly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/core/splash_timeline.dart';

/// A viewport shape worth verifying.
class TestDevice {
  const TestDevice(this.name, this.size, {this.padding});

  final String name;
  final Size size;

  /// View padding in physical pixels — used to imitate notches, the Dynamic
  /// Island and home-indicator bars. Physical pixels are identical to logical
  /// pixels here because every device runs at a device pixel ratio of 1.
  final FakeViewPadding? padding;
}

/// Typical phones, both tablets, and a few awkward aspect ratios.
const List<TestDevice> testDevices = <TestDevice>[
  TestDevice('small phone', Size(320, 568)),
  TestDevice('normal phone', Size(390, 844)),
  TestDevice('large phone', Size(430, 932)),
  TestDevice(
    'Dynamic Island',
    Size(393, 852),
    padding: FakeViewPadding(top: 59, bottom: 34),
  ),
  TestDevice(
    'notched Android',
    Size(412, 915),
    padding: FakeViewPadding(top: 24, bottom: 48),
  ),
  TestDevice('narrow tall', Size(280, 653)),
  TestDevice('short landscape', Size(640, 360)),
  TestDevice('tablet portrait', Size(768, 1024)),
  TestDevice('tablet landscape', Size(1024, 768)),
];

/// Pins the test window to [size] (and optional [padding]) so responsive
/// scaling behaves the way it will on a real device rather than on the 800x600
/// desktop default.
void useViewport(WidgetTester tester, TestDevice device) {
  tester.view.physicalSize = device.size;
  tester.view.devicePixelRatio = 1;
  final FakeViewPadding? padding = device.padding;
  if (padding != null) {
    tester.view.padding = padding;
    tester.view.viewPadding = padding;
  }
  addTearDown(tester.view.reset);
}

/// Upper bound on how long the splash is allowed to take before the login
/// screen appears: choreography + the frame that reports completion + hold +
/// route transition, plus slack.
Duration get splashBudget =>
    SplashTimeline.total +
    SplashTimeline.hold +
    const Duration(milliseconds: 1500);

/// Advances the test clock in small steps until [finder] matches or [budget]
/// elapses.
///
/// Driving the clock this way instead of a single hand-computed pump keeps
/// tests independent of exactly which frame the controller reports completion
/// on and of how long the route transition takes.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  required Duration budget,
}) async {
  const Duration step = Duration(milliseconds: 100);
  var elapsed = Duration.zero;
  while (elapsed < budget && !tester.any(finder)) {
    await tester.pump(step);
    elapsed += step;
  }
}

/// Fills the login form with development credentials and submits it.
///
/// The login screen validates locally, so tests must provide valid input rather
/// than tapping the button on an empty form.
Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'STU-2083-0156');
  await tester.enterText(find.byType(TextFormField).at(1), 'student123');
  await tester.pump();
  await tester.ensureVisible(find.text('Sign in'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();
}

/// Fails if the framework recorded any exception — notably `RenderFlex`
/// overflow, which is the thing responsive layouts get wrong most often.
///
/// Consumes every pending exception so a single bad frame reports once instead
/// of leaking into a later assertion.
void expectNoOverflow(WidgetTester tester, String context) {
  final List<Object?> errors = <Object?>[];
  while (true) {
    final Object? error = tester.takeException();
    if (error == null) break;
    errors.add(error);
  }
  expect(
    errors,
    isEmpty,
    reason: 'Unexpected exception while rendering $context:\n$errors',
  );
}
