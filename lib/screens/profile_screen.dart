import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppSpacing;
import '../models/student_profile.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/user_avatar.dart';

/// Profile overview.
///
/// Pinned maroon app bar over a scrolling body: identity, the academic
/// summary strip, then the section menu. Matches the reference structure — the
/// header stays put while the content beneath it scrolls.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.profile;

  // The signed-in record lives in [StudentProfile], shared with the dashboard
  // so the name, class and portrait can never drift apart between screens.

  static const List<_AcademicStat> _stats = <_AcademicStat>[
    _AcademicStat(label: 'Grade', value: StudentProfile.grade),
    _AcademicStat(label: 'Section', value: StudentProfile.section),
    _AcademicStat(label: 'Academic Year', value: StudentProfile.academicYear),
  ];

  /// Section destinations. Personal Information and Guardian Information are
  /// wired; the rest stay inert rather than pushing an empty page, until their
  /// screens land.
  List<ProfileMenuTile> _buildMenu(BuildContext context) {
    return <ProfileMenuTile>[
      ProfileMenuTile(
        label: 'Personal Information',
        icon: Icons.person_outline_rounded,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.personalInformation),
      ),
      ProfileMenuTile(
        label: 'Guardian Information',
        icon: Icons.groups_outlined,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.guardianInformation),
      ),
      ProfileMenuTile(
        label: 'Academic Information',
        icon: Icons.school_outlined,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.academicInformation),
      ),
    ];
  }

  // ── Geometry ──────────────────────────────────────────────────────────
  static const double _barTopPadding = 12;
  static const double _barBottomPadding = 24;
  static const double _barControl = 44;

  // ── Component sizing ──────────────────────────────────────────────────
  static const double _avatarSize = 96;
  static const double _cameraSize = 32;
  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final List<ProfileMenuTile> menu = _buildMenu(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: <Widget>[
          AppScreenBar(
            title: 'My Profile',
            topPadding: ProfileScreen._barTopPadding,
            bottomPadding: ProfileScreen._barBottomPadding,
            controlSize: ProfileScreen._barControl,
            iconSize: 19,
            titleSize: 18,
            titleWeight: FontWeight.w700,
            titleLetterSpacing: -0.2,
            onBack: () => Navigator.of(context).maybePop(),
            shadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8 * s,
                offset: Offset(0, 2 * s),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _Identity(scale: s),
                      SizedBox(height: AppSpacing.xl * s),
                      const _AcademicSummary(),
                      SizedBox(height: AppSpacing.xl * s),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppLayout.gutter * s,
                        ),
                        child: Column(
                          children: <Widget>[
                            for (int i = 0; i < menu.length; i++) ...<Widget>[
                              if (i > 0) SizedBox(height: 10 * s),
                              menu[i],
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * s),
                    ],
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

/// Avatar, name, active badge and registration id.
class _Identity extends StatelessWidget {
  const _Identity({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 24 * s, 24 * s, AppSpacing.lg * s),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              UserAvatar(
                name: StudentProfile.name,
                url: StudentProfile.avatarUrl,
                size: ProfileScreen._avatarSize * s,
                borderColor: AppPalette.cardBorder,
                borderWidth: 2,
                fallbackBackground: AppPalette.maroonSurface,
                fallbackForeground: AppPalette.maroon800,
              ),
              // Photo replacement needs a native picker, which this build does
              // not depend on yet; left inert rather than faking an upload.
              Positioned(
                right: -2 * s,
                bottom: -2 * s,
                child: Container(
                  width: ProfileScreen._cameraSize * s,
                  height: ProfileScreen._cameraSize * s,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2 * s),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6 * s,
                        offset: Offset(0, 2 * s),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 15 * s,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md * s),
          Text(
            StudentProfile.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20 * s,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.3 * s,
              color: AppPalette.headingText,
            ),
          ),
          SizedBox(height: AppSpacing.sm * s),
          const _ActiveBadge(),
          SizedBox(height: 6 * s),
          Text(
            StudentProfile.registrationId,
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0.6 * s,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: AppPalette.statusGreenBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6 * s,
            height: 6 * s,
            decoration: const BoxDecoration(
              color: AppPalette.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6 * s),
          Text(
            'Active',
            style: TextStyle(
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppPalette.statusGreen,
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _AcademicStat {
  const _AcademicStat({required this.label, required this.value});

  final String label;
  final String value;
}

/// Grade / Section / Academic Year strip.
class _AcademicSummary extends StatelessWidget {
  const _AcademicSummary();

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter * s),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ProfileScreen._radius * s),
          border: Border.all(color: AppPalette.cardBorder),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6 * s,
              offset: Offset(0, 1 * s),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < ProfileScreen._stats.length; i++)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs * s),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : const Border(
                            left: BorderSide(color: AppPalette.cardBorder),
                          ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        ProfileScreen._stats[i].label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          letterSpacing: 0.6 * s,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        ProfileScreen._stats[i].value,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
