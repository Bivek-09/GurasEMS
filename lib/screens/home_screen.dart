import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppSpacing;
import '../models/student_profile.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/dashboard_hero_card.dart';
import '../widgets/more_services_sheet.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/staggered_entrance.dart';
import '../widgets/todays_classes_card.dart';

/// Student home dashboard.
///
/// Three layers in one [Stack], matching the design: the maroon header sits
/// underneath, the scrolling content rides up over its curved edge, and the
/// translucent navigation floats above both. Content that overflows the
/// viewport scrolls beneath the bar rather than being cut off by it.
///
/// The signed-in record lives in [StudentProfile] and the day's schedule in
/// [_todayClasses], so the header greeting, the hero card and the classes
/// section all read the same data instead of carrying their own copies.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.home;

  // Sample timetable slice — replaced by the real day schedule once the
  // academic service is wired in.
  static const List<ClassSession> _todayClasses = <ClassSession>[
    ClassSession(
      subject: 'Mathematics',
      startTime: '09:00 AM',
      endTime: '09:45 AM',
      room: 'Room 101',
      status: 'Ongoing',
    ),
  ];

  static const double _gutter = AppLayout.gutter;
  static const double _sectionGap = AppSpacing.xl;
  static const double _blockGap = 24;

  /// The dashboard exposes every bottom-nav destination; it stays selected on
  /// Home itself.
  static Set<int> get _enabledTabs => <int>{
    AppRoutes.homeIndex,
    AppRoutes.academicsIndex,
    AppRoutes.noticesIndex,
    AppRoutes.profileIndex,
  };

  /// Time-of-day greeting, read once per build — no timers to dispose and no
  /// midnight drift while the screen sits in the background.
  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _handleTabSelected(BuildContext context, int index) {
    // Shared tab switcher: keeps /home at the bottom and swaps the tab screen
    // on top. Tapping the current tab is a no-op.
    AppRoutes.switchTab(context, index, AppRoutes.homeIndex);
  }

  /// Routes a quick-action tile to its destination. "More" opens the services
  /// sheet; unmapped labels do nothing rather than pushing an empty page.
  void _handleActionTap(BuildContext context, String label) {
    if (label == 'More') {
      MoreServicesSheet.show(context);
      return;
    }

    final String? route = switch (label) {
      'Attendance' => AppRoutes.attendance,
      'Results' => AppRoutes.results,
      'Fees' => AppRoutes.fees,
      'Classes' || 'Timetable' => AppRoutes.classes,
      'Library' => AppRoutes.library,
      'Transport' => AppRoutes.transport,
      'Notices' => AppRoutes.notices,
      _ => null,
    };

    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double headerHeight = AppTopBar.heightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: AppPalette.dashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — maroon header with the curved lower edge. Painted first,
          // so it sits underneath the scrolling body and the card can ride up
          // over its curve.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppTopBar(
              greeting: _greeting,
              name: StudentProfile.name,
              grade: 'Grade ${StudentProfile.grade}',
              section: 'Section ${StudentProfile.section}',
              avatarUrl: StudentProfile.avatarUrl,
              onNotificationsTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.notices),
            ),
          ),

          // Layer 2 — scrolling body, painted above the header. The top inset
          // leaves the content overlapping the header's curve by exactly
          // [AppTopBar.contentOverlap]; the scroll view's hard-edge clip hides
          // everything above that line, so the card overlaps the curve without
          // ever covering the greeting row.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: headerHeight - AppTopBar.contentOverlap * s,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  _gutter * s,
                  0,
                  _gutter * s,
                  navHeight + _blockGap * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: StaggeredEntrance(
                      children: <Widget>[
                        const DashboardHeroCard(
                          imageAsset: AppAssets.school,
                        ),
                        SizedBox(height: _sectionGap * s),
                        QuickActionsGrid(
                          onActionTap: (String label) =>
                              _handleActionTap(context, label),
                        ),
                        SizedBox(height: _blockGap * s),
                        TodaysClassesSection(
                          sessions: _todayClasses,
                          onViewAll: () =>
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.classes),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer 3 — persistent navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: 0,
              enabledIndices: _enabledTabs,
              onSelected: (int index) => _handleTabSelected(context, index),
            ),
          ),
        ],
      ),
    );
  }
}
