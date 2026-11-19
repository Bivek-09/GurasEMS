import 'package:flutter/material.dart';

/// Completion state of one unit of the enrolled curriculum.
enum SyllabusStatus { completed, ongoing, pending }

extension SyllabusStatusX on SyllabusStatus {
  /// Short badge label shown against a syllabus unit.
  String get label => switch (this) {
    SyllabusStatus.completed => 'Completed',
    SyllabusStatus.ongoing => 'Ongoing',
    SyllabusStatus.pending => 'Pending',
  };
}

/// One chapter / unit inside a subject's Term II syllabus.
@immutable
class SyllabusUnit {
  const SyllabusUnit(this.title, this.status);

  final String title;
  final SyllabusStatus status;
}

/// A labelled detail tile shown beneath a subject's progress bar.
@immutable
class SubjectMeta {
  const SubjectMeta(this.label, this.value);

  final String label;
  final String value;
}

/// One subject in the student's enrolled curriculum.
///
/// Carries everything the accordion card and its syllabus sheet need: the
/// attendance and coverage percentages, the accent pair used by the icon and
/// the syllabus action, the two meta tiles and the ordered unit list.
@immutable
class AcademicSubject {
  const AcademicSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.faculty,
    required this.email,
    required this.attendancePercent,
    required this.progressPercent,
    required this.icon,
    required this.tint,
    required this.tintBackground,
    required this.meta,
    required this.actionLabel,
    required this.units,
  });

  /// Stable key used by the accordion's expansion set.
  final String id;

  final String name;

  /// Short subject code, e.g. "MTH-101".
  final String code;
  final String faculty;
  final String email;

  final int attendancePercent;

  /// Term II syllabus coverage, 0–100.
  final int progressPercent;

  final IconData icon;

  /// Accent used for the icon glyph and the syllabus action copy.
  final Color tint;

  /// Soft wash behind the icon and the syllabus action.
  final Color tintBackground;

  /// Exactly two tiles: weekly load and the subject-specific second tile.
  final List<SubjectMeta> meta;

  /// Label of the primary action inside the expanded accordion.
  final String actionLabel;

  final List<SyllabusUnit> units;
}

/// A teacher responsible for one or more subjects.
@immutable
class FacultyMember {
  const FacultyMember({
    required this.name,
    required this.role,
    required this.email,
    required this.room,
  });

  final String name;

  /// Subject (and, for the mentor, the additional leadership note).
  final String role;
  final String email;
  final String room;
}

/// One row of the interim mark sheet.
@immutable
class MarkSheetRow {
  const MarkSheetRow({
    required this.subject,
    required this.grade,
    required this.score,
  });

  final String subject;
  final String grade;
  final int score;
}

/// One published result on the academic history timeline.
@immutable
class AcademicTermRecord {
  const AcademicTermRecord({
    required this.title,
    required this.subtitle,
    required this.gpa,
    required this.badge,
    required this.published,
    required this.highlight,
  });

  final String title;
  final String subtitle;

  /// Cumulative GPA for the term, e.g. "3.60 GPA".
  final String gpa;

  /// Secondary status line, e.g. "86.5% • Verified".
  final String badge;

  /// Publication line used by the mark sheet sheet.
  final String published;

  /// Whether the timeline dot is filled maroon (current) or neutral (past).
  final bool highlight;
}

/// One sitting in the Term II examination routine.
@immutable
class ExamRoutineEntry {
  const ExamRoutineEntry({
    required this.day,
    required this.subject,
    required this.time,
    required this.room,
  });

  final String day;
  final String subject;
  final String time;
  final String room;
}

/// Headline figures on the student's academic summary card.
///
/// Shared so the card cannot drift from the rest of the app; the identity
/// (name, class, register number) comes from `StudentProfile`.
abstract final class AcademicSummary {
  static const String rollNumber = '14';
  static const String cumulativeGpa = '3.65';
  static const String gpaRemark = 'Distinction';
  static const String academicYear = '2083/84 BS';
  static const String currentTerm = 'Term II';
  static const String classRank = 'Top 5%';
}

