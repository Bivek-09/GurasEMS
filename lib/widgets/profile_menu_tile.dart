import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';

/// A destination row in the profile menu.
///
/// Reused for every entry so the icon box, label, chevron, hover tint and press
/// feedback stay identical across the list.
class ProfileMenuTile extends StatefulWidget {
  const ProfileMenuTile({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;

  /// Null until the destination screen exists; the row then stays inert rather
  /// than pretending to navigate.
  final VoidCallback? onTap;

  static const double _radius = 12;
  static const double _padding = 14;
  static const double _glyphSize = 32;
  static const double _glyphRadius = 8;
  static const double _iconSize = 20;
  static const double _chevronSize = 16;
  static const double _gap = 14;
  static const double _minHeight = 52;
  static const double _pressedScale = 0.98;

  static const Color _resting = Color(0xFF475569);

  @override
  State<ProfileMenuTile> createState() => _ProfileMenuTileState();
}

class _ProfileMenuTileState extends State<ProfileMenuTile> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final bool active = _hovered || _pressed;
    final Color tint = active ? AppPalette.maroon800 : ProfileMenuTile._resting;

    return AnimatedScale(
      scale: _pressed ? ProfileMenuTile._pressedScale : 1,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        // The fill, border and shadow live on one decorated Container so the
        // shadow renders *behind* its own fill. Splitting them leaves the
        // shadow painting over the card and greying it out.
        child: Container(
          constraints: BoxConstraints(
            minHeight: ProfileMenuTile._minHeight * s,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ProfileMenuTile._radius * s),
            border: Border.all(
              color: active ? const Color(0xFFE2E8F0) : AppPalette.cardBorder,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: active ? 0.07 : 0.04),
                blurRadius: active ? 14 * s : 8 * s,
                offset: Offset(0, active ? 3 * s : 1 * s),
              ),
            ],
          ),
          // Transparent Material: the ink layer has to sit on the white fill
          // for the press ripple to be visible.
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ProfileMenuTile._radius * s),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
              onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
              onTapCancel: widget.onTap == null
                  ? null
                  : () => _setPressed(false),
              onHover: widget.onTap == null ? null : _setHovered,
              child: Padding(
                padding: EdgeInsets.all(ProfileMenuTile._padding * s),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: ProfileMenuTile._glyphSize * s,
                      height: ProfileMenuTile._glyphSize * s,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(
                          ProfileMenuTile._glyphRadius * s,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        size: ProfileMenuTile._iconSize * s,
                        color: tint,
                      ),
                    ),
                    SizedBox(width: ProfileMenuTile._gap * s),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          letterSpacing: -0.1 * s,
                          color: active
                              ? AppPalette.headingText
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    SizedBox(width: 6 * s),
                    AnimatedSlide(
                      offset: active ? const Offset(0.12, 0) : Offset.zero,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: ProfileMenuTile._chevronSize * s,
                        color: tint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
