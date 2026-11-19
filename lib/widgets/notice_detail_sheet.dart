import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/school_notice.dart';
import 'app_toast.dart';

/// Bottom sheet with one notice's full text and its attachment.
///
/// Mirrors the reference's "Notice Detail" modal: a category badge and close
/// button, the title, the date/publisher meta line, the formatted body, the
/// attachment card and the acknowledge action. Downloading a document keeps the
/// sheet open and flashes a toast above it, as the reference does.
class NoticeDetailSheet extends StatelessWidget {
  const NoticeDetailSheet({super.key, required this.notice});

  final SchoolNotice notice;

  /// Opens the sheet for [notice].
  static Future<void> show(
    BuildContext context, {
    required SchoolNotice notice,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => NoticeDetailSheet(notice: notice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet * s),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.block * s,
          AppSpacing.xl * s,
          AppSpacing.block * s,
          AppSpacing.xxl * s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _CategoryBadge(category: notice.category, scale: s),
                const Spacer(),
                SizedBox(
                  width: 32 * s,
                  height: 32 * s,
                  child: Material(
                    color: AppSlate.shade100,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close_rounded,
                        size: 17 * s,
                        color: AppSlate.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md * s),
            Text(
              notice.displayTitle,
              style: TextStyle(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppPalette.headingText,
              ),
            ),
            SizedBox(height: 10 * s),
            _MetaLine(notice: notice, scale: s),
            SizedBox(height: AppSpacing.md * s),
            Divider(height: 1, thickness: 1, color: AppSlate.shade100),
            SizedBox(height: AppSpacing.md * s),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12 * s,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                  color: AppGray.shade600,
                ),
                children: _bodySpans(notice.body, s),
              ),
            ),
            SizedBox(height: AppSpacing.lg * s),
            _AttachmentCard(
              notice: notice,
              scale: s,
              onDownload: () => _flashToast(context, 'Downloading document...'),
            ),
            SizedBox(height: AppSpacing.xl * s),
            SizedBox(
              height: 46 * s,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.maroon800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.inner * s),
                  ),
                ),
                child: Text(
                  'Acknowledge & Close',
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

/// Splits the reference's light markup into styled spans:
/// `<br>` becomes a line break, `<strong>…</strong>` becomes bold copy.
List<InlineSpan> _bodySpans(String raw, double s) {
  final String text = raw.replaceAllMapped(
    RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false),
    (_) => '\n',
  );

  final RegExp bold = RegExp(
    r'<strong>(.*?)</strong>',
    caseSensitive: false,
    dotAll: true,
  );

  final List<InlineSpan> spans = <InlineSpan>[];
  int cursor = 0;
  for (final Match match in bold.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(
        TextSpan(text: _stripTags(text.substring(cursor, match.start))),
      );
    }
    spans.add(
      TextSpan(
        text: _stripTags(match.group(1) ?? ''),
        style: TextStyle(fontWeight: FontWeight.w700, color: AppGray.shade800),
      ),
    );
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: _stripTags(text.substring(cursor))));
  }
  return spans;
}

String _stripTags(String value) => value.replaceAll(RegExp(r'<[^>]*>'), '');

/// Floats a toast above the modal by inserting it into the root overlay.
void _flashToast(BuildContext context, String message) {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      return Positioned(
        top: MediaQuery.paddingOf(overlayContext).top + 72,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: Center(child: AppToast(message: message)),
        ),
      );
    },
  );
  overlay.insert(entry);
  Timer(const Duration(milliseconds: 2000), () {
    if (entry.mounted) entry.remove();
  });
}

// ─────────────────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category, required this.scale});

  final NoticeCategory category;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final (
      Color background,
      Color foreground,
      IconData icon,
    ) = switch (category) {
      NoticeCategory.academic => (
        const Color(0xFFFFFBEB),
        const Color(0xFFB45309),
        Icons.school_outlined,
      ),
      NoticeCategory.events => (
        const Color(0xFFFFF1F2),
        const Color(0xFFBE123C),
        Icons.emoji_events_outlined,
      ),
      NoticeCategory.other => (
        const Color(0xFFEFF6FF),
        const Color(0xFF1D4ED8),
        Icons.notifications_none_rounded,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12 * s, color: foreground),
          SizedBox(width: 5 * s),
          Text(
            category.badgeLabel,
            style: TextStyle(
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.notice, required this.scale});

  final SchoolNotice notice;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Wrap(
      spacing: AppSpacing.sm * s,
      runSpacing: AppSpacing.xs * s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _MetaItem(
          icon: Icons.event_available_outlined,
          text: notice.date,
          scale: s,
        ),
        Text(
          '•',
          style: TextStyle(fontSize: 11 * s, color: AppGray.shade300),
        ),
        _MetaItem(
          icon: Icons.account_balance_outlined,
          text: notice.publisher,
          scale: s,
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.text,
    required this.scale,
  });

  final IconData icon;
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13 * s, color: AppPalette.maroon800),
        SizedBox(width: 5 * s),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5 * s,
            fontWeight: FontWeight.w500,
            color: AppPalette.supportingText,
          ),
        ),
      ],
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({
    required this.notice,
    required this.scale,
    required this.onDownload,
  });

  final SchoolNotice notice;
  final double scale;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md * s),
      decoration: BoxDecoration(
        color: AppGray.shade50,
        borderRadius: BorderRadius.circular(AppRadii.inner * s),
        border: Border.all(color: AppSlate.shade100),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 22 * s,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  notice.attachmentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5 * s,
                    fontWeight: FontWeight.w600,
                    color: AppGray.shade800,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  '${notice.attachmentSize} • Download to view',
                  style: TextStyle(
                    fontSize: 9.5 * s,
                    fontWeight: FontWeight.w500,
                    color: AppGray.shade400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm * s),
          Material(
            color: AppPalette.maroonSurface,
            borderRadius: BorderRadius.circular(AppRadii.tiny * s),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onDownload,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 6 * s,
                ),
                child: Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.maroon800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