// ─────────────────────────────────────────────────────────────────────────
// Sample data — replaced by the academic service once it is wired in.
// ─────────────────────────────────────────────────────────────────────────

// Accent pairs sampled from the reference's subject palette.
const Color _mathTint = Color(0xFF7D1128);
const Color _mathWash = Color(0xFFFDF2F4);
const Color _sciTint = Color(0xFF1D4ED8);
const Color _sciWash = Color(0xFFEFF6FF);
const Color _engTint = Color(0xFF7E22CE);
const Color _engWash = Color(0xFFFAF5FF);
const Color _nepTint = Color(0xFF0F766E);
const Color _nepWash = Color(0xFFF0FDFA);
const Color _socTint = Color(0xFF4338CA);
const Color _socWash = Color(0xFFEEF2FF);
const Color _comTint = Color(0xFFB45309);
const Color _comWash = Color(0xFFFFFBEB);

/// The six enrolled subjects, in the order the reference presents them.
const List<AcademicSubject> kAcademicSubjects = <AcademicSubject>[
  AcademicSubject(
    id: 'mth',
    name: 'Compulsory Mathematics',
    code: 'MTH-101',
    faculty: 'Mr. Ramesh Adhikari',
    email: 'ramesh.adhikari@guras.edu.np',
    attendancePercent: 94,
    progressPercent: 78,
    icon: Icons.calculate_outlined,
    tint: _mathTint,
    tintBackground: _mathWash,
    meta: <SubjectMeta>[
      SubjectMeta('Weekly Periods', '6 Hours / Week'),
      SubjectMeta('Classroom', 'Room 101 (Main Block)'),
    ],
    actionLabel: 'View Syllabus & Notes',
    units: <SyllabusUnit>[
      SyllabusUnit('Sets & Real Numbers', SyllabusStatus.completed),
      SyllabusUnit('Arithmetic: Compound Interest', SyllabusStatus.completed),
      SyllabusUnit('Algebra: Quadratic Equations', SyllabusStatus.completed),
      SyllabusUnit('Geometry: Circle Theorems', SyllabusStatus.ongoing),
      SyllabusUnit('Trigonometry: Heights & Distances', SyllabusStatus.pending),
    ],
  ),
  AcademicSubject(
    id: 'sci',
    name: 'Science & Technology',
    code: 'SCI-102',
    faculty: 'Dr. Anita Sharma',
    email: 'anita.sharma@guras.edu.np',
    attendancePercent: 92,
    progressPercent: 65,
    icon: Icons.science_outlined,
    tint: _sciTint,
    tintBackground: _sciWash,
    meta: <SubjectMeta>[
      SubjectMeta('Weekly Periods', '5 Hours (Inc. Lab)'),
      SubjectMeta('Practical Lab', 'Science Lab 2'),
    ],
    actionLabel: 'View Syllabus & Lab Book',
    units: <SyllabusUnit>[
      SyllabusUnit('Force & Motion', SyllabusStatus.completed),
      SyllabusUnit('Chemical Reactions & Equations', SyllabusStatus.completed),
      SyllabusUnit('Metals & Non-metals', SyllabusStatus.completed),
      SyllabusUnit('Life Processes & Nervous System', SyllabusStatus.ongoing),
      SyllabusUnit('Optics & Electricity', SyllabusStatus.pending),
    ],
  ),
  AcademicSubject(
    id: 'eng',
    name: 'English Literature',
    code: 'ENG-103',
    faculty: 'Mrs. Sunita Thapa',
    email: 'sunita.thapa@guras.edu.np',
    attendancePercent: 96,
    progressPercent: 82,
    icon: Icons.menu_book_outlined,
    tint: _engTint,
    tintBackground: _engWash,
    meta: <SubjectMeta>[
      SubjectMeta('Weekly Periods', '5 Hours / Week'),
      SubjectMeta('Grammar & Prose', 'Unit 7 Completed'),
    ],
    actionLabel: 'View Syllabus & Novels',
    units: <SyllabusUnit>[
      SyllabusUnit(
        'Units 1-4: Reading Comprehension',
        SyllabusStatus.completed,
      ),
      SyllabusUnit(
        'Poetry: The Road Not Taken & Sonnets',
        SyllabusStatus.completed,
      ),
      SyllabusUnit('Essay & Formal Correspondence', SyllabusStatus.completed),
      SyllabusUnit(
        'Drama: The Merchant of Venice Act II',
        SyllabusStatus.ongoing,
      ),
      SyllabusUnit('Creative Writing & Reviews', SyllabusStatus.pending),
    ],
  ),
  AcademicSubject(
    id: 'nep',
    name: 'Nepali (नेपाली)',
    code: 'NEP-104',
    faculty: 'Mr. Krishna Sharma',
    email: 'krishna.sharma@guras.edu.np',
    attendancePercent: 95,
    progressPercent: 90,
    icon: Icons.auto_stories_outlined,
    tint: _nepTint,
    tintBackground: _nepWash,
    meta: <SubjectMeta>[
      SubjectMeta('Weekly Periods', '5 Hours / Week'),
      SubjectMeta('Vyakarana & Sahitya', 'Unit 9 Finished'),
    ],
    actionLabel: 'View Syllabus & Sahitya',
    units: <SyllabusUnit>[
      SyllabusUnit('कथा: उज्यालो यात्रा', SyllabusStatus.completed),
      SyllabusUnit('व्याकरण: समास र पदवर्ग', SyllabusStatus.completed),
      SyllabusUnit('निबन्ध लेखन तथा संक्षेपिकरण', SyllabusStatus.completed),
      SyllabusUnit('नाटक: अन्धवेग', SyllabusStatus.ongoing),
      SyllabusUnit('काव्य खण्ड', SyllabusStatus.pending),
    ],
  ),
  AcademicSubject(
    id: 'soc',
    name: 'Social Studies',
    code: 'SOC-105',
    faculty: 'Mr. Hari Shrestha',
    email: 'hari.shrestha@guras.edu.np',
    attendancePercent: 91,
    progressPercent: 70,
    icon: Icons.public_outlined,
    tint: _socTint,
    tintBackground: _socWash,
    meta: <SubjectMeta>[
      SubjectMeta('Weekly Periods', '4 Hours / Week'),
      SubjectMeta('Current Theme', 'Nepalese Heritage & Demography'),
    ],
    actionLabel: 'View Syllabus & Case Studies',
    units: <SyllabusUnit>[
      SyllabusUnit('Our Tradition & Social Values', SyllabusStatus.completed),
      SyllabusUnit('Constitution & Federalism', SyllabusStatus.completed),
      SyllabusUnit('Economic Planning & Resources', SyllabusStatus.completed),
      SyllabusUnit(
        'Contemporary International Affairs',
        SyllabusStatus.ongoing,
      ),
      SyllabusUnit('Disaster Management & Map Work', SyllabusStatus.pending),
    ],
  ),
  AcademicSubject(
    id: 'com',
    name: 'Computer Science',
    code: 'COM-106',
    faculty: 'Er. Bibek KC',
    email: 'bibek.kc@guras.edu.np',
    attendancePercent: 98,
    progressPercent: 88,
    icon: Icons.computer_outlined,
    tint: _comTint,
    tintBackground: _comWash,
    meta: <SubjectMeta>[
      SubjectMeta('Coding Practical', 'C-Programming & HTML'),
      SubjectMeta('Lab Allocation', 'Lab 1 (Desktop #14)'),
    ],
    actionLabel: 'View Lab Exercises & Tasks',
    units: <SyllabusUnit>[
      SyllabusUnit('Networking & Internet Concepts', SyllabusStatus.completed),
      SyllabusUnit('HTML5 & CSS Responsive Web', SyllabusStatus.completed),
      SyllabusUnit('Structured Programming in C', SyllabusStatus.completed),
      SyllabusUnit('Array and Pointers in C', SyllabusStatus.ongoing),
      SyllabusUnit('Cyber Security & Digital Ethics', SyllabusStatus.pending),
    ],
  ),
];

