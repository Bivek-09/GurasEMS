import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppSpacing;
import '../models/attendance_month.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/attendance_calendar.dart';
import '../widgets/attendance_donut.dart';

/// Attendance — Academics tab.
///
/// Crimson app bar; a month selector, the attendance donut with counts, and the
/// status-coloured calendar grid beneath it. The reference's Bikram Sambat
/// year stays faithful to the source design.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.attendance;

  static const Color _surface = Color(0xFFF8F9FB);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const List<AttendanceMonth> _months = kAttendanceMonths;

  /// Shrawan→Bhadra→Ashoj; the reference opens on Bhadra.
  int _monthIndex = 1;

  AttendanceMonth get _month => _months[_monthIndex];

  void _prevMonth() {
    if (_monthIndex > 0) setState(() => _monthIndex--);
  }

  void _nextMonth() {
    if (_monthIndex < _months.length - 1) setState(() => _monthIndex++);
  }

  int get _academicsIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Academics',
  );

  void _onTabSelected(int index) =>
      AppRoutes.switchTab(context, index, _academicsIndex);

  void _showDay(int day) {
    final AttendanceStatus status = _month.statusOf(day);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) =>
          _DayDetailSheet(monthTitle: _month.title, day: day, status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = AppScreenBar.heightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: AttendanceScreen._surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: barHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg * s,
                  AppSpacing.lg * s,
                  AppSpacing.lg * s,
                  navHeight + 24 * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _MonthSelector(
                          title: _month.title,
                          onPrev: _prevMonth,
                          onNext: _nextMonth,
                          canPrev: _monthIndex > 0,
                          canNext: _monthIndex < _months.length - 1,
                          scale: s,
                        ),
                        SizedBox(height: 14 * s),
                        _SummaryCard(month: _month, scale: s),
                        SizedBox(height: 14 * s),
                        _CalendarCard(
                          month: _month,
                          scale: s,
                          onDayTap: _showDay,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppScreenBar(
              title: 'Attendance',
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),

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

/// Decoration shared by the summary and calendar cards, so the two white
/// surfaces can never drift apart.
BoxDecoration _cardDecoration(double s) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16 * s),
    border: Border.all(color: AppPalette.cardBorder),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 14 * s,
        offset: Offset(0, 2 * s),
      ),
    ],
  );
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.title,
    required this.onPrev,
    required this.onNext,
    required this.canPrev,
    required this.canNext,
    required this.scale,
  });

  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool canPrev;
  final bool canNext;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10 * s,
        horizontal: AppSpacing.lg * s,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _Chevron(
            onTap: canPrev ? onPrev : null,
            scale: s,
            icon: Icons.chevron_left_rounded,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15 * s,
                fontWeight: FontWeight.w600,
                color: AppPalette.headingText,
              ),
            ),
          ),
          _Chevron(
            onTap: canNext ? onNext : null,
            scale: s,
            icon: Icons.chevron_right_rounded,
          ),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({
    required this.onTap,
    required this.scale,
    required this.icon,
  });

  final VoidCallback? onTap;
  final double scale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return SizedBox(
      width: 28 * s,
      height: 28 * s,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(
            icon,
            size: 20 * s,
            color: onTap == null
                ? const Color(0xFFD1D5DB)
                : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.month, required this.scale});

  final AttendanceMonth month;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: _cardDecoration(s),
      child: Row(
        children: <Widget>[
          AttendanceDonut(percent: month.percent),
          Container(
            width: 1,
            height: 96 * s,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg * s),
            color: const Color(0xFFF3F4F6),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _legendRow('Present', AppPalette.success, month.present, s),
                SizedBox(height: 6 * s),
                _legendRow('Absent', AppPalette.error, month.absent, s),
                SizedBox(height: 6 * s),
                _legendRow('Leave', AppPalette.warning, month.leave, s),
                SizedBox(height: AppSpacing.sm * s),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: const Color(0xFFF3F4F6),
                ),
                SizedBox(height: AppSpacing.sm * s),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Text(
                      '${month.total}',
                      style: TextStyle(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.headingText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(String label, Color color, int count, double s) {
    return Row(
      children: <Widget>[
        Container(
          width: 10 * s,
          height: 10 * s,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.sm * s),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13 * s,
            fontWeight: FontWeight.w700,
            color: AppPalette.headingText,
          ),
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.scale,
    required this.onDayTap,
  });

  final AttendanceMonth month;
  final double scale;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: _cardDecoration(s),
      child: AttendanceCalendar(month: month, onDayTap: onDayTap),
    );
  }
}

/// Day detail bottom sheet.
class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({
    required this.monthTitle,
    required this.day,
    required this.status,
  });

  final String monthTitle;
  final int day;
  final AttendanceStatus status;

  String get _statusLabel {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.leave:
        return 'On Leave';
      case AttendanceStatus.none:
        return 'No Class / Holiday';
    }
  }

  Color get _statusColor {
    switch (status) {
      case AttendanceStatus.present:
        return AppPalette.success;
      case AttendanceStatus.absent:
        return AppPalette.error;
      case AttendanceStatus.leave:
        return AppPalette.warning;
      case AttendanceStatus.none:
        return const Color(0xFF9CA3AF);
    }
  }

  String? get _punchIn =>
      status == AttendanceStatus.present ? '08:50 AM' : null;

  String get _remarks {
    switch (status) {
      case AttendanceStatus.present:
        return 'Attended all periods';
      case AttendanceStatus.absent:
        return 'Unexcused Absence';
      case AttendanceStatus.leave:
        return 'Approved Sick Leave';
      case AttendanceStatus.none:
        return 'Weekend or Prescribed Holiday';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl * s,
        AppSpacing.md * s,
        AppSpacing.xl * s,
        24 * s,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 40 * s,
              height: 4 * s,
              decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
            ),
          ),
          SizedBox(height: 14 * s),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$monthTitle · Day $day',
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.headingText,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
                icon: Icon(Icons.close_rounded, size: 18 * s),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md * s),
          _row(
            'Status',
            s,
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * s,
                vertical: AppSpacing.xs * s,
              ),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _row('Punch In', s, text: _punchIn ?? '-- : --'),
          _row('Remarks', s, text: _remarks),
          SizedBox(height: AppSpacing.lg * s),
          SizedBox(
            height: 44 * s,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.maroon800,
              ),
              child: const Text('Dismiss'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double s, {Widget? trailing, String text = ''}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * s),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          if (trailing != null)
            trailing
          else
            Text(
              text,
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: AppPalette.headingText,
              ),
            ),
        ],
      ),
    );
  }
}
