import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../models/library_book.dart';

/// What the student chose from the book options sheet.
enum BookAction { renew, history, report }

/// Options sheet raised by a borrowed book's "more" button.
///
/// Mirrors the reference's action sheet: the book header with the student id,
/// then renew, history and report-damage rows and a cancel button. Resolves
/// with the chosen [BookAction], or `null` when cancelled.
class BookActionSheet extends StatelessWidget {
  const BookActionSheet({super.key, required this.title});

  final String title;

  static Future<BookAction?> show(
    BuildContext context, {
    required String title,
  }) {
    return showModalBottomSheet<BookAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => BookActionSheet(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 24 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 48 * s,
                height: 4 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 16 * s),
            Row(
              children: <Widget>[
                Container(
                  width: 40 * s,
                  height: 40 * s,
                  decoration: BoxDecoration(
                    color: AppPalette.maroonSurface,
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    size: 20 * s,
                    color: AppPalette.maroon800,
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'Student ID: $kLibraryStudentId',
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            _ActionRow(
              icon: Icons.autorenew_rounded,
              iconColor: AppPalette.maroon800,
              label: 'Renew Borrow Period (+14 days)',
              bold: true,
              scale: s,
              onTap: () => Navigator.of(context).pop(BookAction.renew),
            ),
            SizedBox(height: 8 * s),
            _ActionRow(
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF2563EB),
              label: 'View Full Book History',
              scale: s,
              onTap: () => Navigator.of(context).pop(BookAction.history),
            ),
            SizedBox(height: 8 * s),
            _ActionRow(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFEF4444),
              label: 'Report Damaged / Lost Book',
              danger: true,
              scale: s,
              onTap: () => Navigator.of(context).pop(BookAction.report),
            ),
            SizedBox(height: 16 * s),
            SizedBox(
              height: 44 * s,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF334155),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.scale,
    required this.onTap,
    this.bold = false,
    this.danger = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final double scale;
  final VoidCallback onTap;
  final bool bold;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
              color: danger ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 16 * s, color: iconColor),
              SizedBox(width: 12 * s),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                    color: danger
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(width: 8 * s),
              Icon(
                Icons.chevron_right_rounded,
                size: 16 * s,
                color: danger
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
