// Tests for the shared design system: button states, cards, feedback and the
// empty/error states every screen is expected to reuse.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/core/app_palette.dart';
import 'package:gurasems/core/app_theme.dart';
import 'package:gurasems/widgets/app_buttons.dart';
import 'package:gurasems/widgets/app_card.dart';
import 'package:gurasems/widgets/app_feedback.dart';
import 'package:gurasems/widgets/app_states.dart';

Widget _host(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('PrimaryButton turns darker maroon when pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(PrimaryButton(label: 'Go', onPressed: () {})),
    );

    final ButtonStyle style = tester
        .widget<FilledButton>(find.byType(FilledButton))
        .style!;

    expect(
      style.backgroundColor!.resolve(<WidgetState>{WidgetState.pressed}),
      AppPalette.primary,
    );
    expect(
      style.overlayColor!.resolve(<WidgetState>{WidgetState.pressed}),
      AppPalette.primaryDark,
    );
  });

  testWidgets('PrimaryButton shows an obvious disabled state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const PrimaryButton(label: 'Go')));

    final FilledButton button = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    expect(button.onPressed, isNull);
    expect(
      button.style!.backgroundColor!.resolve(<WidgetState>{
        WidgetState.disabled,
      }),
      const Color(0xFFE5E7EB),
    );
  });

  testWidgets('PrimaryButton keeps its maroon surface while loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(PrimaryButton(label: 'Go', onPressed: () {}, loading: true)),
    );

    final FilledButton button = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    // Loading must block re-submission without looking disabled.
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      button.style!.backgroundColor!.resolve(<WidgetState>{
        WidgetState.disabled,
      }),
      AppPalette.primary,
    );
  });

  testWidgets('SecondaryButton washes pale maroon when pressed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(SecondaryButton(label: 'Cancel', onPressed: () {})),
    );

    final ButtonStyle style = tester
        .widget<OutlinedButton>(find.byType(OutlinedButton))
        .style!;

    expect(style.foregroundColor!.resolve(<WidgetState>{}), AppPalette.primary);
    expect(
      style.overlayColor!.resolve(<WidgetState>{WidgetState.pressed}),
      AppPalette.primaryLight,
    );
  });

  testWidgets('AppCard invokes its tap callback', (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(AppCard(onTap: () => taps++, child: const Text('Row'))),
    );

    await tester.tap(find.text('Row'));
    expect(taps, 1);
  });

  testWidgets('EmptyState and ErrorState render their copy and retry', (
    WidgetTester tester,
  ) async {
    var retried = 0;
    await tester.pumpWidget(
      _host(ErrorState(message: 'No connection', onRetry: () => retried++)),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);

    await tester.pumpWidget(
      _host(
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here yet',
          message: 'New items will appear here.',
        ),
      ),
    );
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('New items will appear here.'), findsOneWidget);
  });

  testWidgets('ConfirmDialog resolves true on confirm and false on cancel', (
    WidgetTester tester,
  ) async {
    Future<bool>? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () {
                  result = ConfirmDialog.show(
                    ctx,
                    title: 'Discard?',
                    message: 'Unsaved changes will be lost.',
                    confirmLabel: 'Discard',
                    destructive: true,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Discard?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('showAppSnackBar surfaces success and error messages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showAppSnackBar(ctx, 'Saved!'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('Saved!'), findsOneWidget);
  });
}
