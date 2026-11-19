import 'package:flutter/widgets.dart';

/// Layout helpers shared by every screen.
///
/// Sizing is driven off the device's shortest side rather than absolute pixels
/// so the composition holds together on small phones, large phones, notched
/// devices and tablets alike.
abstract final class AppLayout {
  /// The logical width the typography and spacing were composed against —
  /// a typical modern phone in portrait.
  static const double referenceWidth = 390;

  /// Keeps type legible on the smallest supported phones.
  static const double minScale = 0.84;

  /// Stops the composition from ballooning on tablets.
  static const double maxScale = 1.45;

  /// Widest the dashboard's content column is allowed to get.
  ///
  /// The header and the scrolling body share this ceiling so a tablet or
  /// desktop window keeps the greeting, the cards and the nav bar on one
  /// vertical axis instead of letting them drift apart.
  static const double maxContentWidth = 480;

  /// Horizontal margin for a screen's content column.
  ///
  /// Shared so cards line up on the same axis as the user moves between
  /// screens instead of shifting by a few pixels per design.
  static const double gutter = 20;

  /// A multiplier relative to [referenceWidth], clamped to a sane range.
  ///
  /// Derived from the shortest side so rotating a tablet or opening the app on
  /// an unusually tall phone never skews the proportions.
  static double scaleOf(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    return (shortest / referenceWidth).clamp(minScale, maxScale).toDouble();
  }
}
