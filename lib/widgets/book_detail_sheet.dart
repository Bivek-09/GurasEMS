import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../models/library_book.dart';
import 'library_badge.dart';

/// What the student asked for from the book detail sheet.
enum BookSheetAction { renew }

/// Bottom sheet with one book's cover, metadata and primary action.
///
/// Mirrors the reference's "Book Details" modal: the cover and title, a status
/// badge, the accession / date rows and the renew / done actions. The same
/// sheet serves both an issued copy and a catalogue preview — the caller only
/// swaps the two middle rows.
class BookDetailSheet extends StatelessWidget {
  const BookDetailSheet({
    super.key,
    required this.title,
    required this.author,
    required this.cover,
    required this.badgeText,
    required this.badgeTone,
    required this.firstLabel,
    required this.firstValue,
    required this.secondLabel,
    required this.secondValue,
    this.renewalsText,
    this.primaryLabel = 'Renew Borrowing',
  });

  final String title;
  final String author;
  final BookCover cover;
  final String badgeText;
  final LibraryBadgeTone badgeTone;

  /// First metadata row, e.g. "Issued On" or "Availability".
  final String firstLabel;
  final String firstValue;

  /// Second metadata row, e.g. "Due Date" or "Lending Term".
  final String secondLabel;
  final String secondValue;

  /// Renewal allowance row; hidden when null.
  final String? renewalsText;

  final String primaryLabel;

  /// Opens the sheet and resolves with the action taken, or `null` when
  /// dismissed.
  static Future<BookSheetAction?> show(
    BuildContext context, {
    required String title,
    required String author,
    required BookCover cover,
    required String badgeText,
    required LibraryBadgeTone badgeTone,
    required String firstLabel,
    required String firstValue,
    required String secondLabel,
    required String secondValue,
    String? renewalsText,
    String primaryLabel = 'Renew Borrowing',
  }) {
    return showModalBottomSheet<BookSheetAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => BookDetailSheet(
        title: title,
        author: author,
        cover: cover,
        badgeText: badgeText,
        badgeTone: badgeTone,
        firstLabel: firstLabel,
        firstValue: firstValue,
        secondLabel: secondLabel,
        secondValue: secondValue,
        renewalsText: renewalsText,
        primaryLabel: primaryLabel,
      ),
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
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 24 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 32 * s,
                height: 32 * s,
                child: Material(
                  color: const Color(0xFFF1F5F9),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close_rounded,
                      size: 17 * s,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
            _header(context, s),
            SizedBox(height: 14 * s),
            _meta(s),
            SizedBox(height: 18 * s),
            _actions(context, s),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double s) {
    final double thumbW = 64 * s;
    final double thumbH = 80 * s;

    return Column(
      children: <Widget>[
        Container(
          width: thumbW,
          height: thumbH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10 * s),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                cover.start,
                if (cover.mid != null) cover.mid!,
                cover.end,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10 * s,
                offset: Offset(0, 4 * s),
              ),
            ],
          ),
          child: Icon(
            cover.glyph,
            size: 24 * s,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
        SizedBox(height: 12 * s),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 3 * s),
        Text(
          author,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5 * s,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 10 * s),
        Center(
          child: LibraryBadge(text: badgeText, tone: badgeTone, scale: s),
        ),
      ],
    );
  }

  Widget _meta(double s) {
    return Column(
      children: <Widget>[
        _metaRow('Accession No.', kLibraryAccession, s),
        _metaRow(firstLabel, firstValue, s),
        _metaRow(secondLabel, secondValue, s),
        if (renewalsText != null)
          _metaRow('Borrow Renewals Left', renewalsText!, s, last: true),
      ],
    );
  }

  Widget _metaRow(String label, String value, double s, {bool last = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9 * s),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF8FAFC))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, double s) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 44 * s,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(BookSheetAction.renew),
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.maroon800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                ),
              ),
              child: Text(
                primaryLabel,
                style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        SizedBox(width: 8 * s),
        SizedBox(
          height: 44 * s,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF334155),
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * s),
              ),
            ),
            child: Text(
              'Done',
              style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
