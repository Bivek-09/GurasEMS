import 'package:flutter/material.dart';

/// Bucket a notice belongs to.
///
/// Drives both the list's filter pills ([filterLabel]) and the detail sheet's
/// coloured badge ([badgeLabel]) — the reference calls the same bucket "Other"
/// in the tabs but "General" on the badge, so the two labels live here.
enum NoticeCategory { academic, events, other }

extension NoticeCategoryX on NoticeCategory {
  /// Label used by the list's filter pills.
  String get filterLabel => switch (this) {
    NoticeCategory.academic => 'Academic',
    NoticeCategory.events => 'Events',
    NoticeCategory.other => 'Other',
  };

  /// Label used by the detail sheet's category badge.
  String get badgeLabel => switch (this) {
    NoticeCategory.academic => 'Academic',
    NoticeCategory.events => 'Event',
    NoticeCategory.other => 'General',
  };
}

/// One entry in the notice board.
@immutable
class SchoolNotice {
  const SchoolNotice({
    required this.id,
    required this.title,
    required this.summary,
    required this.date,
    required this.category,
    required this.pinned,
    required this.publisher,
    required this.body,
    required this.attachmentName,
    required this.attachmentSize,
    required this.icon,
    required this.iconTint,
    required this.iconTintBackground,
    required this.iconBorder,
    this.detailTitle,
  });

  final int id;

  /// Title shown in the list. The detail sheet can carry a fuller version.
  final String title;
  final String? detailTitle;

  /// Two-line preview under the title.
  final String summary;

  /// Nepali calendar date, e.g. "2083-05-20".
  final String date;

  final NoticeCategory category;

  /// Pinned notices carry the maroon pin marker on the card.
  final bool pinned;

  /// Office that issued the notice, shown in the detail sheet.
  final String publisher;

  /// Detail copy. Light markup survives from the reference: `<br>` for line
  /// breaks and `<strong>…</strong>` for emphasis.
  final String body;

  final String attachmentName;
  final String attachmentSize;

  /// Per-notice glyph and its tinted badge colours.
  final IconData icon;
  final Color iconTint;
  final Color iconTintBackground;
  final Color iconBorder;

  /// Heading the detail sheet should use.
  String get displayTitle => detailTitle ?? title;
}

