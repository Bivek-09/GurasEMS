import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';

/// One destination in the persistent bottom bar.
@immutable
class BottomNavDestination {
  const BottomNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const List<BottomNavDestination> kBottomNavDestinations =
    <BottomNavDestination>[
      BottomNavDestination(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      BottomNavDestination(
        label: 'Academics',
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded,
      ),
      BottomNavDestination(
        label: 'Notices',
        icon: Icons.notifications_none_rounded,
        activeIcon: Icons.notifications_rounded,
      ),
      BottomNavDestination(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

/// Translucent bottom navigation that the dashboard content scrolls beneath.
///
/// Publishes its own height through [heightOf] so the scrollable content can
/// reserve exactly the right amount of clearance.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    this.destinations = kBottomNavDestinations,
    this.selectedIndex = 0,
    this.onSelected,
    this.enabledIndices = const <int>{},
  });

  final List<BottomNavDestination> destinations;
  final int selectedIndex;

  /// Called for tabs that have a destination.
  final ValueChanged<int>? onSelected;

  /// Which tabs lead somewhere.
  ///
  /// Anything outside this set stays inert — no ripple, no tap — so a tab whose
  /// screen has not been built yet cannot look broken.
  final Set<int> enabledIndices;

  static const double _horizontalPadding = 24;
  static const double _topPadding = 10;
  static const double _bottomPadding = 20;
  static const double _iconSize = 24;
  static const double _dotSize = 6;

  /// Full height including the home-indicator inset.
  static double heightOf(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    return MediaQuery.paddingOf(context).bottom +
        (_topPadding + _bottomPadding + 48) * s;
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14 * s, sigmaY: 14 * s),
        child: Container(
          padding: EdgeInsets.only(
            left: _horizontalPadding * s,
            right: _horizontalPadding * s,
            top: _topPadding * s,
            bottom: MediaQuery.paddingOf(context).bottom + _bottomPadding * s,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            border: Border(top: BorderSide(color: AppGray.shade100)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20 * s,
                offset: Offset(0, -4 * s),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                // Shares the dashboard's content ceiling so the bar lines up
                // with the header and the cards instead of clustering.
                maxWidth: AppLayout.maxContentWidth,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (int i = 0; i < destinations.length; i++)
                    // Flexible so a large system font scale shrinks the labels
                    // instead of overflowing the bar.
                    Flexible(
                      child: _NavItem(
                        destination: destinations[i],
                        selected: i == selectedIndex,
                        scale: s,
                        onTap: onSelected != null && enabledIndices.contains(i)
                            ? () => onSelected!(i)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final BottomNavDestination destination;
  final bool selected;
  final double scale;
  final VoidCallback? onTap;

  static const Color _inactive = AppGray.shade400;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final Color color = selected ? AppPalette.maroon800 : _inactive;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12 * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  selected ? destination.activeIcon : destination.icon,
                  size: AppBottomNav._iconSize * s,
                  color: color,
                ),
                SizedBox(height: 4 * s),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10 * s,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.2,
                    letterSpacing: -0.05 * s,
                    color: color,
                  ),
                ),
                SizedBox(height: 2 * s),
                // The dot reserves the active tab's height in every tab, so the
                // row never shifts when the selection changes.
                Container(
                  width: AppBottomNav._dotSize * s,
                  height: AppBottomNav._dotSize * s,
                  decoration: BoxDecoration(
                    color: selected ? AppPalette.maroon800 : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
