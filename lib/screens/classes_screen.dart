import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/class_schedule.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/class_detail_sheet.dart';

/// Which slice of the timetable is showing.
enum ScheduleView { week, month }

/// Timetable — the student's weekly schedule under the Academics section.
///
/// Rebuilt from the "Timetable" reference: a crimson app bar with a jump-to-
/// today control, a Week/Month segmented toggle, day cards that list each
/// period as a coloured row, a compact month grid with an assessment notice,
/// and a lecture-detail sheet for any period. The bottom nav keeps the
/// Academics tab active.
class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.classes;

  static const Color _surface = AppSlate.shade50;

  // ── App bar geometry ──────────────────────────────────────────────────
  static const double _topPadding = 4;
  static const double _bottomPadding = 16;
  static const double _control = 40;

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  ScheduleView _view = ScheduleView.week;

  /// Briefly rings the current-day card after a jump-to-today.
  bool _highlightToday = false;
  Timer? _highlightTimer;

  final GlobalKey _todayKey = GlobalKey();

  double _barHeight(BuildContext context) => AppScreenBar.heightOf(
    context,
    topPadding: ClassesScreen._topPadding,
    bottomPadding: ClassesScreen._bottomPadding,
  );

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────
  void _setView(ScheduleView view) {
    if (view == _view) return;
    setState(() => _view = view);
  }

  void _openPeriod(TimetablePeriod period) =>
      PeriodDetailSheet.show(context, period: period);

  /// Returns to the week view and scrolls the current-day card into sight,
  /// ringing it for a moment — the reference's calendar shortcut.
  void _jumpToToday() {
    setState(() {
      _view = ScheduleView.week;
      _highlightToday = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? context = _todayKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      }
    });

    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _highlightToday = false);
    });
  }

  // ── Navigation ────────────────────────────────────────────────────────
  int get _academicsIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Academics',
  );

  void _onTabSelected(int index) =>
      AppRoutes.switchTab(context, index, _academicsIndex);

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = _barHeight(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: ClassesScreen._surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — pinned toggle strip above the scrolling schedule.
          Positioned.fill(
            child: Column(
              children: <Widget>[
                SizedBox(height: barHeight),
                _ToggleSection(view: _view, scale: s, onChanged: _setView),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg * s,
                      14 * s,
                      AppSpacing.lg * s,
                      navHeight + AppSpacing.block * s,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppLayout.maxContentWidth,
                        ),
                        child: _view == ScheduleView.week
                            ? _WeekView(
                                scale: s,
                                highlightToday: _highlightToday,
                                todayKey: _todayKey,
                                onPeriodTap: _openPeriod,
                              )
                            : _MonthView(
                                scale: s,
                                onDayTap: () => _setView(ScheduleView.week),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Layer 2 — pinned crimson app bar.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppScreenBar(
              title: 'Timetable',
              leadingIcon: Icons.chevron_left_rounded,
              iconSize: 21,
              topPadding: ClassesScreen._topPadding,
              bottomPadding: ClassesScreen._bottomPadding,
              horizontalPadding: 12,
              titleSize: 18,
              titleWeight: FontWeight.w700,
              titleLetterSpacing: 0.3,
              onBack: () => Navigator.of(context).maybePop(),
              trailing: _RoundIconButton(
                icon: Icons.calendar_month_rounded,
                scale: s,
                onTap: _jumpToToday,
              ),
            ),
          ),

          // Layer 3 — persistent navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: _academicsIndex,
              enabledIndices: <int>{0, 1, 2, 3},
              onSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Round icon button
// ─────────────────────────────────────────────────────────────────────────

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return SizedBox(
      width: ClassesScreen._control * s,
      height: ClassesScreen._control * s,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(icon, size: 21 * s, color: Colors.white),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Week / Month toggle
// ─────────────────────────────────────────────────────────────────────────

class _ToggleSection extends StatelessWidget {
  const _ToggleSection({
    required this.view,
    required this.scale,
    required this.onChanged,
  });

  final ScheduleView view;
  final double scale;
  final ValueChanged<ScheduleView> onChanged;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final bool week = view == ScheduleView.week;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl * s,
        14 * s,
        AppSpacing.xl * s,
        10 * s,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppSlate.shade100)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 340 * s),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.xs * s),
                    decoration: BoxDecoration(
                      color: AppGray.shade100,
                      borderRadius: BorderRadius.circular(AppRadii.inner * s),
                      border: Border.all(color: AppGray.shade200),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _SegmentButton(
                            label: 'Week',
                            active: week,
                            scale: s,
                            onTap: () => onChanged(ScheduleView.week),
                          ),
                        ),
                        Expanded(
                          child: _SegmentButton(
                            label: 'Month',
                            active: !week,
                            scale: s,
                            onTap: () => onChanged(ScheduleView.month),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      week
                          ? '${kTimetableMonth.toUpperCase()} • ${kTimetableTerm.toUpperCase()}'
                          : 'MONTHLY CALENDAR VIEW',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5 * s,
                        color: AppPalette.maroon800,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm * s),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9 * s,
                      vertical: 3 * s,
                    ),
                    decoration: BoxDecoration(
                      color: week ? const Color(0xFFFEF2F2) : AppGray.shade100,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      week ? kTimetableTodayLabel : 'Ashoj 2083',
                      style: TextStyle(
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w700,
                        color: week ? AppPalette.maroon800 : AppGray.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool active;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: active ? AppPalette.maroon800 : Colors.transparent,
        borderRadius: BorderRadius.circular(9 * s),
        boxShadow: active
            ? <BoxShadow>[
                BoxShadow(
                  color: AppPalette.maroon800.withValues(alpha: 0.2),
                  blurRadius: 6 * s,
                  offset: Offset(0, 1 * s),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(9 * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 7 * s),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? Colors.white : AppPalette.supportingText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Week view
// ─────────────────────────────────────────────────────────────────────────

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.scale,
    required this.highlightToday,
    required this.todayKey,
    required this.onPeriodTap,
  });

  final double scale;
  final bool highlightToday;
  final GlobalKey todayKey;
  final ValueChanged<TimetablePeriod> onPeriodTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < kTimetableDays.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 14 * s),
          _DayCard(
            key: kTimetableDays[i].isToday ? todayKey : null,
            day: kTimetableDays[i],
            highlight: highlightToday && kTimetableDays[i].isToday,
            scale: s,
            onPeriodTap: onPeriodTap,
          ),
        ],
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    super.key,
    required this.day,
    required this.highlight,
    required this.scale,
    required this.onPeriodTap,
  });

  final TimetableDay day;
  final bool highlight;
  final double scale;
  final ValueChanged<TimetablePeriod> onPeriodTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final Color border = highlight
        ? AppPalette.maroon800
        : day.isToday
        ? AppPalette.maroon800.withValues(alpha: 0.25)
        : AppPalette.cardBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: border, width: highlight ? 2 : 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 50 * s,
            child: Column(
              children: <Widget>[
                Text(
                  day.weekday,
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
                    color: AppPalette.supportingText,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  '${day.dayNumber}',
                  style: TextStyle(
                    fontSize: 23 * s,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5 * s,
                    color: day.isToday
                        ? AppPalette.maroon800
                        : AppGray.shade800,
                  ),
                ),
                if (day.isToday) ...<Widget>[
                  SizedBox(height: 6 * s),
                  Container(
                    width: 6 * s,
                    height: 6 * s,
                    decoration: const BoxDecoration(
                      color: AppPalette.maroon800,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg * s),
            height: 72 * s,
            color: AppSlate.shade100,
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                for (int i = 0; i < day.periods.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: AppSpacing.sm * s),
                  _PeriodRow(
                    period: day.periods[i],
                    scale: s,
                    onTap: () => onPeriodTap(day.periods[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.period,
    required this.scale,
    required this.onTap,
  });

  final TimetablePeriod period;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.tiny * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs * s,
            vertical: 6 * s,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 9 * s,
                height: 9 * s,
                decoration: BoxDecoration(
                  color: period.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Text(
                  period.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5 * s,
                    fontWeight: FontWeight.w600,
                    color: AppGray.shade800,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm * s),
              Text(
                period.timeLabel,
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.supportingText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Month view
// ─────────────────────────────────────────────────────────────────────────

class _MonthView extends StatelessWidget {
  const _MonthView({required this.scale, required this.onDayTap});

  final double scale;
  final VoidCallback onDayTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _CalendarCard(scale: s, onDayTap: onDayTap),
        SizedBox(height: 14 * s),
        _AssessmentNotice(scale: s),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.scale, required this.onDayTap});

  final double scale;
  final VoidCallback onDayTap;

  static const List<String> _weekdayHeaders = <String>[
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final List<List<CalendarCell>> rows = <List<CalendarCell>>[
      for (int i = 0; i < kCalendarCells.length; i += 7)
        kCalendarCells.sublist(i, i + 7),
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  kCalendarTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: AppGray.shade800,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm * s),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm * s,
                  vertical: 3 * s,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(AppRadii.micro * s),
                ),
                child: Text(
                  '$kTeachingDays Teaching Days',
                  style: TextStyle(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.maroon800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md * s),
          Divider(height: 1, thickness: 1, color: AppSlate.shade100),
          SizedBox(height: 10 * s),
          Row(
            children: <Widget>[
              for (int i = 0; i < _weekdayHeaders.length; i++)
                Expanded(
                  child: Text(
                    _weekdayHeaders[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11 * s,
                      fontWeight: FontWeight.w700,
                      color: i == 6
                          ? const Color(0xFFF87171)
                          : AppGray.shade400,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs * s),
          for (int r = 0; r < rows.length; r++) ...<Widget>[
            if (r > 0) SizedBox(height: 2 * s),
            Row(
              children: <Widget>[
                for (final CalendarCell cell in rows[r])
                  Expanded(
                    child: _CalendarCellTile(
                      cell: cell,
                      scale: s,
                      onTap: onDayTap,
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: 10 * s),
          Text(
            kCalendarHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11 * s,
              color: AppPalette.supportingText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCellTile extends StatelessWidget {
  const _CalendarCellTile({
    required this.cell,
    required this.scale,
    required this.onTap,
  });

  final CalendarCell cell;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final bool isToday = cell.kind == CalendarCellKind.today;
    final bool selectable = isToday || cell.kind == CalendarCellKind.teaching;

    final Color color = switch (cell.kind) {
      CalendarCellKind.previous => AppGray.shade300,
      CalendarCellKind.teaching => AppGray.shade800,
      CalendarCellKind.holiday => const Color(0xFFEF4444),
      CalendarCellKind.today => Colors.white,
    };

    final Widget label = Container(
      margin: EdgeInsets.all(1 * s),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm * s),
      decoration: isToday
          ? BoxDecoration(
              color: AppPalette.maroon800,
              borderRadius: BorderRadius.circular(9 * s),
            )
          : null,
      alignment: Alignment.center,
      child: Text(
        cell.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12 * s,
          fontWeight: isToday
              ? FontWeight.w800
              : cell.kind == CalendarCellKind.holiday
              ? FontWeight.w700
              : FontWeight.w500,
          color: color,
        ),
      ),
    );

    if (!selectable) return label;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(9 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: label),
    );
  }
}

class _AssessmentNotice extends StatelessWidget {
  const _AssessmentNotice({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(AppSpacing.sm * s),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppRadii.inner * s),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16 * s,
              color: const Color(0xFFB45309),
            ),
          ),
          SizedBox(width: AppSpacing.md * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  kAssessmentTitle,
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF78350F),
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  kAssessmentBody,
                  style: TextStyle(
                    fontSize: 11 * s,
                    height: 1.35,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
