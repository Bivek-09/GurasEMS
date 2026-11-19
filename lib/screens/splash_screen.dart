import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/splash_timeline.dart';
import '../widgets/animated_brand.dart';
import 'login_screen.dart';

/// Full-screen brand intro.
///
/// The supplied school photograph fills the screen as the background layer,
/// then the brand stack reveals on top of it — logo first, then the "GurasEMS"
/// name, then the "Student" label and tagline — before handing off to
/// [LoginScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Entry route of the application, declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.splash;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Single clock driving every stage of the reveal.
  late final AnimationController _controller;

  /// Owns the post-animation hold so it can be cancelled if we are torn down
  /// before it fires.
  Timer? _holdTimer;

  /// Last-resort hand-off. If the ticker is silenced before the controller ever
  /// reports completion — the app is backgrounded mid-intro, or a platform
  /// glitch freezes the clock — this still moves the user on instead of leaving
  /// them stranded on the splash screen.
  Timer? _fallbackTimer;

  /// Guards [_openLogin] so the hold timer and the fallback can never both
  /// navigate.
  bool _navigated = false;

  /// Whether the platform has animations switched off. Read from
  /// `MediaQuery` in [didChangeDependencies] and applied exactly once.
  bool _reduceMotion = false;
  bool _reduceMotionApplied = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SplashTimeline.total,
    );
    _controller.addStatusListener(_handleStatus);
    _controller.forward();
    _fallbackTimer = Timer(
      SplashTimeline.total + SplashTimeline.hold,
      _openLogin,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reduceMotion && !_reduceMotionApplied) {
      _reduceMotionApplied = true;
      // Skip the stagger and show the finished lockup at once; the status
      // listener then holds it for only [SplashTimeline.reducedHold].
      _controller.value = 1;
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _holdTimer?.cancel();
    _holdTimer = Timer(
      _reduceMotion ? SplashTimeline.reducedHold : SplashTimeline.hold,
      _openLogin,
    );
  }

  void _openLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;
    // Removing the whole stack guarantees the system back gesture can never
    // land back on the splash screen.
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _fallbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Maps a [SplashTimeline] interval onto the master controller.
  Animation<double> _stage(Interval interval) =>
      _controller.drive(CurveTween(curve: interval));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1 ─ The school photograph is the background layer.
          _SchoolBackdrop(animation: _stage(SplashTimeline.image)),

          // 2 ─ The brand stack is centred over it and animates in afterwards.
          SafeArea(
            child: Center(
              child: FittedBox(
                // Safety net: scales the whole stack down as one unit on
                // unusually short or narrow screens instead of overflowing.
                fit: BoxFit.scaleDown,
                child: AnimatedBrand(controller: _controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed school photograph that backs the entire splash composition.
///
/// It fades in first and settles from a hair larger, so it reads as a soft
/// background rather than a hard cut. [BoxFit.cover] preserves the aspect ratio
/// and the warm veil keeps the wordmark legible over whatever the photograph
/// contains without hiding it completely.
class _SchoolBackdrop extends StatelessWidget {
  const _SchoolBackdrop({required this.animation});

  final Animation<double> animation;

  /// Scale the photograph settles from, so the reveal has a gentle push-in.
  static const double _startScale = 1.06;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: _startScale,
                end: 1,
              ).animate(animation),
              child: Image.asset(
                AppAssets.school,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppPalette.background.withValues(alpha: 0.72),
                  AppPalette.background.withValues(alpha: 0.58),
                  AppPalette.background.withValues(alpha: 0.90),
                ],
                stops: const <double>[0.0, 0.48, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
