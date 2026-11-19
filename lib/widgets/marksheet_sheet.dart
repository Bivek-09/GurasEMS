import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/personal_info.dart';
import '../models/result_data.dart';

/// Modal bottom sheet displaying the complete academic marksheet.
class MarksheetSheet extends StatelessWidget {
  const MarksheetSheet({
    super.key,
    this.subjects = kSubjects,
    this.termName = 'Annual Examination 2083',
    this.gpa = '3.82',
    this.percentage = '91.0%',
  });

  final List<SubjectResult> subjects;
  final String termName;
  final String gpa;
  final String percentage;

  static Future<void> show(
    BuildContext context, {
    List<SubjectResult> subjects = kSubjects,
    String termName = 'Annual Examination 2083',
    String gpa = '3.82',
    String percentage = '91.0%',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => MarksheetSheet(
        subjects: subjects,
        termName: termName,
        gpa: gpa,
        percentage: percentage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double maxH = MediaQuery.sizeOf(context).height * 0.9;

    final int totalFullMarks = subjects.fold<int>(
      0,
      (sum, s) => sum + s.fullMarks,
    );
    final int totalObtained = subjects.fold<int>(
      0,
      (sum, s) => sum + s.obtained,
    );

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Drag handle
          Padding(
            padding: EdgeInsets.only(top: 10 * s, bottom: 6 * s),
            child: Container(
              width: 36 * s,
              height: 4 * s,
              decoration: BoxDecoration(
                color: AppGray.shade300,
                borderRadius: BorderRadius.circular(2 * s),
              ),
            ),
          ),
          // Top header bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg * s,
              vertical: AppSpacing.sm * s,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8 * s),
                  decoration: BoxDecoration(
                    color: AppPalette.maroonSurface,
                    borderRadius: BorderRadius.circular(AppRadii.small * s),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: AppPalette.maroon800,
                    size: 20 * s,
                  ),
                ),
                SizedBox(width: AppSpacing.md * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Academic Grade Sheet',
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.headingText,
                        ),
                      ),
                      Text(
                        termName,
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w500,
                          color: AppPalette.supportingText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20 * s,
                    color: AppPalette.muted,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppGray.shade200),
          // Scrollable Marksheet Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Student details card
                  Container(
                    padding: EdgeInsets.all(14 * s),
                    decoration: BoxDecoration(
                      color: AppPalette.dashboardBg,
                      borderRadius: BorderRadius.circular(AppRadii.inner * s),
                      border: Border.all(color: AppGray.shade200),
                    ),
                    child: Column(
                      children: <Widget>[
                        _DetailRow(
                          label: 'Student Name',
                          value: kPlaceholderStudent.fullName,
                          scale: s,
                        ),
                        SizedBox(height: AppSpacing.sm * s),
                        _DetailRow(
                          label: 'Roll No / Class',
                          value: '18  •  Grade 10 - Section A',
                          scale: s,
                        ),
                        SizedBox(height: AppSpacing.sm * s),
                        _DetailRow(
                          label: 'Evaluation Term',
                          value: termName,
                          scale: s,
                        ),
                        SizedBox(height: AppSpacing.sm * s),
                        _DetailRow(
                          label: 'Result Status',
                          value: 'PASSED (Distinction)',
                          scale: s,
                          isAccent: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg * s),
                  // Score Highlights
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _StatBadge(
                          title: 'GPA',
                          value: gpa,
                          subtitle: 'Scale: 4.0',
                          color: AppPalette.maroon800,
                          bgColor: AppPalette.maroonSurface,
                          scale: s,
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      Expanded(
                        child: _StatBadge(
                          title: 'Percentage',
                          value: percentage,
                          subtitle: '$totalObtained / $totalFullMarks Marks',
                          color: AppPalette.blue,
                          bgColor: const Color(0xFFEFF6FF),
                          scale: s,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg * s),
                  // Detailed Subjects Table
                  Text(
                    'Subject-wise Evaluation',
                    style: TextStyle(
                      fontSize: 13.5 * s,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.headingText,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm * s),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.inner * s),
                      border: Border.all(color: AppGray.shade200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: <Widget>[
                        // Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * s,
                            vertical: 10 * s,
                          ),
                          color: AppGray.shade100,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Subject',
                                  style: TextStyle(
                                    fontSize: 11.5 * s,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.headingText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'TH',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5 * s,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.headingText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'PR',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5 * s,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.headingText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Total',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5 * s,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.headingText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Grade',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5 * s,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.headingText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Subject Rows
                        ...subjects.asMap().entries.map((entry) {
                          final int idx = entry.key;
                          final SubjectResult sub = entry.value;
                          final bool isEven = idx % 2 == 0;
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12 * s,
                              vertical: 9 * s,
                            ),
                            color: isEven ? Colors.white : AppGray.shade50,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    sub.name,
                                    style: TextStyle(
                                      fontSize: 12 * s,
                                      fontWeight: FontWeight.w600,
                                      color: AppPalette.headingText,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    sub.theoryDetail,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5 * s,
                                      color: AppPalette.supportingText,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    sub.practicalDetail,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5 * s,
                                      color: AppPalette.supportingText,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${sub.obtained}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12 * s,
                                      fontWeight: FontWeight.w700,
                                      color: AppPalette.headingText,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7 * s,
                                        vertical: 2 * s,
                                      ),
                                      decoration: BoxDecoration(
                                        color: sub.grade.startsWith('A')
                                            ? AppPalette.statusGreenBg
                                            : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.micro * s,
                                        ),
                                      ),
                                      child: Text(
                                        sub.grade,
                                        style: TextStyle(
                                          fontSize: 11 * s,
                                          fontWeight: FontWeight.w700,
                                          color: sub.grade.startsWith('A')
                                              ? AppPalette.statusGreen
                                              : AppPalette.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl * s),
                  // Actions: Print / Download
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Downloading marksheet PDF...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(Icons.download_rounded, size: 16 * s),
                          label: Text(
                            'Download PDF',
                            style: TextStyle(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md * s,
                            ),
                            side: const BorderSide(color: AppGray.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.small * s,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.check_rounded, size: 16 * s),
                          label: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppPalette.maroon800,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md * s,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.small * s,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md * s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.scale,
    this.isAccent = false,
  });

  final String label;
  final String value;
  final double scale;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w500,
            color: AppPalette.supportingText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5 * scale,
            fontWeight: isAccent ? FontWeight.w700 : FontWeight.w600,
            color: isAccent ? AppPalette.statusGreen : AppPalette.headingText,
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.scale,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.inner * scale),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: AppSpacing.xs * scale),
          Text(
            value,
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11 * scale,
              color: AppPalette.supportingText,
            ),
          ),
        ],
      ),
    );
  }
}
