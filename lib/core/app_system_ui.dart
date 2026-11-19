import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';

/// Single source of truth for the Android system-bar appearance.
///
/// The app targets Android API 36, so Flutter runs edge-to-edge: from Android
/// 15 (API 35) on the status bar is transparent and its colour is decided by
/// whatever the app paints beneath it — `statusBarColor` is ignored. On API 34
/// and below the bar still honours `statusBarColor`, and Flutter's default
/// activity paints it with a translucent grey (`0x40000000`), which is what
/// made the bar read as grey/dark and detached from the UI.
///
/// To work on every supported version this helper fixes the two things that
/// are honoured everywhere:
///
///  * [SystemUiOverlayStyle.statusBarIconBrightness] — so the clock, network
///    and battery stay readable against the colour behind them, and
///  * [SystemUiOverlayStyle.systemStatusBarContrastEnforced] — disabled, so
///    Android does not paint its translucent contrast scrim over the bar on
///    API 29+.
///
/// [SystemUiOverlayStyle.statusBarColor] is also set to the screen's own top
/// colour. It is only applied below API 35, but there it replaces the engine's
/// grey with the header/canvas colour, so older devices blend identically to
/// edge-to-edge ones. Screens should never call `SystemChrome` directly; the
/// route table in `main.dart` wraps each screen in an [AppSystemUiRegion].
abstract final class AppSystemUi {
  /// Bars for a screen whose top edge is the warm off-white canvas — the
  /// splash and login screens. Dark icons keep the system indicators legible.
  static const SystemUiOverlayStyle onLightCanvas = SystemUiOverlayStyle(
    statusBarColor: AppPalette.background,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
  );

  /// Bars for a screen capped by a maroon header — the dashboard and every
  /// detail screen. Light icons keep the system indicators legible.
  static const SystemUiOverlayStyle onDarkHeader = SystemUiOverlayStyle(
    statusBarColor: AppPalette.maroon800,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
  );
}

/// Publishes [style] as the system-bar appearance for as long as it is the
/// topmost such region on screen.
///
/// This is the declarative [`AnnotatedRegion`] mechanism, not an imperative
/// `SystemChrome` call, so exactly one region — the one belonging to the route
/// on top of the navigator — is ever in effect. That is what keeps the bars in
/// step with the visible screen without every widget re-stating the style.
class AppSystemUiRegion extends StatelessWidget {
  const AppSystemUiRegion({
    super.key,
    required this.style,
    required this.child,
  });

  /// The overlay style applied while this region is on top.
  final SystemUiOverlayStyle style;

  /// The screen this region styles.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(value: style, child: child);
  }
}
