import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppShadows, AppSpacing;

/// A single lecture in today's schedule.
@immutable
class ClassSession {
  const ClassSession({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.status,
  });

  final String subject;
  final String startTime;
  final String endTime;
  final String room;
  final String status;

  /// Convenience for the single time range the card renders.
  String get timeRange => '$startTime – $endTime';
}

/// Section heading plus the class card beneath it.
class TodaysClassesSection extends StatelessWidget {
  const TodaysClassesSection({
    super.key,
    required this.sessions,
    this.onViewAll,
  });

  final List<ClassSession> sessions;

  /// Null until the full timetable screen exists.
  final VoidCallback? onViewAll;

  static const double _badgeSize = 44;
  static const double _badgeRadius = 12;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs * s),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Today's Classes",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: -0.2 * s,
                    color: AppPalette.headingText,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm * s),
              _ViewAllLink(onTap: onViewAll, scale: s),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md * s),
        for (int i = 0; i < sessions.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: AppSpacing.md * s),
          _ClassCard(session: sessions[i], scale: s),
        ],
      ],
    );
  }
}

class _ViewAllLink extends StatelessWidget {
  const _ViewAllLink({required this.onTap, required this.scale});

  final VoidCallback? onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8 * scale),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 6 * scale,
            vertical: 4 * scale,
          ),
          child: Text(
            'View All',
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: AppPalette.maroon800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.session, required this.scale});

  final ClassSession session;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: AppShadows.card(s),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: TodaysClassesSection._badgeSize * s,
            height: TodaysClassesSection._badgeSize * s,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(
                TodaysClassesSection._badgeRadius * s,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                  blurRadius: 10 * s,
                  offset: Offset(0, 3 * s),
                ),
              ],
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 21 * s,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  session.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: -0.1 * s,
                    color: AppPalette.headingText,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  '${session.timeRange} · ${session.room}',
                  // Two lines so the room number survives on a 320px screen
                  // instead of being cut mid-word.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: AppPalette.supportingText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * s),
          _StatusPill(label: session.status, scale: s),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: AppPalette.statusGreenBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.statusGreenBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: 0.2 * scale,
          color: AppPalette.statusGreen,
        ),
      ),
    );
  }
}