/// The class teacher / mentor shown at the top of the Faculty tab.
const FacultyMember kFacultyMentor = FacultyMember(
  name: 'Mr. Ramesh Adhikari',
  role: 'Head of Mathematics • Grade 10-A Mentor',
  email: 'ramesh.adhikari@guras.edu.np',
  room: 'Room 101',
);

/// The five subject teachers shown beneath the mentor.
const List<FacultyMember> kFacultyTeachers = <FacultyMember>[
  FacultyMember(
    name: 'Dr. Anita Sharma',
    role: 'Science & Technology',
    email: 'anita.sharma@guras.edu.np',
    room: 'Room 102',
  ),
  FacultyMember(
    name: 'Mrs. Sunita Thapa',
    role: 'English Literature & Composition',
    email: 'sunita.thapa@guras.edu.np',
    room: 'Room 104',
  ),
  FacultyMember(
    name: 'Er. Bibek KC',
    role: 'Computer Science & Lab Instructor',
    email: 'bibek.kc@guras.edu.np',
    room: 'Comp Lab 1',
  ),
  FacultyMember(
    name: 'Mr. Krishna Sharma',
    role: 'Nepali Sahitya & Grammar',
    email: 'krishna.sharma@guras.edu.np',
    room: 'Room 103',
  ),
  FacultyMember(
    name: 'Mr. Hari Shrestha',
    role: 'Social Studies & Current Affairs',
    email: 'hari.shrestha@guras.edu.np',
    room: 'Room 105',
  ),
];

