import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/splash_timeline.dart';

/// The centred brand stack of the splash screen:
///
/// ```text
///      [logo]
///    GurasEMS
///     Student
///  Your Learning Journey
///    in One Place
/// ```
///
/// Everything is driven by a single external controller through [Interval]s, so
/// the reveals stay sequential. The transitions listen to the animation
/// themselves, which means this widget never calls [State.setState] per frame.
///
/// Stages are produced with `drive(CurveTween(...))` rather than
/// [CurvedAnimation]; per the Flutter API docs the latter adds a status
/// listener to its parent and therefore requires explicit disposal, while
/// `drive` registers nothing and cannot leak.
class AnimatedBrand extends StatelessWidget {
  const AnimatedBrand({super.key, required this.controller});

  /// Master controller, owned and disposed by the splash screen.
  final Animation<double> controller;

  /// Logo scale at the very start of its reveal.
  static const double _logoStartScale = 0.86;

  /// Unscaled dimensions, multiplied by the responsive scale factor.
  static const double _logoHeight = 96;
  static const double _brandSize = 46;
  static const double _studentSize = 22;
  static const double _taglineSize = 14.5;

  /// Spacing expressed as a fraction of the adjacent text size so the stack
  /// stays optically balanced at every scale.
  static const double _brandGap = 0.62;
  static const double _studentGap = 0.46;
  static const double _taglineGap = 0.90;

  /// How far each reveal starts below its final position.
  static const double _riseOffset = 0.16;

  /// Maps a [SplashTimeline] interval onto the master controller.
  Animation<double> _stage(Interval interval) =>
      controller.drive(CurveTween(curve: interval));

  /// Fades [child] in while it rises slightly into place.
  Widget _reveal({required Animation<double> stage, required Widget child}) {
    return FadeTransition(
      opacity: stage,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, _riseOffset),
          end: Offset.zero,
        ).animate(stage),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppLayout.scaleOf(context);

    final logoStage = _stage(SplashTimeline.logo);
    final brandStage = _stage(SplashTimeline.brand);
    final studentStage = _stage(SplashTimeline.student);
    final taglineStage = _stage(SplashTimeline.tagline);

    final brandSize = _brandSize * scale;
    final studentSize = _studentSize * scale;
    final taglineSize = _taglineSize * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // 1 ─ Logo: soft fade while scaling up into position.
        FadeTransition(
          opacity: logoStage,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: _logoStartScale,
              end: 1,
            ).animate(logoStage),
            child: Image.asset(
              AppAssets.logo,
              height: _logoHeight * scale,
              fit: BoxFit.contain,
            ),
          ),
        ),

        SizedBox(height: _brandGap * brandSize),

        // 2 ─ Brand wordmark. Split into two spans so "Guras" and "EMS" carry
        //      their own brand colours without distorting the text.
        _reveal(
          stage: brandStage,
          child: Text.rich(
            TextSpan(
              text: 'Guras',
              style: const TextStyle(color: AppPalette.navy),
              children: <InlineSpan>[
                TextSpan(
                  text: 'EMS',
                  style: const TextStyle(color: AppPalette.blue),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: brandSize,
              fontWeight: FontWeight.w700,
              height: 1.0,
              // Tracking is expressed as a fraction of the type size so it
              // scales with the wordmark instead of fighting it.
              letterSpacing: -0.02 * brandSize,
            ),
          ),
        ),

        SizedBox(height: _studentGap * brandSize),

        // 3 ─ Student label in the maroon identity colour.
        _reveal(
          stage: studentStage,
          child: Text(
            'Student',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: studentSize,
              fontWeight: FontWeight.w600,
              color: AppPalette.maroon,
              letterSpacing: 0.22 * studentSize,
            ),
          ),
        ),

        SizedBox(height: _taglineGap * taglineSize),

        // 4 ─ Tagline: a plain fade, so the composition visibly comes to rest.
        FadeTransition(
          opacity: taglineStage,
          child: Text(
            'Your Learning Journey\nin One Place',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: taglineSize,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: AppPalette.muted,
              letterSpacing: 0.02 * taglineSize,
            ),
          ),
        ),
      ],
    );
  }
}
