import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_theme.dart' show AppShadows, AppRadii, AppSpacing;

/// One entry in the student-services grid.
@immutable
class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.tint,
    required this.tintBackground,
    this.onTap,
  });

  final String label;
  final IconData icon;

  /// Foreground colour of the icon.
  final Color tint;

  /// Soft background behind the icon.
  final Color tintBackground;

  /// Left null until the destination screen exists. A null callback makes the
  /// tile inert — no ripple, no press — instead of pretending to navigate.
  final VoidCallback? onTap;
}

/// The nine student services, ordered exactly as the design presents them.
///
/// Colour system: each service carries its own distinguishable hue and soft
/// pastel surface (see the `tile…` tokens in [AppPalette]) so the grid reads as
/// nine separate services rather than a single brand wash — matching the
/// reference artwork. The icon *shapes* and the container size are identical
/// for every tile; only the colour follows the service.
const List<QuickAction> kQuickActions = <QuickAction>[
  QuickAction(
    label: 'Attendance',
    icon: Icons.assignment_outlined,
    tint: AppPalette.tileEmerald,
    tintBackground: AppPalette.tileEmeraldBg,
  ),
  QuickAction(
    label: 'Results',
    icon: Icons.description_outlined,
    tint: AppPalette.tileBlue,
    tintBackground: AppPalette.tileBlueBg,
  ),
  QuickAction(
    label: 'Fees',
    icon: Icons.account_balance_wallet_outlined,
    tint: AppPalette.tileOrange,
    tintBackground: AppPalette.tileOrangeBg,
  ),
  QuickAction(
    label: 'Classes',
    icon: Icons.menu_book_outlined,
    tint: AppPalette.tileIndigo,
    tintBackground: AppPalette.tileIndigoBg,
  ),
  QuickAction(
    label: 'Timetable',
    icon: Icons.calendar_today_outlined,
    tint: AppPalette.tileRed,
    tintBackground: AppPalette.tileRedBg,
  ),
  QuickAction(
    label: 'Library',
    icon: Icons.bookmark_outlined,
    tint: AppPalette.tileViolet,
    tintBackground: AppPalette.tileVioletBg,
  ),
  QuickAction(
    label: 'Transport',
    icon: Icons.directions_bus_outlined,
    tint: AppPalette.tileAmber,
    tintBackground: AppPalette.tileAmberBg,
  ),
  QuickAction(
    label: 'Notices',
    icon: Icons.campaign_outlined,
    tint: AppPalette.tileRose,
    tintBackground: AppPalette.tileRoseBg,
  ),
  QuickAction(
    label: 'More',
    icon: Icons.more_horiz_outlined,
    tint: AppPalette.tileTeal,
    tintBackground: AppPalette.tileTealBg,
  ),
];

/// A single service tile on the dashboard.
///
/// Every shortcut in the grid — Attendance through More — is rendered by this
/// one widget, so the nine tiles are guaranteed to share one design system
/// instead of drifting apart as nine near-copies. It owns the fixed proportions
/// (card radius, icon-container size, glyph size, label gap) so a new service
/// only has to supply a [QuickAction].
///
/// The white card, hairline border and resting shadow are the same tokens the
/// rest of the dashboard uses ([AppShadows.card]); the tinted container behind
/// the glyph is the only per-tile colour.
class DashboardShortcut extends StatelessWidget {
  const DashboardShortcut({
    super.key,
    required this.action,
    this.onTap,
    this.scale = 1,
  });

  final QuickAction action;

  /// Overrides [QuickAction.onTap] when the grid wires taps at its own level.
  final VoidCallback? onTap;

  /// Responsive scale factor, shared with the grid so every tile matches.
  final double scale;

  // ── Proportions (logical pixels, before [scale]) ────────────────────────
  /// Square tinted container behind every glyph. Measured from the reference
  /// artwork, then eased down to 38 lp so the tile reads a touch lighter on a
  /// 390 lp-wide phone.
  static const double containerSize = 38;

  /// Corner radius of the tinted container.
  static const double containerRadius = AppRadii.inner;

  /// Glyph size inside the container — consistent optical weight across all
  /// nine icons because they all come from Material's `_outlined` family.
  static const double glyphSize = 18;

  /// Corner radius of the white card.
  static const double cardRadius = AppRadii.block;

  static const double _verticalPadding = 14;
  static const double _horizontalPadding = 6;
  static const double _labelGap = 10;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final VoidCallback? handler = onTap ?? action.onTap;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding * s,
        vertical: _verticalPadding * s,
      ),
      decoration: BoxDecoration(
        // Fill, border and shadow share one decorated Container so the shadow
        // renders behind the fill instead of greying it out.
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: AppShadows.card(s),
      ),
      child: Material(
        // Transparent Material keeps the ink layer on the white fill so the
        // press ripple stays visible.
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(cardRadius * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: handler,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: containerSize * s,
                height: containerSize * s,
                decoration: BoxDecoration(
                  color: action.tintBackground,
                  borderRadius: BorderRadius.circular(containerRadius * s),
                ),
                child: Icon(
                  action.icon,
                  size: glyphSize * s,
                  color: action.tint,
                ),
              ),
              SizedBox(height: _labelGap * s),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  letterSpacing: -0.1 * s,
                  color: AppGray.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three-column grid of student services.
///
/// Built as explicit rows inside a [LayoutBuilder] rather than a scrolling
/// [GridView]: the dashboard is already one vertical scroll view, and rendering
/// the grid as rows lets every tile in a row stretch to the tallest tile's
/// height — so a label that wraps on a narrow phone grows the whole row instead
/// of clipping a neighbour. [LayoutBuilder] supplies the available width so the
/// gap can breathe on wider content columns and the composition never overflows.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    this.actions = kQuickActions,
    this.onActionTap,
  });

  final List<QuickAction> actions;
  final ValueChanged<String>? onActionTap;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Tighten the gutter on the narrowest phones and let it open up on a
        // comfortable content column, without ever changing the 3-up rhythm.
        final double gap =
            (constraints.maxWidth < 300 ? AppSpacing.sm : AppSpacing.md) * s;
        final int rows = (actions.length / _columns).ceil();

        return Column(
          children: <Widget>[
            for (int row = 0; row < rows; row++) ...<Widget>[
              if (row > 0) SizedBox(height: gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int col = 0; col < _columns; col++) ...<Widget>[
                      if (col > 0) SizedBox(width: gap),
                      Expanded(child: _tileAt(row * _columns + col, s)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Builds the tile at [index], or an empty spacer when the list does not fill
  /// the final row (keeps the 3-up alignment without a half-width tile).
  Widget _tileAt(int index, double s) {
    if (index >= actions.length) return const SizedBox.shrink();
    final QuickAction action = actions[index];
    return DashboardShortcut(
      action: action,
      scale: s,
      onTap: onActionTap == null ? null : () => onActionTap!(action.label),
    );
  }
}
