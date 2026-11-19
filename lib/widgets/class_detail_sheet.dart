import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../models/class_schedule.dart';

/// Bottom sheet that expands one timetable period.
///
/// Mirrors the reference's "Lecture Detail" modal: a drag handle, a soft-pink
/// eyebrow, the subject and its time, then a framed list of the classroom,
/// instructor and the curriculum topic, closed by a single Dismiss action.
class PeriodDetailSheet extends StatelessWidget {
  const PeriodDetailSheet({super.key, required this.period});

  final TimetablePeriod period;

  /// Opens the sheet, dimming the screen behind it.
  static Future<void> show(
    BuildContext context, {
    required TimetablePeriod period,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (_) => PeriodDetailSheet(period: period),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double maxH = MediaQuery.sizeOf(context).height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28 * s)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24 * s, 14 * s, 24 * s, 24 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40 * s,
                height: 5 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 18 * s),
            _header(context, s),
            SizedBox(height: 20 * s),
            _details(s),
            SizedBox(height: 20 * s),
            _dismiss(context, s),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.maroonSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Lecture Detail',
                  style: TextStyle(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6 * s,
                    color: AppPalette.maroon800,
                  ),
                ),
              ),
              SizedBox(height: 8 * s),
              Text(
                period.subject,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -0.3 * s,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 3 * s),
              Text(
                period.timeLabel,
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * s),
        SizedBox(
          width: 32 * s,
          height: 32 * s,
          child: Material(
            color: const Color(0xFFF3F4F6),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close_rounded,
                size: 17 * s,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _details(double s) {
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: <Widget>[
          _row(
            icon: Icons.meeting_room_outlined,
            label: 'Classroom:',
            value: period.room,
            scale: s,
          ),
          SizedBox(height: 14 * s),
          _row(
            icon: Icons.person_outline_rounded,
            label: 'Instructor:',
            value: period.teacher,
            scale: s,
          ),
          SizedBox(height: 14 * s),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          SizedBox(height: 14 * s),
          _row(
            icon: Icons.menu_book_outlined,
            label: 'Topic:',
            value: period.topic,
            scale: s,
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
    required double scale,
  }) {
    final double s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 15 * s, color: AppPalette.maroon800),
        SizedBox(width: 8 * s),
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * s,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dismiss(BuildContext context, double s) {
    return SizedBox(
      height: 46 * s,
      child: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.maroon800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * s),
          ),
        ),
        child: Text(
          'Dismiss',
          style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
