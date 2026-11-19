import 'package:flutter/material.dart';

import '../core/app_layout.dart';

/// Dark pill confirmation that sits at the top of the screen, matching the
/// reference's toast treatment.
class AppToast extends StatelessWidget {
  const AppToast({super.key, required this.message});

  final String message;

  static const IconData _icon = Icons.check_circle_outline_rounded;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24 * s),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(999),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16 * s,
              offset: Offset(0, 6 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(_icon, size: 16 * s, color: const Color(0xFF34D399)),
            SizedBox(width: 8 * s),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5 * s,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small neutral affordance used for copy actions on field rows.
class CopyIconButton extends StatelessWidget {
  const CopyIconButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return SizedBox(
      width: 32 * s,
      height: 32 * s,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(
            Icons.copy_all_outlined,
            size: 16 * s,
            color: const Color(0xFF9AA1AC),
          ),
        ),
      ),
    );
  }
}
