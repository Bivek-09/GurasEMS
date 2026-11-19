import 'package:flutter/material.dart';

/// One period (lesson slot) in a day's timetable.
///
/// The reference paints a coloured dot per subject; the wash is stored here as
/// part of the data because the same subject can take a different tint from one
/// day to the next (green Mathematics on Monday, cyan on Wednesday).
@immutable
class TimetablePeriod {
  const TimetablePeriod({
    required this.subject,
    required this.timeLabel,
    required this.room,
    required this.teacher,
    required this.topic,
    required this.dotColor,
  });

  /// "Mathematics".
  final String subject;

  /// Compact range the row shows, e.g. "09:00 - 09:45".
  final String timeLabel;

  /// "Room 101".
  final String room;

  /// "Mr. Ramesh Karki".
  final String teacher;

  /// "Algebra & Quadratic Equations".
  final String topic;

  /// Accent dot beside the subject on the week card.
  final Color dotColor;
}

/// One weekday column in the week view.
@immutable
class TimetableDay {
  const TimetableDay({
    required this.weekday,
    required this.dayNumber,
    required this.periods,
    this.isToday = false,
  });

  /// "Mon".
  final String weekday;

  /// Big day-of-month number, e.g. 15.
  final int dayNumber;

  final List<TimetablePeriod> periods;

  /// Marks the current day: crimson number, accent border and pulse dot.
  final bool isToday;
}

// ── Subject dot colours (reference palette) ────────────────────────────────
const Color kDotGreen = Color(0xFF10B981);
const Color kDotRed = Color(0xFFEF4444);
const Color kDotPurple = Color(0xFF8B5CF6);
const Color kDotBlue = Color(0xFF3B82F6);
const Color kDotAmber = Color(0xFFF59E0B);
const Color kDotCyan = Color(0xFF06B6D4);
const Color kDotOrange = Color(0xFFF97316);
const Color kDotPink = Color(0xFFEC4899);
const Color kDotYellow = Color(0xFFEAB308);

/// Month / term labels above and beside the schedule.
const String kTimetableMonth = 'Ashoj 2083 (BS)';
const String kTimetableTerm = 'Term II';
const String kTimetableTodayLabel = 'Today: Mon 15';

/// The full working week the reference lays out.
const List<TimetableDay> kTimetableDays = <TimetableDay>[
  TimetableDay(
    weekday: 'Mon',
    dayNumber: 15,
    isToday: true,
    periods: <TimetablePeriod>[
      TimetablePeriod(
        subject: 'Mathematics',
        timeLabel: '09:00 - 09:45',
        room: 'Room 101',
        teacher: 'Mr. Ramesh Karki',
        topic: 'Algebra & Quadratic Equations',
        dotColor: kDotGreen,
      ),
      TimetablePeriod(
        subject: 'Science',
        timeLabel: '09:45 - 10:30',
        room: 'Lab 1',
        teacher: 'Dr. Anita Joshi',
        topic: 'Optics & Light Reflection',
        dotColor: kDotRed,
      ),
      TimetablePeriod(
        subject: 'English',
        timeLabel: '10:45 - 11:30',
        room: 'Room 103',
        teacher: 'Ms. Sarita Thapa',
        topic: 'Poetry Comprehension & Grammar',
        dotColor: kDotPurple,
      ),
    ],
  ),
  TimetableDay(
    weekday: 'Tue',
    dayNumber: 16,
    periods: <TimetablePeriod>[
      TimetablePeriod(
        subject: 'Social Studies',
        timeLabel: '09:00 - 09:45',
        room: 'Room 202',
        teacher: 'Mr. Birendra Shrestha',
        topic: 'Our Traditions and Civic Duties',
        dotColor: kDotBlue,
      ),
      TimetablePeriod(
        subject: 'Computer',
        timeLabel: '10:00 - 10:45',
        room: 'Computer Lab A',
        teacher: 'Er. Sandeep Giri',
        topic: 'Introduction to Python & Logic Loops',
        dotColor: kDotAmber,
      ),
      TimetablePeriod(
        subject: 'Nepali',
        timeLabel: '11:00 - 11:45',
        room: 'Room 101',
        teacher: 'Mrs. Devi Gurung',
        topic: 'Nepali Byakaran & Rachana',
        dotColor: kDotRed,
      ),
    ],
  ),
  TimetableDay(
    weekday: 'Wed',
    dayNumber: 17,
    periods: <TimetablePeriod>[
      TimetablePeriod(
        subject: 'Mathematics',
        timeLabel: '09:00 - 09:45',
        room: 'Room 101',
        teacher: 'Mr. Ramesh Karki',
        topic: 'Geometry: Coordinate Plane',
        dotColor: kDotCyan,
      ),
      TimetablePeriod(
        subject: 'Science',
        timeLabel: '09:45 - 10:30',
        room: 'Lab 2',
        teacher: 'Dr. Anita Joshi',
        topic: 'Chemistry: Periodic Trends',
        dotColor: kDotOrange,
      ),
    ],
  ),
  TimetableDay(
    weekday: 'Thu',
    dayNumber: 18,
    periods: <TimetablePeriod>[
      TimetablePeriod(
        subject: 'English',
        timeLabel: '09:00 - 09:45',
        room: 'Room 103',
        teacher: 'Ms. Sarita Thapa',
        topic: 'Essay Writing & Expression',
        dotColor: kDotPurple,
      ),
      TimetablePeriod(
        subject: 'Accountancy',
        timeLabel: '10:00 - 10:45',
        room: 'Room 104',
        teacher: 'Mr. Madhav Pant',
        topic: 'Ledger & Journal Entries',
        dotColor: kDotGreen,
      ),
    ],
  ),
  TimetableDay(
    weekday: 'Fri',
    dayNumber: 19,
    periods: <TimetablePeriod>[
      TimetablePeriod(
        subject: 'Physical Training',
        timeLabel: '09:00 - 09:45',
        room: 'Main Ground',
        teacher: 'Coach Bikash Rai',
        topic: 'Track & Field Training',
        dotColor: kDotPink,
      ),
      TimetablePeriod(
        subject: 'Art & Craft',
        timeLabel: '10:00 - 10:45',
        room: 'Creative Studio',
        teacher: 'Ms. Pratima Karki',
        topic: 'Sketching & Traditional Mask Making',
        dotColor: kDotYellow,
      ),
    ],
  ),
];

