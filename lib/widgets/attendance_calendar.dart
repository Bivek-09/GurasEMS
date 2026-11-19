import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppSpacing;
import '../models/attendance_month.dart';

/// The month calendar: weekday header plus a grid whose day cells are coloured
/// by attendance status, with the present/absent/leave legend at the bottom.
class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({
    super.key,
    required this.month,
    required this.onDayTap,
  });

  final AttendanceMonth month;
  final ValueChanged<int> onDayTap;

  static const _weekdays = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  static const double _rowHeight = 32;

  Color _badgeFill(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return const Color(0xFFD1FAE5);
      case AttendanceStatus.absent:
        return const Color(0xFFFEE2E2);
      case AttendanceStatus.leave:
        return const Color(0xFFFEF3C7);
      case AttendanceStatus.none:
        return Colors.transparent;
    }
  }

  Color _badgeText(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return const Color(0xFF065F46);
      case AttendanceStatus.absent:
        return const Color(0xFFB91C1C);
      case AttendanceStatus.leave:
        return const Color(0xFF92400E);
      case AttendanceStatus.none:
        return const Color(0xFF334155);
    }
  }

  Color? _badgeBorder(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return const Color(0xFF6EE7B7);
      case AttendanceStatus.absent:
        return const Color(0xFFFCA5A5);
      case AttendanceStatus.leave:
        return const Color(0xFFFCD34D);
      case AttendanceStatus.none:
        return null;
    }
  }

  List<List<int?>> _weeks() {
    final List<int?> cells = <int?>[];
    for (int i = 0; i < month.startOffset; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= month.daysCount; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final List<List<int?>> rows = <List<int?>>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }
    return rows;
  }

  Widget _dayCell(int? day, double s) {
    if (day == null) {
      return SizedBox(height: _rowHeight * s);
    }

    final AttendanceStatus status = month.statusOf(day);
    final Color border = _badgeBorder(status) ?? Colors.transparent;
    final bool hasBorder = status != AttendanceStatus.none;

    return SizedBox(
      height: _rowHeight * s,
      child: Center(
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onDayTap(day),
            child: Container(
              width: 28 * s,
              height: 28 * s,
              decoration: BoxDecoration(
                color: _badgeFill(status),
                shape: BoxShape.circle,
                border: hasBorder ? Border.all(color: border, width: 1) : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: status == AttendanceStatus.none
                      ? FontWeight.w500
                      : FontWeight.w600,
                  color: _badgeText(status),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final List<List<int?>> rows = _weeks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (final String day in _weekdays)
              Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm * s),
        for (int r = 0; r < rows.length; r++) ...<Widget>[
          if (r > 0) SizedBox(height: 6 * s),
          Row(
            children: <Widget>[
              for (final int? day in rows[r]) Expanded(child: _dayCell(day, s)),
            ],
          ),
        ],
        SizedBox(height: AppSpacing.lg * s),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
        SizedBox(height: AppSpacing.md * s),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.md * s,
          runSpacing: 6 * s,
          children: <Widget>[
            _legend('Present', AppPalette.success, s),
            _legend('Absent', AppPalette.error, s),
            _legend('Leave', AppPalette.warning, s),
          ],
        ),
      ],
    );
  }

  Widget _legend(String label, Color color, double s) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8 * s,
          height: 8 * s,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6 * s),
        Text(
          label,
          style: TextStyle(
            fontSize: 11 * s,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