/// The notice board, newest first, exactly as the reference lists it.
const List<SchoolNotice> kNotices = <SchoolNotice>[
  SchoolNotice(
    id: 1,
    title: 'Dashain Holiday Notice',
    summary: 'School will remain closed from 2083-06-01 to 2083-06-15.',
    date: '2083-05-20',
    category: NoticeCategory.academic,
    pinned: true,
    publisher: "Principal's Office",
    body:
        'Dear Students & Parents, <br><br>This is to formally notify all that '
        'the school will observe the auspicious festive break on the occasion '
        'of Bijaya Dashami. All regular classes and academic activities will '
        'remain suspended from <strong>2083-06-01 to 2083-06-15</strong>.'
        '<br><br>Students are requested to complete their holiday assignments '
        'before the reopening date.',
    attachmentName: 'Dashain_Vacation_Circular_2083.pdf',
    attachmentSize: '284 KB',
    icon: Icons.beach_access_outlined,
    iconTint: Color(0xFFF97316),
    iconTintBackground: Color(0xFFFFF7ED),
    iconBorder: Color(0xFFFFEDD5),
  ),
  SchoolNotice(
    id: 2,
    title: 'Parent-Teacher Meeting',
    detailTitle: 'Parent-Teacher Meeting (PTM)',
    summary: 'PTM scheduled for Grade 10. Please attend.',
    date: '2083-05-18',
    category: NoticeCategory.academic,
    pinned: false,
    publisher: 'Grade 10 Coordinator',
    body:
        'Respectable Parents/Guardians,<br><br>The first term performance '
        'review Parent-Teacher Meeting (PTM) for <strong>Grade 10</strong> has '
        'been scheduled for Friday. Timings: 10:00 AM to 02:00 PM. Your '
        "presence is strictly mandatory to evaluate your ward's first-term "
        'marksheet and upcoming SEE preparation strategy.',
    attachmentName: 'PTM_Schedule_Slot_Details.pdf',
    attachmentSize: '196 KB',
    icon: Icons.groups_outlined,
    iconTint: Color(0xFF0EA5E9),
    iconTintBackground: Color(0xFFF0F9FF),
    iconBorder: Color(0xFFE0F2FE),
  ),
  SchoolNotice(
    id: 3,
    title: 'Exam Routine Published',
    summary: 'First terminal exam routine is now available.',
    date: '2083-05-10',
    category: NoticeCategory.academic,
    pinned: false,
    publisher: 'Examination Board',
    body:
        'The complete examination schedule for the <strong>First Terminal '
        'Examination 2083</strong> has been finalized. Written theory '
        'examinations commence from 2083-05-28. Admit cards will be issued '
        'from the finance desk once dues are cleared.',
    attachmentName: 'First_Terminal_Exam_Routine_2083.pdf',
    attachmentSize: '312 KB',
    icon: Icons.description_outlined,
    iconTint: Color(0xFFF59E0B),
    iconTintBackground: Color(0xFFFFFBEB),
    iconBorder: Color(0xFFFEF3C7),
  ),
  SchoolNotice(
    id: 4,
    title: 'Sports Week',
    detailTitle: 'Annual Sports Week 2083',
    summary: 'Annual sports week from 2083-05-25.',
    date: '2083-05-08',
    category: NoticeCategory.events,
    pinned: true,
    publisher: 'Sports Department',
    body:
        'Get ready for the annual athletic festival! The <strong>Annual Sports '
        'Week</strong> will commence from 2083-05-25 across the school sports '
        'complex. Inter-house registrations for Football, Basketball, Table '
        'Tennis, and Track events are officially open with house captains.',
    attachmentName: 'Sports_Rulebook_and_Fixtures.pdf',
    attachmentSize: '428 KB',
    icon: Icons.emoji_events_outlined,
    iconTint: Color(0xFFF43F5E),
    iconTintBackground: Color(0xFFFFF1F2),
    iconBorder: Color(0xFFFFE4E6),
  ),
  SchoolNotice(
    id: 5,
    title: 'Science Exhibition Registration',
    summary: 'Submit project abstracts to science lab by next Friday.',
    date: '2083-05-02',
    category: NoticeCategory.events,
    pinned: false,
    publisher: 'Department of Science',
    body:
        'The STEM Innovators Fair is back! Students of grades 8 through 12 can '
        'participate individually or in teams of up to 3 members. Please '
        'submit project abstracts with working model requirements to '
        'Mrs. Shrestha by this Friday.',
    attachmentName: 'Science_Fair_Guidelines.pdf',
    attachmentSize: '254 KB',
    icon: Icons.science_outlined,
    iconTint: Color(0xFF10B981),
    iconTintBackground: Color(0xFFECFDF5),
    iconBorder: Color(0xFFD1FAE5),
  ),
  SchoolNotice(
    id: 6,
    title: 'Library Book Returns',
    summary:
        'Return all issued semester reference books without penalty this week.',
    date: '2083-04-28',
    category: NoticeCategory.other,
    pinned: false,
    publisher: 'Central Library',
    body:
        'All students holding borrowed books from the reference section are '
        'requested to return or renew their library inventory before terminal '
        'exam clearance.',
    attachmentName: 'Library_Notice_Clearance.pdf',
    attachmentSize: '168 KB',
    icon: Icons.bookmark_added_outlined,
    iconTint: Color(0xFFA855F7),
    iconTintBackground: Color(0xFFFAF5FF),
    iconBorder: Color(0xFFF3E8FF),
  ),
];
