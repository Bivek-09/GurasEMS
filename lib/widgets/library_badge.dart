import 'package:flutter/material.dart';

import '../models/library_book.dart';

/// Foreground / background pair behind one [LibraryBadgeTone].
///
/// Kept as a plain function so the badge and any future caller resolve a tone
/// the same way.
({Color foreground, Color background}) libraryToneColors(
  LibraryBadgeTone tone,
) {
  return switch (tone) {
    LibraryBadgeTone.success => (
      foreground: const Color(0xFF10B981),
      background: const Color(0xFFE6F9F0),
    ),
    LibraryBadgeTone.warning => (
      foreground: const Color(0xFFD97706),
      background: const Color(0xFFFFFBEB),
    ),
    LibraryBadgeTone.danger => (
      foreground: const Color(0xFFEF4444),
      background: const Color(0xFFFEE2E2),
    ),
    LibraryBadgeTone.info => (
      foreground: const Color(0xFF0284C7),
      background: const Color(0xFFE0F2FE),
    ),
  };
}

/// Rounded status pill used for due dates and catalogue availability.
class LibraryBadge extends StatelessWidget {
  const LibraryBadge({
    super.key,
    required this.text,
    required this.tone,
    required this.scale,
    this.uppercase = false,
    this.bordered = false,
  });

  final String text;
  final LibraryBadgeTone tone;
  final double scale;

  /// Whether to render the label in small caps tracking.
  final bool uppercase;

  /// Adds a hairline border — used by the summary card's "1 Overdue" chip.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final ({Color foreground, Color background}) colors = libraryToneColors(
      tone,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: bordered
            ? Border.all(color: colors.foreground.withValues(alpha: 0.25))
            : null,
      ),
      child: Text(
        uppercase ? text.toUpperCase() : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5 * s,
          fontWeight: FontWeight.w700,
          letterSpacing: uppercase ? 0.5 * s : 0,
          color: colors.foreground,
        ),
      ),
    );
  }
}
