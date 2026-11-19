// Verifies that the entrance animations resolve immediately when the platform
// reports animations are disabled (accessibility "Remove animations" or the
// developer animator-scale setting). Without this, the OS-level switch made the
// splash and login screens sit on their first animation frame.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/login_screen.dart';
import 'package:gurasems/screens/splash_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets(
    'login is fully revealed on its first frame with animations off',
    (WidgetTester tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      final Iterable<FadeTransition> reveals = tester
          .widgetList<FadeTransition>(
            find.descendant(
              of: find.byType(LoginScreen),
              matching: find.byType(FadeTransition),
            ),
          );
      expect(reveals, isNotEmpty);
      for (final FadeTransition reveal in reveals) {
        expect(reveal.opacity.value, 1.0);
      }
      expect(find.text('Welcome back'), findsOneWidget);
    },
  );

  testWidgets('splash shows the finished lockup at once with animations '
      'disabled, then hands off', (WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());
    await tester.pump();

    final Iterable<FadeTransition> reveals = tester.widgetList<FadeTransition>(
      find.descendant(
        of: find.byType(SplashScreen),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(reveals, isNotEmpty);
    for (final FadeTransition reveal in reveals) {
      expect(reveal.opacity.value, 1.0);
    }

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
