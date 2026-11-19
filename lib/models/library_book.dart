import 'package:flutter/material.dart';

/// Semantic colour family behind a library status pill.
///
/// The reference paints availability and due-date badges from four Tailwind
/// ramps; naming the family here keeps every pill on one source of truth.
enum LibraryBadgeTone { success, warning, danger, info }

/// The hand-drawn cover of a book row.
///
/// Every cover in the reference is composed from a gradient, a small publisher
/// tag, a glyph and a one-line caption. That whole treatment is data so the
/// artwork stays described in one place instead of being rebuilt per row.
@immutable
class BookCover {
  const BookCover({
    required this.tag,
    required this.glyph,
    required this.label,
    required this.footer,
    required this.start,
    required this.end,
    this.mid,
  });

  /// Small uppercase chip on the top-left, e.g. "CDC NEB" or "SCI-101".
  final String tag;

  /// Center glyph, e.g. a flask for the science lab manual.
  final IconData glyph;

  /// Caption under the glyph — only the issued covers show one.
  final String label;

  /// Bottom caption, e.g. "COMPULSORY" or "PHYSICS".
  final String footer;

  /// Gradient stops, sampled from the reference's cover artwork.
  final Color start;
  final Color? mid;
  final Color end;
}

/// A title the student currently has issued.
@immutable
class IssuedBook {
  const IssuedBook({
    required this.title,
    required this.author,
    required this.issuedDate,
    required this.dueDate,
    required this.statusText,
    required this.statusTone,
    required this.renewalsLeft,
    required this.renewalsTotal,
    required this.cover,
  });

  final String title;

  /// Issuing body or author, shown beneath the title in the detail sheet.
  final String author;

  /// Nepali calendar date strings, e.g. "2083-06-10".
  final String issuedDate;
  final String dueDate;

  /// Due-date caption, e.g. "Due in 5 days" or "Overdue 7 days".
  final String statusText;
  final LibraryBadgeTone statusTone;

  /// Renewal allowance still available, e.g. 1 of 2.
  final int renewalsLeft;
  final int renewalsTotal;

  final BookCover cover;
}

/// A title in the searchable library catalogue.
@immutable
class CatalogBook {
  const CatalogBook({
    required this.title,
    required this.author,
    required this.rack,
    required this.statusText,
    required this.statusTone,
    required this.category,
    required this.cover,
  });

  final String title;
  final String author;

  /// Shelf location, e.g. "Rack A-12".
  final String rack;

  /// Availability caption, e.g. "Available (4)" or "Reserved (1 left)".
  final String statusText;
  final LibraryBadgeTone statusTone;

  /// Filter bucket the chip row matches against: Math, Science, Literature…
  final String category;

  final BookCover cover;
}

/// Chip buckets across the top of the catalogue, "All" first as in the mock.
const List<String> kLibraryCategories = <String>[
  'All',
  'Math',
  'Science',
  'Literature',
  'Social',
  'Nepali',
];

/// Student identity shown on the options sheet.
const String kLibraryStudentId = 'STU-2083-0156';

/// Accession number the reference prints for every issued copy.
const String kLibraryAccession = 'LIB-2083-9942';

/// Fine notice under the borrowed list.
const String kLibraryFineNotice =
    'Overdue fines accrue at Rs. 5 / day. Please renew before the due date '
    'at the library desk or via online request.';

/// Quota the summary card counts against.
const int kBorrowQuota = 4;

/// Titles currently on loan, in the order the reference lists them.
const List<IssuedBook> kIssuedBooks = <IssuedBook>[
  IssuedBook(
    title: 'Mathematics Grade 10',
    author: 'Grade 10 Textbook Board',
    issuedDate: '2083-06-10',
    dueDate: '2083-09-10',
    statusText: 'Due in 5 days',
    statusTone: LibraryBadgeTone.success,
    renewalsLeft: 1,
    renewalsTotal: 2,
    cover: BookCover(
      tag: 'CDC NEB',
      glyph: Icons.category_outlined,
      label: 'MATH 10',
      footer: 'COMPULSORY',
      start: Color(0xFFD97706),
      mid: Color(0xFFF97316),
      end: Color(0xFFB45309),
    ),
  ),
  IssuedBook(
    title: 'Science Practical Book',
    author: 'Dr. K. Sharma & Laboratory Council',
    issuedDate: '2083-06-01',
    dueDate: '2083-09-01',
    statusText: 'Overdue 7 days',
    statusTone: LibraryBadgeTone.danger,
    renewalsLeft: 0,
    renewalsTotal: 2,
    cover: BookCover(
      tag: 'LAB MANUAL',
      glyph: Icons.science_outlined,
      label: 'SCIENCE LAB',
      footer: 'SEC. PRACTICAL',
      start: Color(0xFF047857),
      mid: Color(0xFF0D9488),
      end: Color(0xFF155E75),
    ),
  ),
  IssuedBook(
    title: 'English Literature',
    author: 'Oxford Publications Board',
    issuedDate: '2083-07-12',
    dueDate: '2083-10-12',
    statusText: 'Due in 20 days',
    statusTone: LibraryBadgeTone.info,
    renewalsLeft: 2,
    renewalsTotal: 2,
    cover: BookCover(
      tag: 'READER',
      glyph: Icons.auto_stories_outlined,
      label: 'ENGLISH',
      footer: 'POETRY & PROSE',
      start: Color(0xFF312E81),
      mid: Color(0xFF1E3A8A),
      end: Color(0xFF0F172A),
    ),
  ),
];

/// The full catalogue the "All Books" tab searches and filters.
const List<CatalogBook> kCatalogBooks = <CatalogBook>[
  CatalogBook(
    title: 'Physics Fundamentals Vol 1',
    author: 'H. C. Verma',
    rack: 'Rack A-12',
    statusText: 'Available (4)',
    statusTone: LibraryBadgeTone.success,
    category: 'Science',
    cover: BookCover(
      tag: 'SCI-101',
      glyph: Icons.blur_on,
      label: '',
      footer: 'PHYSICS',
      start: Color(0xFF5B21B6),
      end: Color(0xFF9333EA),
    ),
  ),
  CatalogBook(
    title: 'Advanced Coordinate Geometry',
    author: 'S. L. Loney',
    rack: 'Rack B-04',
    statusText: 'Reserved (1 left)',
    statusTone: LibraryBadgeTone.warning,
    category: 'Math',
    cover: BookCover(
      tag: 'MTH-204',
      glyph: Icons.architecture_outlined,
      label: '',
      footer: 'GEOMETRY',
      start: Color(0xFFBE123C),
      end: Color(0xFFDB2777),
    ),
  ),
  CatalogBook(
    title: 'Shakespeare: Selected Plays',
    author: 'William Shakespeare',
    rack: 'Rack C-01',
    statusText: 'Available (3)',
    statusTone: LibraryBadgeTone.success,
    category: 'Literature',
    cover: BookCover(
      tag: 'LIT-089',
      glyph: Icons.theater_comedy_outlined,
      label: '',
      footer: 'DRAMA',
      start: Color(0xFF075985),
      end: Color(0xFF312E81),
    ),
  ),
];
