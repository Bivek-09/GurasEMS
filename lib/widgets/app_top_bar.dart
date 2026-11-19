import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppSpacing;
import 'user_avatar.dart';

const Color _greetingRose = Color(0xFFFECDD3);

/// Maroon header that caps the student dashboard.
///
/// Owns the curved lower edge that the scrolling content rides up over, and
/// publishes that geometry through [heightOf] / [contentOverlap] so the screen
/// can layer the two without the numbers drifting apart.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.name,
    required this.grade,
    required this.section,
    this.greeting = 'Good Morning,',
    this.avatarUrl,
    this.hasUnreadNotifications = true,
    this.onNotificationsTap,
  });

  final String name;
  final String grade;
  final String section;

  /// Time-of-day greeting. Passed in rather than derived so the wording stays
  /// with the caller instead of being hardcoded in the widget.
  final String greeting;

  /// Optional avatar image. Falls back to initials when absent or unreachable.
  final String? avatarUrl;

  final bool hasUnreadNotifications;

  /// Opens the notification centre (the Notices screen). Null leaves the bell
  /// inert so it never pretends to navigate.
  final VoidCallback? onNotificationsTap;

  // ── Geometry ──────────────────────────────────────────────────────────
  static const double _topPadding = 12;
  static const double _avatarBlockMargin = 8;
  static const double _avatarSize = 48;
  static const double _bottomPadding = 64;
  static const double curveRadius = 32;

  /// Distance the scrolling content rides up over the curved edge.
  static const double contentOverlap = 40;

  /// Full height of the bar, including the status-bar inset.
  static double heightOf(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    return MediaQuery.paddingOf(context).top +
        (_topPadding + _avatarBlockMargin + _avatarSize + _bottomPadding) * s;
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double inset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.only(
        top: inset + _topPadding * s,
        bottom: _bottomPadding * s,
      ),
      decoration: const BoxDecoration(
        color: AppPalette.maroon800,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(curveRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
            ),
            child: Row(
              children: <Widget>[
                UserAvatar(
                  name: name,
                  url: avatarUrl,
                  size: _avatarSize * s,
                  borderColor: Colors.white.withValues(alpha: 0.4),
                  borderWidth: 2,
                  presenceDot: true,
                  fallbackBackground: Colors.white,
                  fallbackForeground: AppPalette.maroon800,
                ),
                SizedBox(width: 14 * s),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: _greetingRose.withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs * s),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          letterSpacing: -0.2 * s,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        '$grade · $section',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md * s),
                _NotificationBell(
                  scale: s,
                  hasUnread: hasUnreadNotifications,
                  onTap: onNotificationsTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted notification button with an unread dot.
///
/// Inert until [onTap] is supplied; the dashboard wires it to the Notices
/// screen, the notification centre of this build.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.scale,
    required this.hasUnread,
    this.onTap,
  });

  final double scale;
  final bool hasUnread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: onTap != null,
        label: 'Notifications',
        child: SizedBox(
          width: 44 * scale,
          height: 44 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8 * scale,
                      sigmaY: 8 * scale,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 20 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasUnread)
                Positioned(
                  top: 8 * scale,
                  right: 8 * scale,
                  child: Container(
                    width: 8 * scale,
                    height: 8 * scale,
                    decoration: BoxDecoration(
                      color: AppPalette.rose,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppPalette.maroon800,
                        width: 2 * scale,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
