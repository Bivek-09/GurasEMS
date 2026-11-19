import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../models/fee_data.dart';
import 'fee_status_badge.dart';

/// What the student asked for from the invoice sheet.
enum InvoiceSheetAction { pay, download }

/// Bottom sheet with one invoice's breakdown, metadata and actions.
///
/// Mirrors the reference's modal: a drag handle, the invoice tag beside its
/// status badge, an itemised breakdown box, three metadata rows and the
/// pay / download / close actions. Paid invoices hide the pay button.
class InvoiceDetailSheet extends StatelessWidget {
  const InvoiceDetailSheet({super.key, required this.invoice});

  final FeeInvoice invoice;

  /// Opens the sheet and resolves with the action taken, or `null` when the
  /// student dismissed it.
  static Future<InvoiceSheetAction?> show(
    BuildContext context, {
    required FeeInvoice invoice,
  }) {
    return showModalBottomSheet<InvoiceSheetAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => InvoiceDetailSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double maxH = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 24 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Drag handle.
            Center(
              child: Container(
                width: 48 * s,
                height: 4 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 16 * s),

            // Invoice tag + title, status badge on the right.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10 * s,
                          vertical: 3 * s,
                        ),
                        decoration: BoxDecoration(
                          color: AppPalette.pendingBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          invoice.id,
                          style: TextStyle(
                            fontSize: 10 * s,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8 * s,
                            color: AppPalette.maroon800,
                          ),
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      Text(
                        invoice.title,
                        style: TextStyle(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                FeeStatusBadge(paid: invoice.isPaid),
              ],
            ),
            SizedBox(height: 16 * s),

            // Fee breakdown.
            Container(
              padding: EdgeInsets.all(16 * s),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16 * s),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < invoice.lines.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(height: 10 * s),
                    _BreakdownRow(line: invoice.lines[i], scale: s),
                  ],
                  SizedBox(height: 10 * s),
                  Container(height: 1, color: const Color(0xFFE5E7EB)),
                  SizedBox(height: 10 * s),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        rs(invoice.amount),
                        style: TextStyle(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16 * s),

            // Metadata.
            _MetaRow(label: 'Due Date:', value: invoice.dueDate, scale: s),
            _MetaRow(
              label: 'Payment Mode:',
              value: invoice.paymentMode,
              scale: s,
            ),
            _MetaRow(label: 'Receipt No:', value: invoice.receiptNo, scale: s),
            SizedBox(height: 20 * s),

            // Actions.
            if (!invoice.isPaid) ...<Widget>[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(InvoiceSheetAction.pay),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.maroon800,
                    padding: EdgeInsets.symmetric(vertical: 14 * s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * s),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          'Pay with Digital Wallet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Icon(Icons.arrow_forward_rounded, size: 16 * s),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pop(InvoiceSheetAction.download),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13 * s),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.download_rounded,
                      size: 16 * s,
                      color: AppPalette.maroon800,
                    ),
                    SizedBox(width: 8 * s),
                    Flexible(
                      child: Text(
                        'Download Official PDF Receipt',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5 * s,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8 * s),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8 * s),
                child: Text(
                  'Close',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.line, required this.scale});

  final FeeBreakdownLine line;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            line.label,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        Text(
          line.display,
          style: TextStyle(
            fontSize: 12 * s,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6 * s),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
