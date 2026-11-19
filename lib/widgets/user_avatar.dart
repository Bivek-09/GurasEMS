import 'package:flutter/material.dart';

import '../core/app_palette.dart';

/// Circular user photo with an initials fallback.
///
/// Extracted so the dashboard header and the profile screen cannot drift apart.
/// Falls back to initials whenever the photo is missing or fails to load, so a
/// network failure never leaves an empty circle.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.url,
    required this.size,
    this.borderColor,
    this.borderWidth = 2,
    this.presenceDot = false,
    this.fallbackBackground,
    this.fallbackForeground,
  });

  final String name;
  final String? url;
  final double size;

  /// Border drawn inside the circle. Pass a translucent white for the coloured
  /// header, a pale neutral for cards on the page background.
  final Color? borderColor;

  final double borderWidth;

  /// Draws the green "online" dot on the bottom-right, used over the maroon
  /// header where the dot must be ringed against it.
  final bool presenceDot;

  /// Initials background. Defaults to a translucent white, which only reads on
  /// a dark surface — pass a tinted pair for cards on a light page.
  final Color? fallbackBackground;

  /// Initials foreground. Defaults to white to suit [fallbackBackground].
  final Color? fallbackForeground;

  static const Color _onlineGreen = AppPalette.success;
  static const double _dotSize = 12;
  static const double _dotBorder = 2;

  /// First letter of the first and last words, e.g. "Sujan Karki" -> "SK".
  static String initialsOf(String value) {
    final List<String> parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _fallback() {
    final Color bg = fallbackBackground ?? Colors.white.withValues(alpha: 0.16);
    final Color fg = fallbackForeground ?? Colors.white;

    return ColoredBox(
      color: bg,
      child: Center(
        child: Text(
          initialsOf(name),
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            height: 1,
            color: fg,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = size / 48;
    final Color? border = borderColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE2E8F0),
              border: border == null
                  ? null
                  : Border.all(color: border, width: borderWidth * scale),
            ),
            child: ClipOval(
              child: url == null
                  ? _fallback()
                  : Image.network(
                      url!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => _fallback(),
                    ),
            ),
          ),
          if (presenceDot)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _dotSize * scale,
                height: _dotSize * scale,
                decoration: BoxDecoration(
                  color: _onlineGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppPalette.maroon800,
                    width: _dotBorder * scale,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