// ── Month view ─────────────────────────────────────────────────────────────

const String kCalendarTitle = 'Ashoj 2083 Calendar Overview';
const int kTeachingDays = 26;
const String kCalendarHint = 'Tap any active day to view schedule details.';
const String kAssessmentTitle = 'Monthly Assessment Notice';
const String kAssessmentBody =
    'Terminal periodic tests commence on Ashoj 28. Review classes scheduled '
    'every Thursday.';

/// Meaning of one square in the month grid.
enum CalendarCellKind { previous, teaching, holiday, today }

/// A single date square in the compact month grid.
@immutable
class CalendarCell {
  const CalendarCell(this.label, this.kind);

  final String label;
  final CalendarCellKind kind;
}

/// The 28 cells of the Ashoj grid: two trailing dates from the previous month
/// followed by the 1st–26th, with Saturdays as holidays and the 15th current.
const List<CalendarCell> kCalendarCells = <CalendarCell>[
  CalendarCell('29', CalendarCellKind.previous),
  CalendarCell('30', CalendarCellKind.previous),
  CalendarCell('1', CalendarCellKind.teaching),
  CalendarCell('2', CalendarCellKind.teaching),
  CalendarCell('3', CalendarCellKind.teaching),
  CalendarCell('4', CalendarCellKind.teaching),
  CalendarCell('5', CalendarCellKind.holiday),
  CalendarCell('6', CalendarCellKind.teaching),
  CalendarCell('7', CalendarCellKind.teaching),
  CalendarCell('8', CalendarCellKind.teaching),
  CalendarCell('9', CalendarCellKind.teaching),
  CalendarCell('10', CalendarCellKind.teaching),
  CalendarCell('11', CalendarCellKind.teaching),
  CalendarCell('12', CalendarCellKind.holiday),
  CalendarCell('13', CalendarCellKind.teaching),
  CalendarCell('14', CalendarCellKind.teaching),
  CalendarCell('15', CalendarCellKind.today),
  CalendarCell('16', CalendarCellKind.teaching),
  CalendarCell('17', CalendarCellKind.teaching),
  CalendarCell('18', CalendarCellKind.teaching),
  CalendarCell('19', CalendarCellKind.holiday),
  CalendarCell('20', CalendarCellKind.teaching),
  CalendarCell('21', CalendarCellKind.teaching),
  CalendarCell('22', CalendarCellKind.teaching),
  CalendarCell('23', CalendarCellKind.teaching),
  CalendarCell('24', CalendarCellKind.teaching),
  CalendarCell('25', CalendarCellKind.teaching),
  CalendarCell('26', CalendarCellKind.holiday),
];
