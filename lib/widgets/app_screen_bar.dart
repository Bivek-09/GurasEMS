import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppSpacing;

/// Maroon header shared by the detail screens.
///
/// Seven screens carried the same skeleton as a private `_AppBar`: a maroon
/// band under the status-bar inset, a circular back affordance, a centred
/// ellipsised title, a matching trailing slot and the content-width cap. That
/// skeleton lives here once; the geometry knobs let every caller keep its own
/// Stitch dimensions pixel-identical. The defaults reproduce the Attendance
/// header this was first extracted from.
class AppScreenBar extends StatelessWidget {
  const AppScreenBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.leadingIcon = Icons.arrow_back_ios_new_rounded,
    this.backSemanticLabel = 'Go Back',
    this.iconSize = 18,
    this.controlSize = _control,
    this.topPadding = _topPadding,
    this.bottomPadding = _bottomPadding,
    this.horizontalPadding = AppSpacing.lg,
    this.titleSize = 18,
    this.titleWeight = FontWeight.w600,
    this.titleLetterSpacing = 0,
    this.shadow,
  });

  final String title;

  /// Invoked by the leading affordance. Null renders the leading slot as a
  /// plain spacer so the title stays centred without a dead control.
  final VoidCallback? onBack;

  /// Right-hand slot, aligned to the trailing edge of the leading slot.
  final Widget? trailing;

  /// Glyph of the leading affordance; screens keep the arrow they already use.
  final IconData leadingIcon;

  /// Accessibility label for the icon-only back control.
  final String backSemanticLabel;

  /// Unscaled dimensions, multiplied by the responsive scale factor.
  final double iconSize;
  final double controlSize;
  final double topPadding;
  final double bottomPadding;
  final double horizontalPadding;

  /// Title typography, also scaled by the responsive factor.
  final double titleSize;
  final FontWeight titleWeight;
  final double titleLetterSpacing;

  /// Optional drop shadow, for bars that float above a light surface instead
  /// of sitting in the maroon-to-page stack. The Profile bar carries one; the
  /// detail screens need none, so the default leaves the bar flat.
  final List<BoxShadow>? shadow;

  static const double _topPadding = 4;
  static const double _bottomPadding = 16;
  static const double _control = 40;

  /// Full height of the bar including the status-bar inset, so a screen can
  /// start its scrolling content beneath it inside a Stack.
  static double heightOf(
    BuildContext context, {
    double topPadding = _topPadding,
    double controlSize = _control,
    double bottomPadding = _bottomPadding,
  }) {
    final double s = AppLayout.scaleOf(context);
    return MediaQuery.paddingOf(context).top +
        (topPadding + controlSize + bottomPadding) * s;
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double inset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.only(
        top: inset + topPadding * s,
        bottom: bottomPadding * s,
        left: horizontalPadding * s,
        right: horizontalPadding * s,
      ),
      decoration: BoxDecoration(color: AppPalette.maroon800, boxShadow: shadow),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: Row(
            children: <Widget>[
              _leading(s),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize * s,
                    fontWeight: titleWeight,
                    letterSpacing: titleLetterSpacing * s,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: controlSize * s,
                child: Align(alignment: Alignment.centerRight, child: trailing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leading(double s) {
    final double size = controlSize * s;

    if (onBack == null) {
      return SizedBox(width: size, height: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onBack,
          child: Semantics(
            button: true,
            label: backSemanticLabel,
            child: Icon(leadingIcon, size: iconSize * s, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
