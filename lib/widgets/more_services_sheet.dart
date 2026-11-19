import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import 'profile_menu_tile.dart';

/// "More services" sheet behind the dashboard's ninth quick action.
///
/// Only lists destinations that already exist in the app and are not already
/// on the quick-actions grid — the profile hub and the personal record — so
/// the sheet can never offer a dead end or a duplicate.
class MoreServicesSheet extends StatelessWidget {
  const MoreServicesSheet({super.key});

  /// Opens the sheet above the dashboard.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => const MoreServicesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg * s,
          AppSpacing.sm * s,
          AppSpacing.lg * s,
          AppSpacing.lg * s,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet * s),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40 * s,
                height: 4 * s,
                decoration: const BoxDecoration(color: AppGray.shade200),
              ),
            ),
            SizedBox(height: AppSpacing.md * s),
            Text(
              'More Services',
              style: TextStyle(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.md * s),
            ProfileMenuTile(
              label: 'My Profile',
              icon: Icons.account_circle_outlined,
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pushNamed(AppRoutes.profile);
              },
            ),
            SizedBox(height: AppSpacing.sm * s),
            ProfileMenuTile(
              label: 'Personal Information',
              // Same glyph the Profile screen already uses for this row.
              icon: Icons.person_outline_rounded,
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pushNamed(AppRoutes.personalInformation);
              },
            ),
          ],
        ),
      ),
    );
  }
}
