import 'package:flutter/material.dart';

/// A restrained fade-and-rise transition used for every pushed route.
///
/// The reference app reads as calm and professional, so pages cross-fade while
/// sliding a very short distance instead of using the platform's more
/// theatrical defaults. Motion is kept subtle so navigation still feels
/// immediate, and reduced-motion users get a plain fade.
///
/// Curves are produced with `drive(CurveTween(...))` rather than
/// [CurvedAnimation]; per the Flutter API docs the latter adds a status listener
/// to its parent and therefore requires explicit disposal, while `drive`
/// registers nothing and cannot leak.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  /// How far a new page rises into place, as a fraction of its own height.
  static const double _riseOffset = 0.035;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final double magnitude = _magnitude(context);
    final Animation<double> fade = animation.drive(
      CurveTween(curve: Curves.easeOut),
    );

    if (magnitude == 0) {
      return FadeTransition(opacity: fade, child: child);
    }

    final Animation<double> slide = animation.drive(
      CurveTween(curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, _riseOffset * magnitude),
          end: Offset.zero,
        ).animate(slide),
        child: child,
      ),
    );
  }

  /// Returns `1` for full motion and `0` when the platform asks for reduced
  /// animation, without forcing a rebuild contract on callers.
  double _magnitude(BuildContext context) {
    final MediaQueryData? media = MediaQuery.maybeOf(context);
    if (media != null && media.disableAnimations) return 0;
    return 1;
  }
}
