import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';

/// Paid / Pending pill shared by the fee rows and the invoice sheet.
///
/// One widget keeps the badge's wording and colours identical wherever a
/// fee's state is shown.
class FeeStatusBadge extends StatelessWidget {
  const FeeStatusBadge({super.key, required this.paid});

  final bool paid;

  static const String paidLabel = 'Paid';
  static const String pendingLabel = 'Pending';

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: paid ? AppPalette.statusGreenBg : AppPalette.pendingBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: paid ? AppPalette.statusGreenBorder : AppPalette.pendingBorder,
        ),
      ),
      child: Text(
        paid ? paidLabel : pendingLabel,
        style: TextStyle(
          fontSize: 11 * s,
          fontWeight: FontWeight.w600,
          color: paid ? AppPalette.statusGreen : AppPalette.pendingText,
        ),
      ),
    );
  }
}
