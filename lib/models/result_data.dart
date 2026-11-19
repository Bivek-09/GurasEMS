import 'package:flutter/foundation.dart';

@immutable
class SubjectResult {
  const SubjectResult({
    required this.name,
    required this.fullMarks,
    required this.thFull,
    required this.thObtained,
    required this.prFull,
    required this.prObtained,
    required this.gp,
    required this.grade,
  });

  final String name;
  final int fullMarks;
  final int thFull;
  final int thObtained;
  final int prFull;
  final int prObtained;
  final double gp;
  final String grade;

  int get obtained => thObtained + prObtained;

  /// "62/75" — theory marks within the theory max.
  String get theoryDetail => '$thObtained/$thFull';
  String get practicalDetail => '$prObtained/$prFull';
}

@immutable
class ExamTerm {
  const ExamTerm({
    required this.name,
    required this.percentage,
    required this.gpa,
    required this.status,
  });

  final String name;
  final String percentage;
  final String gpa;
  final String status;
}

const List<SubjectResult> kSubjects = <SubjectResult>[
  SubjectResult(
    name: 'English',
    fullMarks: 100,
    thFull: 75,
    thObtained: 62,
    prFull: 25,
    prObtained: 24,
    gp: 3.6,
    grade: 'A',
  ),
  SubjectResult(
    name: 'Mathematics',
    fullMarks: 100,
    thFull: 75,
    thObtained: 68,
    prFull: 25,
    prObtained: 23,
    gp: 4.0,
    grade: 'A+',
  ),
  SubjectResult(
    name: 'Science',
    fullMarks: 100,
    thFull: 75,
    thObtained: 61,
    prFull: 25,
    prObtained: 24,
    gp: 3.6,
    grade: 'A',
  ),
  SubjectResult(
    name: 'Social Studies',
    fullMarks: 100,
    thFull: 75,
    thObtained: 58,
    prFull: 25,
    prObtained: 22,
    gp: 3.2,
    grade: 'B+',
  ),
  SubjectResult(
    name: 'Nepali',
    fullMarks: 100,
    thFull: 75,
    thObtained: 65,
    prFull: 25,
    prObtained: 23,
    gp: 3.6,
    grade: 'A',
  ),
  SubjectResult(
    name: 'Computer',
    fullMarks: 100,
    thFull: 50,
    thObtained: 44,
    prFull: 50,
    prObtained: 48,
    gp: 4.0,
    grade: 'A+',
  ),
];

const List<ExamTerm> kTerms = <ExamTerm>[
  ExamTerm(
    name: 'First Terminal Exam',
    percentage: '86.5%',
    gpa: '3.6',
    status: 'Completed',
  ),
  ExamTerm(
    name: 'Second Terminal Exam',
    percentage: '89.2%',
    gpa: '3.75',
    status: 'Completed',
  ),
  ExamTerm(
    name: 'Annual Examination 2083',
    percentage: '91.0%',
    gpa: '3.82',
    status: 'Published',
  ),
];
