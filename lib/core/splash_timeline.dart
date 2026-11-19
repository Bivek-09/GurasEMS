import 'package:flutter/animation.dart';

/// Single source of truth for the splash choreography.
///
/// One [AnimationController] drives the entire sequence and each stage owns its
/// own [Interval]. That overlap is what keeps the reveals reading as
/// sequential — logo, brand name, student label, tagline, photograph — instead
/// of everything appearing at once.
abstract final class SplashTimeline {
  /// Length of the full choreography.
  ///
  /// Every stage below is a fraction of this, so trimming it speeds the whole
  /// intro up without disturbing the order or overlap of the reveals.
  static const Duration total = Duration(milliseconds: 2200);

  /// How long the finished composition is held on screen before navigating.
  ///
  /// Long enough to read the completed brand lockup, short enough that it never
  /// feels like the app is stalling.
  static const Duration hold = Duration(milliseconds: 500);

  /// How long the finished composition is held when the platform has animations
  /// switched off. The choreography is skipped entirely in that case, so this
  /// is only a beat to register the wordmark before the hand-off.
  static const Duration reducedHold = Duration(milliseconds: 200);

  /// 1. School photograph fades in first, establishing the background layer.
  static const Interval image = Interval(
    0.00,
    0.30,
    curve: Curves.easeOutCubic,
  );

  /// 2. Logo fades in while scaling up from a slightly smaller size.
  static const Interval logo = Interval(0.14, 0.44, curve: Curves.easeOutCubic);

  /// 3. "GurasEMS" fades and rises into place.
  static const Interval brand = Interval(
    0.40,
    0.66,
    curve: Curves.easeOutCubic,
  );

  /// 4. "Student" fades and rises.
  static const Interval student = Interval(
    0.62,
    0.80,
    curve: Curves.easeOutCubic,
  );

  /// 5. Tagline fades in without translation, so the movement settles down.
  static const Interval tagline = Interval(0.76, 0.92, curve: Curves.easeOut);
}
