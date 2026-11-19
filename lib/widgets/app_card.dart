import 'package:flutter/material.dart';

import '../core/app_palette.dart';
import '../core/app_theme.dart';

/// Standard white surface card.
///
/// A single implementation of the reference's card treatment — radius, hairline
/// border and a restrained shadow. Passing [onTap] turns the whole surface into
/// a tappable target with a consistent ripple instead of each screen wiring its
/// own [InkWell].
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final double r = radius ?? AppRadii.card;

    final BoxDecoration decoration = BoxDecoration(
      color: color ?? AppPalette.surface,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: borderColor ?? AppPalette.cardBorder),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    if (onTap == null) {
      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding, child: child),
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(r),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: decoration,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
