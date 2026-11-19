import 'package:flutter/foundation.dart';

/// Attendance status for one day.
enum AttendanceStatus { none, present, absent, leave }

/// An attendance month record (Bikram Sambat).
@immutable
class AttendanceMonth {
  const AttendanceMonth({
    required this.title,
    required this.percent,
    required this.present,
    required this.absent,
    required this.leave,
    required this.total,
    required this.startOffset,
    required this.daysCount,
    this.presentDates,
    this.absentDates = const <int>{},
    this.leaveDates = const <int>{},
  });

  final String title;
  final int percent;
  final int present;
  final int absent;
  final int leave;
  final int total;

  /// Leading blanks in the grid: weekday column the 1st falls in.
  final int startOffset;
  final int daysCount;

  /// Zero-indexed set of days explicitly present. Null means "fall back to
  /// the coarse rule" the source uses for older months.
  final Set<int>? presentDates;
  final Set<int> absentDates;
  final Set<int> leaveDates;

  AttendanceStatus statusOf(int day) {
    if (absentDates.contains(day)) return AttendanceStatus.absent;
    if (leaveDates.contains(day)) return AttendanceStatus.leave;

    final Set<int>? present = presentDates;
    if (present != null) {
      return present.contains(day)
          ? AttendanceStatus.present
          : AttendanceStatus.none;
    }
    // Older months carry no explicit list; use the source's approximation.
    if (day <= this.present + 2 && day % 7 != 6) {
      return AttendanceStatus.present;
    }
    return AttendanceStatus.none;
  }
}

/// Placeholder months — replace from the attendance API when it lands.
const List<AttendanceMonth> kAttendanceMonths = <AttendanceMonth>[
  AttendanceMonth(
    title: 'Shrawan 2083 (BS)',
    percent: 95,
    present: 19,
    absent: 1,
    leave: 0,
    total: 20,
    startOffset: 1,
    daysCount: 31,
    absentDates: {14},
  ),
  AttendanceMonth(
    title: 'Bhadra 2083 (BS)',
    percent: 92,
    present: 18,
    absent: 1,
    leave: 1,
    total: 20,
    startOffset: 0,
    daysCount: 31,
    presentDates: {
      1,
      2,
      4,
      5,
      6,
      7,
      8,
      9,
      11,
      12,
      13,
      16,
      17,
      18,
      22,
      23,
      25,
      26,
    },
    absentDates: {19},
    leaveDates: {15},
  ),
  AttendanceMonth(
    title: 'Ashoj 2083 (BS)',
    percent: 89,
    present: 16,
    absent: 2,
    leave: 1,
    total: 19,
    startOffset: 3,
    daysCount: 30,
    absentDates: {8, 21},
    leaveDates: {12},
  ),
];
