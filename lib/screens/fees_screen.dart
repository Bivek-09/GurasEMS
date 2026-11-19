import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/fee_data.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/app_toast.dart';
import '../widgets/fee_status_badge.dart';
import '../widgets/invoice_detail_sheet.dart';
import '../widgets/payment_method_sheet.dart';

/// Fees — invoices and transactions under the Academics section.
///
/// Opened from the dashboard's quick actions. The summary card recalculates
/// itself from the invoice list (the reference's dynamic fee calculator), so
/// settling an invoice — through the gateway sheet or the summary's
/// simulation controls — moves the headline, the paid/remaining split and the
/// progress bar together with the rows below. The bottom nav keeps the
/// Academics tab active, matching the reference design.
class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.fees;

  static const Color _surface = AppPalette.dashboardBg;

  // ── App bar ───────────────────────────────────────────────────────────
  /// Full height of the maroon app bar, so scroll content and the toast
  /// layer can clear it exactly.
  ///
  /// The bar itself is now rendered by [AppScreenBar], whose defaults
  /// reproduce this screen's geometry; the public name is kept because the
  /// toast layer positions against it.
  static double barHeightOf(BuildContext context) =>
      AppScreenBar.heightOf(context);

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  // Sample record — replaced by the fee ledger once the API is wired in.
  List<FeeInvoice> _invoices = kFeeInvoices;
  List<FeeTransaction> _transactions = kFeeTransactions;

  /// 0 — Invoices, 1 — Transactions (the reference's segmented control).
  int _tabIndex = 0;

  bool _breakdownOpen = false;

  String? _toastMessage;
  Timer? _toastTimer;
  Timer? _toastChainTimer;

  // ── Derived summary ───────────────────────────────────────────────────
  int get _total =>
      _invoices.fold<int>(0, (int sum, FeeInvoice i) => sum + i.amount);

  int get _paid => _invoices
      .where((FeeInvoice i) => i.isPaid)
      .fold<int>(0, (int sum, FeeInvoice i) => sum + i.amount);

  int get _remaining => _total - _paid;

  int get _paidPercent => _total == 0 ? 0 : ((_paid / _total) * 100).round();

  int get _remainingPercent => 100 - _paidPercent;

  /// Summary bucket label → amount, in the order the invoices introduce it,
  /// so the expandable breakdown always sums from the visible invoice list.
  List<MapEntry<String, int>> get _groups {
    final Map<String, int> sums = <String, int>{};
    for (final FeeInvoice invoice in _invoices) {
      sums.update(
        invoice.group,
        (int value) => value + invoice.amount,
        ifAbsent: () => invoice.amount,
      );
    }
    return sums.entries.toList();
  }

  // ── Toast ─────────────────────────────────────────────────────────────
  void _showToast(
    String message, {
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    if (!mounted) return;
    setState(() => _toastMessage = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(duration, () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  void _downloadReceipt() {
    _showToast('Downloading Official PDF Receipt...');
    _toastChainTimer?.cancel();
    _toastChainTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) _showToast('Receipt saved to device (PDF)');
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _toastChainTimer?.cancel();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────
  Future<void> _openInvoice(FeeInvoice invoice) async {
    final InvoiceSheetAction? action = await InvoiceDetailSheet.show(
      context,
      invoice: invoice,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case InvoiceSheetAction.pay:
        await _startPayment(invoice);
      case InvoiceSheetAction.download:
        _downloadReceipt();
    }
  }

  Future<void> _startPayment(FeeInvoice invoice) async {
    final PaymentGateway? gateway = await PaymentMethodSheet.show(
      context,
      invoice: invoice,
    );
    if (!mounted || gateway == null) return;

    _showToast('Processing payment via ${gateway.name}...');
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _invoices = <FeeInvoice>[
        for (final FeeInvoice i in _invoices)
          i.id == invoice.id
              ? i.settled(
                  on: kSettlementDate,
                  mode: gateway.name,
                  receipt: kSettlementReceipt,
                )
              : i,
      ];
      _transactions = <FeeTransaction>[
        FeeTransaction(
          id: kSettlementTransactionId,
          invoiceTitle: invoice.title,
          method: '${gateway.name} Digital Payment',
          timestamp: 'Just now · $kSettlementDate',
          amount: invoice.amount,
          fresh: true,
        ),
        ..._transactions,
      ];
    });
    _showToast('Payment Successful! Receipt Generated.');
  }

  void _openTransaction(FeeTransaction transaction) =>
      _showToast('Viewing Transaction #${transaction.id}');

  /// Summary card's "Reset Status" control — puts the Transport Fee back to
  /// its unpaid state and drops the settlement row it created.
  void _resetSimulation() {
    setState(() {
      _invoices = <FeeInvoice>[
        for (final FeeInvoice i in _invoices)
          i.id == kTransportInvoiceId ? i.asPending() : i,
      ];
      _transactions = <FeeTransaction>[
        for (final FeeTransaction t in _transactions)
          if (t.id != kSettlementTransactionId) t,
      ];
    });
    _showToast('Fee simulation reset to unpaid state');
  }

  /// Summary card's "Pay All" control — settles every outstanding invoice.
  void _payAllSimulation() {
    setState(() {
      _invoices = <FeeInvoice>[
        for (final FeeInvoice i in _invoices)
          i.isPaid
              ? i
              : i.settled(
                  on: kSettlementDate,
                  mode: kCounterPaymentMode,
                  receipt: kSettlementReceipt,
                ),
      ];
    });
    _showToast('All fees settled successfully!');
  }

  // ── Navigation ────────────────────────────────────────────────────────
  int get _academicsIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Academics',
  );

  void _onTabSelected(int index) =>
      AppRoutes.switchTab(context, index, _academicsIndex);

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = FeesScreen.barHeightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: FeesScreen._surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — scrolling content.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: barHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg * s,
                  AppSpacing.lg * s,
                  AppSpacing.lg * s,
                  navHeight + AppSpacing.block * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _SummaryCard(
                          total: _total,
                          paid: _paid,
                          remaining: _remaining,
                          paidPercent: _paidPercent,
                          remainingPercent: _remainingPercent,
                          groups: _groups,
                          expanded: _breakdownOpen,
                          scale: s,
                          onToggle: () =>
                              setState(() => _breakdownOpen = !_breakdownOpen),
                          onReset: _resetSimulation,
                          onPayAll: _payAllSimulation,
                        ),
                        SizedBox(height: AppSpacing.lg * s),
                        _SegmentedTabs(
                          index: _tabIndex,
                          scale: s,
                          onChanged: (int i) => setState(() => _tabIndex = i),
                        ),
                        SizedBox(height: 14 * s),
                        if (_tabIndex == 0)
                          _invoiceList(s)
                        else
                          _transactionList(s),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer 2 — pinned maroon app bar.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppScreenBar(
              title: 'Fees',
              onBack: () => Navigator.of(context).maybePop(),
              // This screen's reference bar uses the round chevron at 22 and a
              // compact 16pt w700 title — the shared bar reproduces both.
              leadingIcon: Icons.chevron_left_rounded,
              iconSize: 22,
              titleSize: 16,
              titleWeight: FontWeight.w700,
              titleLetterSpacing: 0.3,
            ),
          ),

          // Layer 3 — toast, just under the app bar.
          if (_toastMessage != null)
            Positioned(
              left: 0,
              right: 0,
              top: barHeight + AppSpacing.sm * s,
              child: Center(child: AppToast(message: _toastMessage!)),
            ),

          // Layer 4 — persistent navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: _academicsIndex,
              enabledIndices: <int>{0, 1, 2, 3},
              onSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceList(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < _invoices.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: AppSpacing.md * s),
          _InvoiceCard(
            invoice: _invoices[i],
            scale: s,
            onTap: () => _openInvoice(_invoices[i]),
            onPay: () => _startPayment(_invoices[i]),
          ),
        ],
      ],
    );
  }

  Widget _transactionList(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < _transactions.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: AppSpacing.md * s),
          _TransactionCard(
            transaction: _transactions[i],
            scale: s,
            onTap: () => _openTransaction(_transactions[i]),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Summary card
// ─────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.paid,
    required this.remaining,
    required this.paidPercent,
    required this.remainingPercent,
    required this.groups,
    required this.expanded,
    required this.scale,
    required this.onToggle,
    required this.onReset,
    required this.onPayAll,
  });

  final int total;
  final int paid;
  final int remaining;
  final int paidPercent;
  final int remainingPercent;

  /// Summary bucket label → amount.
  final List<MapEntry<String, int>> groups;

  final bool expanded;
  final double scale;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onPayAll;

  static const Color _hairline = AppGray.shade100;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: _hairline),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _headline(s),
              AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: expanded
                    ? _breakdown(s)
                    : const SizedBox(width: double.infinity),
              ),
              _split(s),
              SizedBox(height: AppSpacing.md * s),
              _progress(s),
            ],
          ),
        ),
      ),
    );
  }

  /// Headline total with the Details / Hide affordance pinned right.
  Widget _headline(double s) {
    return Container(
      padding: EdgeInsets.only(bottom: AppSpacing.md * s),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _hairline)),
      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                rs(total),
                style: TextStyle(
                  fontSize: 24 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5 * s,
                  color: AppSlate.shade800,
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                'Total Fee',
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w500,
                  color: AppGray.shade400,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: AppSpacing.xs * s,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  expanded ? 'Hide' : 'Details',
                  style: TextStyle(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w500,
                    color: AppGray.shade400,
                  ),
                ),
                SizedBox(width: 2 * s),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14 * s,
                    color: AppGray.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Expandable group breakdown plus the reference's simulation controls.
  Widget _breakdown(double s) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.md * s,
        bottom: AppSpacing.sm * s,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _hairline)),
      ),
      child: Column(
        children: <Widget>[
          for (final MapEntry<String, int> group in groups)
            Padding(
              padding: EdgeInsets.only(bottom: 6 * s),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      group.key,
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.supportingText,
                      ),
                    ),
                  ),
                  Text(
                    rs(group.value),
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w600,
                      color: AppSlate.shade700,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(top: AppSpacing.sm * s),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _hairline)),
            ),
            // Wraps instead of overflowing on very narrow phones: the label
            // takes the first line and the two links follow.
            child: Wrap(
              spacing: 6 * s,
              runSpacing: AppSpacing.xs * s,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  'Simulation:',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w500,
                    color: AppGray.shade400,
                  ),
                ),
                _SimulationLink(
                  label: 'Reset Status',
                  color: AppPalette.maroon800,
                  scale: s,
                  onTap: onReset,
                ),
                Text(
                  '•',
                  style: TextStyle(fontSize: 11 * s, color: AppGray.shade300),
                ),
                _SimulationLink(
                  label: 'Pay All',
                  color: AppPalette.statusGreen,
                  scale: s,
                  onTap: onPayAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Paid vs remaining columns.
  Widget _split(double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm * s,
        AppSpacing.md * s,
        AppSpacing.sm * s,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  rs(paid),
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2 * s,
                    color: AppSlate.shade800,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  'Paid',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    color: AppGray.shade400,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  rs(remaining),
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2 * s,
                    color: remaining == 0
                        ? AppSlate.shade800
                        : AppPalette.accentRed,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    color: AppGray.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Two-segment progress bar with the percentage labels beneath it.
  Widget _progress(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double paidWidth = constraints.maxWidth * paidPercent / 100;
            return Container(
              height: 8 * s,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _hairline,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Row(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: paidWidth,
                    color: AppPalette.progressGreen,
                  ),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      color: AppPalette.progressRose,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 6 * s),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                paidPercent == 100
                    ? '100% Paid (Fully Settled)'
                    : '$paidPercent% Paid',
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1 * s,
                  color: AppPalette.statusGreen,
                ),
              ),
            ),
            if (remainingPercent > 0)
              Expanded(
                child: Text(
                  '$remainingPercent% Remaining',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1 * s,
                    color: AppPalette.rose,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SimulationLink extends StatelessWidget {
  const _SimulationLink({
    required this.label,
    required this.color,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final Color color;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4 * s),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 2 * s),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11 * s,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: color,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Segmented tabs
// ─────────────────────────────────────────────────────────────────────────

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.index,
    required this.scale,
    required this.onChanged,
  });

  final int index;
  final double scale;
  final ValueChanged<int> onChanged;

  static const List<String> _labels = <String>['Invoices', 'Transactions'];

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Row(
      children: <Widget>[
        for (int i = 0; i < _labels.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: AppSpacing.md * s),
          Expanded(
            child: _Pill(
              label: _labels[i],
              active: i == index,
              scale: s,
              onTap: () => onChanged(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool active;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: active ? AppPalette.maroon800 : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: active ? null : Border.all(color: AppGray.shade200),
        boxShadow: active
            ? <BoxShadow>[
                BoxShadow(
                  color: AppPalette.maroon800.withValues(alpha: 0.18),
                  blurRadius: 6 * s,
                  offset: Offset(0, 1 * s),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 9 * s),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppPalette.supportingText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Invoice row
// ─────────────────────────────────────────────────────────────────────────

/// Shared resting lift for the invoice and transaction rows.
///
/// The two rows are visually identical cards, so their shadow lives once and
/// both read it; the summary card keeps its stronger shadow separately.
List<BoxShadow> _rowShadow(double s) => <BoxShadow>[
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.03),
    blurRadius: 6 * s,
    offset: Offset(0, 1 * s),
  ),
];

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.scale,
    required this.onTap,
    required this.onPay,
  });

  final FeeInvoice invoice;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final bool pending = !invoice.isPaid;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(
          color: pending ? AppPalette.pendingBorder : AppPalette.cardBorder,
        ),
        boxShadow: _rowShadow(s),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              Container(
                width: 40 * s,
                height: 40 * s,
                decoration: BoxDecoration(
                  color: pending ? AppPalette.pendingBg : AppGray.shade50,
                  borderRadius: BorderRadius.circular(AppRadii.inner * s),
                  border: Border.all(
                    color: pending
                        ? AppPalette.pendingBorder
                        : AppGray.shade100,
                  ),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 20 * s,
                  color: pending
                      ? AppPalette.pendingText
                      : AppPalette.supportingText,
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      invoice.title,
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: AppSlate.shade800,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      rs(invoice.amount),
                      style: TextStyle(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                        color: pending
                            ? AppPalette.accentRed
                            : AppSlate.shade900,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      invoice.statusLine,
                      style: TextStyle(
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w500,
                        color: pending ? AppPalette.rose : AppGray.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              if (pending) ...<Widget>[
                SizedBox(width: 5 * s),
                // Sits inside the card's ink well but takes the tap itself,
                // like the reference's stopPropagation on the quick-pay button.
                Material(
                  color: AppPalette.maroon800,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onPay,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * s,
                        vertical: 5 * s,
                      ),
                      child: Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(width: 5 * s),
              FeeStatusBadge(paid: invoice.isPaid),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Transaction row
// ─────────────────────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.scale,
    required this.onTap,
  });

  final FeeTransaction transaction;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final bool fresh = transaction.fresh;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: BoxDecoration(
        color: fresh
            ? AppPalette.statusGreenBg.withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(
          color: fresh ? const Color(0xFFA7F3D0) : AppPalette.cardBorder,
        ),
        boxShadow: _rowShadow(s),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Txn #${transaction.id} · ${transaction.invoiceTitle}',
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w700,
                        color: AppSlate.shade800,
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      transaction.method,
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: AppGray.shade400,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      transaction.timestamp,
                      style: TextStyle(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: AppGray.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md * s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '+ ${rs(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.statusGreen,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.statusGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
