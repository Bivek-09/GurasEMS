import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';

/// Confirmation sheet shown before dialling a guardian.
///
/// Mirrors the reference's call prompt: a grab handle, the person being
/// called, a primary action and a neutral cancel. Returns `true` when the
/// primary action is chosen and `false` on cancel or dismissal. The number is
/// then handed to whoever opened the sheet — a platform dialler is a native
/// integration this build does not depend on yet, so the caller copies the
/// number instead.
class CallActionSheet extends StatelessWidget {
  const CallActionSheet({super.key, required this.name, required this.phone});

  final String name;
  final String phone;

  /// Presents the sheet above [context].
  ///
  /// Resolves to `true` when the user taps "Call Number Now".
  static Future<bool> show(
    BuildContext context, {
    required String name,
    required String phone,
  }) async {
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => CallActionSheet(name: name, phone: phone),
    );
    return confirmed ?? false;
  }

  void _placeCall(BuildContext context) => Navigator.of(context).pop(true);

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 20 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Grab handle.
            Center(
              child: Container(
                width: 44 * s,
                height: 4 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2 * s),
                ),
              ),
            ),
            SizedBox(height: 18 * s),
            // Who is being called.
            Column(
              children: <Widget>[
                Container(
                  width: 52 * s,
                  height: 52 * s,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.call_rounded,
                    size: 26 * s,
                    color: const Color(0xFF059669),
                  ),
                ),
                SizedBox(height: 8 * s),
                Text(
                  'Call $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17 * s,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.headingText,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  '+977 $phone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.supportingText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 22 * s),
            FilledButton.icon(
              onPressed: () => _placeCall(context),
              icon: Icon(Icons.phone_enabled_rounded, size: 18 * s),
              label: Text(
                'Call Number Now',
                style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                ),
              ),
            ),
            SizedBox(height: 10 * s),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppPalette.supportingText,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: EdgeInsets.symmetric(vertical: 14 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
