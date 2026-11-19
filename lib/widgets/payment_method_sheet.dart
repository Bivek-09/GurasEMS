import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../models/fee_data.dart';

/// Bottom sheet listing the gateways a fee can be paid through.
///
/// Resolves with the chosen [PaymentGateway], or `null` when cancelled.
class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({super.key, required this.invoice});

  final FeeInvoice invoice;

  /// Gateway monogram tiles, in [kPaymentGateways] order.
  static const List<Color> _tints = <Color>[
    Color(0xFF16A34A), // eSewa
    Color(0xFF9333EA), // Khalti
    Color(0xFF2563EB), // connectIPS
    Color(0xFF1E293B), // Card
  ];

  static const List<Color> _tintBackgrounds = <Color>[
    Color(0x1A22C55E),
    Color(0x1AA855F7),
    Color(0x1A3B82F6),
    Color(0x1A1E293B),
  ];

  static Future<PaymentGateway?> show(
    BuildContext context, {
    required FeeInvoice invoice,
  }) {
    return showModalBottomSheet<PaymentGateway>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => PaymentMethodSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
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
      child: Padding(
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
            Text(
              'Select Payment Method',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6 * s),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Payable: ',
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  TextSpan(
                    text: rs(invoice.amount),
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.maroon800,
                    ),
                  ),
                  TextSpan(
                    text: ' for ${invoice.title}',
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20 * s),
            for (int i = 0; i < kPaymentGateways.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: 10 * s),
              _GatewayTile(
                gateway: kPaymentGateways[i],
                tint: _tints[i],
                tintBackground: _tintBackgrounds[i],
                scale: s,
              ),
            ],
            SizedBox(height: 14 * s),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8 * s),
                child: Text(
                  'Cancel Payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
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

class _GatewayTile extends StatelessWidget {
  const _GatewayTile({
    required this.gateway,
    required this.tint,
    required this.tintBackground,
    required this.scale,
  });

  final PaymentGateway gateway;
  final Color tint;
  final Color tintBackground;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(gateway),
        child: Container(
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: tintBackground,
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                // FittedBox keeps the longer "CARD" monogram inside its tile
                // instead of clipping on a small scale.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * s),
                    child: Text(
                      gateway.monogram,
                      style: TextStyle(
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w800,
                        color: tint,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      gateway.displayName,
                      style: TextStyle(
                        fontSize: 12.5 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2 * s),
                    Text(
                      gateway.subtitle,
                      style: TextStyle(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16 * s,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
