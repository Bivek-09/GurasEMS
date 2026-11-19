// Widget tests for the GurasEMS Fees screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurasems/main.dart';
import 'package:gurasems/screens/fees_screen.dart';
import 'package:gurasems/screens/home_screen.dart';
import 'package:gurasems/screens/login_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('dashboard Quick Actions Fees tile opens the fees screen', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap the Fees tile in the Quick Actions grid
    await tester.ensureVisible(find.text('Fees'));
    await tester.tap(find.text('Fees'));
    await tester.pumpAndSettle();

    expect(find.byType(FeesScreen), findsOneWidget);
    expect(find.text('Fees'), findsWidgets); // app bar title

    // Summary derives from the invoice list: 45,000 billed, 35,000 settled.
    expect(find.text('Total Fee'), findsOneWidget);
    expect(find.text('Rs. 45,000'), findsOneWidget);
    expect(find.text('Rs. 35,000'), findsOneWidget);
    expect(find.text('Rs. 10,000'), findsWidgets); // remaining + two invoices
    expect(find.text('78% Paid'), findsOneWidget);
    expect(find.text('22% Remaining'), findsOneWidget);

    // Invoice rows, with the Transport Fee outstanding.
    expect(find.text('Annual Fee'), findsOneWidget);
    expect(find.text('Exam Fee'), findsOneWidget);
    expect(find.text('Transport Fee'), findsOneWidget);
    expect(find.text('Library Fee'), findsOneWidget);
    expect(find.text('Pay Now'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Due: 2083-09-10'), findsOneWidget);
    expectNoOverflow(tester, 'fees');
  });

  testWidgets('summary breakdown expands and its simulation controls settle '
      'and reset the fees', (WidgetTester tester) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Fees'));
    await tester.tap(find.text('Fees'));
    await tester.pumpAndSettle();
    expect(find.byType(FeesScreen), findsOneWidget);

    // 1 ─ Expand the breakdown behind "Details"
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();

    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('Tuition & Facilities'), findsOneWidget);
    expect(find.text('Rs. 30,000'), findsOneWidget);
    expect(find.text('Transportation & Bus'), findsOneWidget);
    expect(find.text('Lab, Exam & Library'), findsOneWidget);
    expect(find.text('Simulation:'), findsOneWidget);

    // 2 ─ "Pay All" settles every invoice
    await tester.ensureVisible(find.text('Pay All'));
    await tester.tap(find.text('Pay All'));
    await tester.pumpAndSettle();

    expect(find.text('All fees settled successfully!'), findsOneWidget);
    expect(find.text('100% Paid (Fully Settled)'), findsOneWidget);
    expect(find.text('Rs. 0'), findsOneWidget);
    expect(find.text('22% Remaining'), findsNothing);
    expect(find.text('Pending'), findsNothing);
    expect(find.text('Pay Now'), findsNothing);

    // Let the toast clear so it can't sit over the simulation links.
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();

    // 3 ─ "Reset Status" puts the Transport Fee back to unpaid
    await tester.tap(find.text('Reset Status'));
    await tester.pumpAndSettle();

    expect(find.text('Fee simulation reset to unpaid state'), findsOneWidget);
    expect(find.text('78% Paid'), findsOneWidget);
    expect(find.text('22% Remaining'), findsOneWidget);
    expect(find.text('Pay Now'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    // Collapse again
    await tester.ensureVisible(find.text('Hide'));
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Simulation:'), findsNothing);
  });

  testWidgets('transactions tab lists payments and reports the tapped row', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Fees'));
    await tester.tap(find.text('Fees'));
    await tester.pumpAndSettle();

    // 1 ─ Switch to the Transactions tab
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Txn #TXN-9021 · Annual Fee'), findsOneWidget);
    expect(find.text('Online Khalti'), findsOneWidget);
    expect(find.text('Txn #TXN-8742 · Exam Fee'), findsOneWidget);
    expect(find.text('Txn #TXN-7102 · Library Fee'), findsOneWidget);
    expect(find.text('+ Rs. 20,000'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);

    // 2 ─ Tapping a row reports it through the toast
    await tester.tap(find.text('Txn #TXN-9021 · Annual Fee'));
    await tester.pumpAndSettle();
    expect(find.text('Viewing Transaction #TXN-9021'), findsOneWidget);

    // 3 ─ Back to Invoices
    await tester.tap(find.text('Invoices'));
    await tester.pumpAndSettle();
    expect(find.text('Annual Fee'), findsOneWidget);
  });

  testWidgets('paying the Transport Fee through the gateway sheet settles it', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Fees'));
    await tester.tap(find.text('Fees'));
    await tester.pumpAndSettle();

    // 1 ─ Quick-pay the outstanding Transport Fee
    await tester.ensureVisible(find.text('Pay Now'));
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();

    expect(find.text('Select Payment Method'), findsOneWidget);
    expect(find.textContaining('Payable:'), findsOneWidget);
    expect(find.text('eSewa Mobile Wallet'), findsOneWidget);
    expect(find.text('Khalti Digital Wallet'), findsOneWidget);
    expect(find.text('connectIPS / Bank Account'), findsOneWidget);
    expect(find.text('Debit / Credit Card'), findsOneWidget);

    // 2 ─ Choose eSewa — processing toast, then the settlement lands
    await tester.tap(find.text('eSewa Mobile Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Processing payment via eSewa...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Payment Successful! Receipt Generated.'), findsOneWidget);
    expect(find.text('100% Paid (Fully Settled)'), findsOneWidget);
    expect(find.text('Rs. 0'), findsOneWidget);
    expect(find.text('Pending'), findsNothing);
    expect(find.text('Pay Now'), findsNothing);
    expect(find.text('Paid · 2083-09-08'), findsOneWidget);

    // 3 ─ The settlement is recorded as a highlighted transaction row
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('Txn #TXN-9982 · Transport Fee'), findsOneWidget);
    expect(find.text('eSewa Digital Payment'), findsOneWidget);
    expect(find.text('Just now · 2083-09-08'), findsOneWidget);
  });

  testWidgets('invoice sheet shows the breakdown and downloads the receipt', (
    WidgetTester tester,
  ) async {
    useViewport(tester, const TestDevice('normal phone', Size(390, 844)));
    await tester.pumpWidget(const GurasEmsApp());

    await pumpUntil(tester, find.byType(LoginScreen), budget: splashBudget);
    await tester.pumpAndSettle();
    await signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Fees'));
    await tester.tap(find.text('Fees'));
    await tester.pumpAndSettle();

    // 1 ─ Open the Annual Fee invoice
    await tester.ensureVisible(find.text('Annual Fee'));
    await tester.tap(find.text('Annual Fee'));
    await tester.pumpAndSettle();

    expect(find.text('INV-2083-01'), findsOneWidget);
    expect(find.text('RCP-2083-9912'), findsOneWidget);
    expect(find.text('Tuition & Curriculum Fee'), findsOneWidget);
    expect(find.text('Rs. 12,000'), findsOneWidget);
    expect(find.text('Total Amount'), findsOneWidget);
    expect(find.text('Paid'), findsWidgets);
    // A settled invoice offers no pay button.
    expect(find.text('Pay with Digital Wallet'), findsNothing);

    // 2 ─ Download the receipt — two-step toast
    await tester.tap(find.text('Download Official PDF Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Downloading Official PDF Receipt...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Receipt saved to device (PDF)'), findsOneWidget);

    // 3 ─ The outstanding invoice does offer the wallet button
    await tester.tap(find.text('Transport Fee'));
    await tester.pumpAndSettle();
    expect(find.text('INV-2083-03'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text('Pay with Digital Wallet'), findsOneWidget);
    await tester.ensureVisible(find.text('Close'));
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // 4 ─ Back to the dashboard
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(FeesScreen), findsNothing);
  });
}
