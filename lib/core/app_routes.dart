import 'package:flutter/material.dart';

/// Single source of truth for route names and main-tab switching.
///
/// The four tab destinations map onto the four bottom-nav icons:
///   Home(0) -> /home
///   Academics(1) -> /attendance   (Attendance is the entry screen)
///   Notices(2) -> /notices
///   Profile(3) -> /profile
///
/// Every tab is reached through the nav, so the route stack is always
/// [splash-less root /home] with one tab screen on top. Switching tabs swaps
/// that top screen instead of stacking.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String attendance = '/attendance';
  static const String results = '/results';
  static const String fees = '/fees';
  static const String classes = '/classes';
  static const String library = '/library';
  static const String transport = '/transport';
  static const String notices = '/notices';
  static const String personalInformation = '/personal-information';
  static const String guardianInformation = '/guardian-information';
  static const String academicInformation = '/academic-information';
  static const String profile = '/profile';

  // Bottom-nav indices.
  static const int homeIndex = 0;
  static const int academicsIndex = 1;
  static const int noticesIndex = 2;
  static const int profileIndex = 3;

  /// The live destination for a tab index, or null when its screen is not
  /// built yet.
  static String? tabRoute(int index) => switch (index) {
    homeIndex => home,
    academicsIndex => attendance,
    noticesIndex => notices,
    resultsIndex => results,
    profileIndex => profile,
    _ => null,
  };

  static const int resultsIndex = 4;

  /// Move to a main-tab screen without stacking tabs.
  ///
  /// [activeIndex] is the destination's tab index so tapping the current one is
  /// a no-op. The dashboard stays as the root route and the tab's screen sits
  /// above it; Home clears that top layer by returning to the root.
  static void switchTab(BuildContext context, int index, int activeIndex) {
    if (index == activeIndex) return;
    final String? target = tabRoute(index);
    if (target == null) return;

    final NavigatorState navigator = Navigator.of(context);
    if (index == homeIndex) {
      navigator.popUntil((Route<dynamic> route) => route.isFirst);
      return;
    }
    navigator.pushNamedAndRemoveUntil(
      target,
      (Route<dynamic> route) => route.isFirst,
    );
  }
}