/// The published results shown as a timeline on the History tab, newest first.
const List<AcademicTermRecord> kAcademicHistory = <AcademicTermRecord>[
  AcademicTermRecord(
    title: 'First Terminal Exam (2083 BS)',
    subtitle: 'Published: Ashoj 2083',
    gpa: '3.60 GPA',
    badge: '86.5% • Verified',
    published: 'Ashoj 2083',
    highlight: true,
  ),
  AcademicTermRecord(
    title: 'Grade 9 - Final Board Exam',
    subtitle: 'Academic Year 2082/83',
    gpa: '3.55 GPA',
    badge: 'Passed • Div I',
    published: 'Chaitra 2082',
    highlight: false,
  ),
];

/// Interim Term II mark sheet rows, in curriculum order.
const List<MarkSheetRow> kMarkSheetRows = <MarkSheetRow>[
  MarkSheetRow(subject: 'Compulsory Mathematics', grade: 'A+', score: 92),
  MarkSheetRow(subject: 'Science & Technology', grade: 'A', score: 85),
  MarkSheetRow(subject: 'English Literature', grade: 'A+', score: 94),
  MarkSheetRow(subject: 'Nepali (नेपाली)', grade: 'A', score: 88),
  MarkSheetRow(subject: 'Social Studies', grade: 'A', score: 82),
  MarkSheetRow(subject: 'Computer Science', grade: 'A+', score: 96),
];

/// Term II examination routine.
const List<ExamRoutineEntry> kExamRoutine = <ExamRoutineEntry>[
  ExamRoutineEntry(
    day: 'Day 1 • Mangsir 28',
    subject: 'Compulsory Mathematics',
    time: '10:00 AM - 01:00 PM',
    room: 'Room 101',
  ),
  ExamRoutineEntry(
    day: 'Day 2 • Poush 01',
    subject: 'Science & Technology',
    time: '10:00 AM - 01:00 PM',
    room: 'Lab Hall A',
  ),
  ExamRoutineEntry(
    day: 'Day 3 • Poush 03',
    subject: 'English Literature',
    time: '10:00 AM - 01:00 PM',
    room: 'Room 104',
  ),
  ExamRoutineEntry(
    day: 'Day 4 • Poush 05',
    subject: 'Nepali',
    time: '10:00 AM - 01:00 PM',
    room: 'Room 103',
  ),
  ExamRoutineEntry(
    day: 'Day 5 • Poush 07',
    subject: 'Computer Science (Theory + Lab)',
    time: '10:00 AM - 01:00 PM',
    room: 'Comp Lab 1',
  ),
];
