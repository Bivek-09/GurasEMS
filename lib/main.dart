import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_system_ui.dart';
import 'core/app_theme.dart';
import 'screens/academic_information_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/guardian_information_screen.dart';
import 'core/app_routes.dart';
import 'screens/personal_information_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/classes_screen.dart';
import 'screens/fees_screen.dart';
import 'screens/library_screen.dart';
import 'screens/notices_screen.dart';
import 'screens/results_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/transport_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Baseline for the very first frame, before any route annotates itself. The
  // native LaunchTheme already matches this colour, so startup is seamless.
  SystemChrome.setSystemUIOverlayStyle(AppSystemUi.onLightCanvas);
  runApp(const GurasEmsApp());
}

/// System-bar appearance for a route's top edge.
///
/// Only the splash and login screens sit on the warm off-white canvas; every
/// other route is capped by a maroon header. Keeping the mapping here, next to
/// the route table, means a screen can never forget to declare it and there is
/// exactly one writer for the bars.
SystemUiOverlayStyle _overlayStyleFor(String route) {
  return switch (route) {
    AppRoutes.splash || AppRoutes.login => AppSystemUi.onLightCanvas,
    _ => AppSystemUi.onDarkHeader,
  };
}

/// Wraps a route's screen in the [AppSystemUiRegion] that publishes its
/// system-bar style while the route is on screen.
WidgetBuilder _themed(String route, WidgetBuilder builder) {
  return (BuildContext context) => AppSystemUiRegion(
    style: _overlayStyleFor(route),
    child: builder(context),
  );
}

/// Root widget for GurasEMS.
///
/// Routing is declared once, here, so screens navigate by name rather than by
/// constructing ad-hoc routes — which is what lets the splash screen clear the
/// stack behind it.
class GurasEmsApp extends StatelessWidget {
  const GurasEmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GurasEMS',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: SplashScreen.routeName,
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: _themed(
          AppRoutes.splash,
          (_) => const SplashScreen(),
        ),
        AppRoutes.login: _themed(AppRoutes.login, (_) => const LoginScreen()),
        AppRoutes.home: _themed(AppRoutes.home, (_) => const HomeScreen()),
        AppRoutes.profile: _themed(
          AppRoutes.profile,
          (_) => const ProfileScreen(),
        ),
        AppRoutes.personalInformation: _themed(
          AppRoutes.personalInformation,
          (_) => const PersonalInformationScreen(),
        ),
        AppRoutes.guardianInformation: _themed(
          AppRoutes.guardianInformation,
          (_) => const GuardianInformationScreen(),
        ),
        AppRoutes.academicInformation: _themed(
          AppRoutes.academicInformation,
          (_) => const AcademicInformationScreen(),
        ),
        AppRoutes.attendance: _themed(
          AppRoutes.attendance,
          (_) => const AttendanceScreen(),
        ),
        AppRoutes.results: _themed(
          AppRoutes.results,
          (_) => const ResultsScreen(),
        ),
        AppRoutes.fees: _themed(AppRoutes.fees, (_) => const FeesScreen()),
        AppRoutes.classes: _themed(
          AppRoutes.classes,
          (_) => const ClassesScreen(),
        ),
        AppRoutes.library: _themed(
          AppRoutes.library,
          (_) => const LibraryScreen(),
        ),
        AppRoutes.transport: _themed(
          AppRoutes.transport,
          (_) => const TransportScreen(),
        ),
        AppRoutes.notices: _themed(
          AppRoutes.notices,
          (_) => const NoticesScreen(),
        ),
      },
    );
  }
}
