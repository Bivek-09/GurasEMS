import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppShadows;
import '../models/guardian_info.dart';
import '../models/student_profile.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_toast.dart';
import '../widgets/call_action_sheet.dart';
import '../widgets/edit_guardian_info_sheet.dart';
import '../widgets/user_avatar.dart';

/// Guardian Information — a section opened from the student profile.
///
/// Shows both guardians and the school's emergency contact as three divided
/// cards, lets the record be edited through a bottom sheet that returns a brand
/// new [GuardianInfo], and confirms in a sheet before handing a number to the
/// phone. Mirrors the reference layout: pinned maroon app bar over a scrolling
/// body, with the global bottom nav keeping the Profile tab active.
class GuardianInformationScreen extends StatefulWidget {
  const GuardianInformationScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.guardianInformation;

  // ── Geometry ──────────────────────────────────────────────────────────
  static const double _barTopPadding = 12;
  static const double _barBottomPadding = 12;
  static const double _barControl = 40;

  /// Full height of the maroon app bar.
  static double barHeightOf(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    return MediaQuery.paddingOf(context).top +
        (_barTopPadding + _barControl + _barBottomPadding) * s;
  }

  @override
  State<GuardianInformationScreen> createState() =>
      _GuardianInformationScreenState();
}

class _GuardianInformationScreenState extends State<GuardianInformationScreen> {
  // Sample record — comes from the student API in production.
  GuardianInfo _info = kPlaceholderGuardians;
  String? _toastMessage;
  Timer? _toastTimer;

  // ── Toast ─────────────────────────────────────────────────────────────
  void _showToast(String message) {
    setState(() => _toastMessage = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  // ── Edit sheet ────────────────────────────────────────────────────────
  Future<void> _openEdit() async {
    final GuardianInfo? updated = await showModalBottomSheet<GuardianInfo>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditGuardianInfoSheet(initial: _info),
    );

    if (updated != null && mounted) {
      setState(() => _info = updated);
      _showToast('Guardian Information updated and sent for verification!');
    }
  }

  // ── Call affordance ───────────────────────────────────────────────────
  Future<void> _call(String name, String phone) async {
    final bool placeCall = await CallActionSheet.show(
      context,
      name: name,
      phone: phone,
    );
    if (!placeCall || !mounted) return;

    // No dialler package in this build, so surface the number instead of
    // pretending to call it.
    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) _showToast('Copied $phone — dial it from your phone');
  }

  // ── Navigation (mirrors the Personal Information profile stack) ───────
  int get _homeTabIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Home',
  );

  int get _academicsTabIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Academics',
  );

  int get _noticesTabIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Notices',
  );

  int get _profileTabIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Profile',
  );

  void _handleTabSelected(int index) {
    if (index == _homeTabIndex) {
      // Return to the dashboard tab at the root of the profile stack.
      Navigator.of(context).popUntil(ModalRoute.withName('/home'));
    } else if (index == _profileTabIndex) {
      // Guardian Information is pushed above Profile — popping returns to it.
      Navigator.of(context).maybePop();
    } else {
      // Swap the profile stack for Academics / Notices without stacking tabs.
      AppRoutes.switchTab(context, index, _profileTabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = GuardianInformationScreen.barHeightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: AppPalette.dashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — scrolling content incl. the three cards and the edit
          // action, riding beneath the pinned header and nav bar.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: barHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.gutter * s,
                  14 * s,
                  AppLayout.gutter * s,
                  navHeight + 24 * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _StudentSummaryPill(scale: s),
                        SizedBox(height: 14 * s),
                        _GuardianCard.father(
                          scale: s,
                          guardian: _info.father,
                          onCall: () =>
                              _call(_info.father.fullName, _info.father.phone),
                        ),
                        SizedBox(height: 14 * s),
                        _GuardianCard.mother(
                          scale: s,
                          guardian: _info.mother,
                          onCall: () =>
                              _call(_info.mother.fullName, _info.mother.phone),
                        ),
                        SizedBox(height: 14 * s),
                        _EmergencyCard(
                          scale: s,
                          info: _info,
                          onCallPrimary: () => _call(
                            _info.father.fullName,
                            _info.emergencyPrimaryPhone,
                          ),
                          onCallSecondary: () => _call(
                            _info.mother.fullName,
                            _info.emergencySecondaryPhone,
                          ),
                        ),
                        SizedBox(height: 14 * s),
                        _EditGuardianAction(scale: s, onEdit: _openEdit),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer 2 — pinned maroon app bar.
          Positioned(left: 0, right: 0, top: 0, child: _AppBar(scale: s)),

          // Layer 3 — toast, just under the app bar.
          if (_toastMessage != null)
            Positioned(
              left: 0,
              right: 0,
              top: barHeight + 8 * s,
              child: Center(child: AppToast(message: _toastMessage!)),
            ),

          // Layer 4 — persistent navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: _profileTabIndex,
              enabledIndices: <int>{
                _homeTabIndex,
                _academicsTabIndex,
                _noticesTabIndex,
                _profileTabIndex,
              },
              onSelected: _handleTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

/// Maroon app bar: back control, centred title, help affordance.
class _AppBar extends StatelessWidget {
  const _AppBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final double inset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.only(
        top: inset + GuardianInformationScreen._barTopPadding * s,
        bottom: GuardianInformationScreen._barBottomPadding * s,
        left: 16 * s,
        right: 16 * s,
      ),
      decoration: const BoxDecoration(color: AppPalette.maroon800),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: GuardianInformationScreen._barControl * s,
                height: GuardianInformationScreen._barControl * s,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 24 * s,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Guardian Information',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: GuardianInformationScreen._barControl * s,
                height: GuardianInformationScreen._barControl * s,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showHelpToast(context),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 22 * s,
                      color: Colors.white,
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

  Future<void> _showHelpToast(BuildContext context) async {
    // The reference's help action surfaces the school admin desk information.
    await showAdaptiveDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        content: const Text(
          'School Administration Desk: 021-523456\ninfo@gurasems.edu.np',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// The student's identity reference pill above the guardian cards.
class _StudentSummaryPill extends StatelessWidget {
  const _StudentSummaryPill({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: AppShadows.card(s),
      ),
      child: Row(
        children: <Widget>[
          UserAvatar(
            name: StudentProfile.name,
            // The reference shows initials, so the sample portrait stays off.
            url: null,
            size: 40 * s,
            borderColor: const Color(0xFFFBCFE0),
            borderWidth: 1,
            fallbackBackground: const Color(0xFFFDF2F4),
            fallbackForeground: const Color(0xFF7D1128),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'STUDENT PROFILE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7 * s,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  '${StudentProfile.name} (Grade ${StudentProfile.grade} - '
                  '${StudentProfile.section})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5 * s,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppPalette.headingText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          const _VerifiedBadge(),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFA7F3D0)),
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
            'Verified',
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF047857),
            ),
          ),
        ],
      ),
    );
  }
}

/// One guardian card: a header strip (glyph, title, subtitle, role badge) over
/// a divided list of key/value rows.
class _GuardianCard extends StatelessWidget {
  const _GuardianCard._({
    required this.scale,
    required this.guardian,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.glyph,
    required this.glyphBg,
    required this.glyphFg,
    required this.badgeBg,
    required this.badgeFg,
    required this.badgeBorder,
    required this.onCall,
  });

  factory _GuardianCard.father({
    required double scale,
    required Guardian guardian,
    required VoidCallback onCall,
  }) {
    return _GuardianCard._(
      scale: scale,
      guardian: guardian,
      title: 'Father / Primary Guardian',
      subtitle: 'Primary legal guardian',
      badge: 'FATHER',
      glyph: Icons.person_outline_rounded,
      glyphBg: AppPalette.maroonSurface,
      glyphFg: AppPalette.maroon800,
      badgeBg: AppPalette.maroonSurface,
      badgeFg: AppPalette.maroon800,
      badgeBorder: const Color(0xFFF9D5DC),
      onCall: onCall,
    );
  }

  factory _GuardianCard.mother({
    required double scale,
    required Guardian guardian,
    required VoidCallback onCall,
  }) {
    return _GuardianCard._(
      scale: scale,
      guardian: guardian,
      title: 'Mother / Secondary Guardian',
      subtitle: 'Secondary contact guardian',
      badge: 'MOTHER',
      glyph: Icons.female,
      glyphBg: const Color(0xFFFCE7F3),
      glyphFg: const Color(0xFFDB2777),
      badgeBg: const Color(0xFFFCE7F3),
      badgeFg: const Color(0xFFDB2777),
      badgeBorder: const Color(0xFFFBCFE8),
      onCall: onCall,
    );
  }

  final double scale;
  final Guardian guardian;
  final String title;
  final String subtitle;
  final String badge;
  final IconData glyph;
  final Color glyphBg;
  final Color glyphFg;
  final Color badgeBg;
  final Color badgeFg;
  final Color badgeBorder;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: AppShadows.card(s),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _cardHeader(
                s: s,
                title: title,
                subtitle: subtitle,
                glyph: glyph,
                glyphBg: glyphBg,
                glyphFg: glyphFg,
                badge: badge,
                badgeBg: badgeBg,
                badgeFg: badgeFg,
                badgeBorder: badgeBorder,
              ),
              SizedBox(height: 12 * s),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
              SizedBox(height: 4 * s),
              _InfoRow(
                scale: s,
                label: 'FULL NAME',
                value: _valueText(guardian.fullName, s),
              ),
              _InfoRow(
                scale: s,
                label: 'RELATION',
                value: _valueText(guardian.relation, s),
              ),
              _InfoRow(
                scale: s,
                label: 'OCCUPATION',
                value: _valueText(guardian.occupation, s),
              ),
              _InfoRow(
                scale: s,
                label: 'PHONE NUMBER',
                value: _valueText(guardian.phone, s),
                trailing: _CallButton(scale: s, onTap: onCall),
              ),
              _InfoRow(
                scale: s,
                label: 'EMAIL',
                value: _valueText(guardian.email, s),
              ),
              if (guardian.address != null)
                _InfoRow(
                  scale: s,
                  label: 'ADDRESS',
                  value: _valueText(guardian.address!, s),
                  alignTop: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _valueText(String value, double s) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 13 * s,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppPalette.headingText,
      ),
    );
  }
}

/// The shared card header: glyph box, title/subtitle, role badge.
Widget _cardHeader({
  required double s,
  required String title,
  required String subtitle,
  required IconData glyph,
  required Color glyphBg,
  required Color glyphFg,
  required String badge,
  required Color badgeBg,
  required Color badgeFg,
  required Color badgeBorder,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        width: 32 * s,
        height: 32 * s,
        decoration: BoxDecoration(
          color: glyphBg,
          borderRadius: BorderRadius.circular(8 * s),
        ),
        child: Icon(glyph, size: 18 * s, color: glyphFg),
      ),
      SizedBox(width: 10 * s),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13 * s,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppPalette.headingText,
              ),
            ),
            SizedBox(height: 1 * s),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 8 * s),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(6 * s),
          border: Border.all(color: badgeBorder),
        ),
        child: Text(
          badge,
          style: TextStyle(
            fontSize: 10 * s,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6 * s,
            color: badgeFg,
          ),
        ),
      ),
    ],
  );
}

/// One divided key/value row inside a white card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.scale,
    required this.label,
    required this.value,
    this.trailing,
    this.alignTop = false,
  });

  final double scale;
  final String label;
  final Widget value;
  final Widget? trailing;
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7 * s),
      child: Row(
        crossAxisAlignment: alignTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              height: 1.35,
              color: AppPalette.supportingText,
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(child: value),
          if (trailing != null) ...<Widget>[SizedBox(width: 8 * s), trailing!],
        ],
      ),
    );
  }
}

/// Compact emerald "Call" pill that opens the confirmation sheet.
class _CallButton extends StatelessWidget {
  const _CallButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(8 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 5 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.call_rounded,
                size: 12 * s,
                color: const Color(0xFF047857),
              ),
              SizedBox(width: 3 * s),
              Text(
                'Call',
                style: TextStyle(
                  fontSize: 10.5 * s,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF047857),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The rose-tinted emergency contact card.
class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({
    required this.scale,
    required this.info,
    required this.onCallPrimary,
    required this.onCallSecondary,
  });

  final double scale;
  final GuardianInfo info;
  final VoidCallback onCallPrimary;
  final VoidCallback onCallSecondary;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: const Color(0xFFFECDD3)),
        boxShadow: AppShadows.card(s),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _cardHeader(
                s: s,
                title: 'Emergency Contact',
                subtitle: 'Auto-notified during school incidents',
                glyph: Icons.emergency_outlined,
                glyphBg: const Color(0xFFFEE2E2),
                glyphFg: AppPalette.pendingText,
                badge: 'PRIORITY 1',
                badgeBg: const Color(0xFFFFF1F2),
                badgeFg: AppPalette.pendingText,
                badgeBorder: AppPalette.pendingBorder,
              ),
              SizedBox(height: 12 * s),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
              SizedBox(height: 4 * s),
              _InfoRow(
                scale: s,
                label: 'CONTACT PERSON',
                value: _valueText(info.emergencyContactPerson, s),
              ),
              _InfoRow(
                scale: s,
                label: 'PRIMARY EMERGENCY',
                value: _phoneLink(
                  info.emergencyPrimaryPhone,
                  s,
                  color: AppPalette.maroon800,
                  onTap: onCallPrimary,
                ),
              ),
              _InfoRow(
                scale: s,
                label: 'SECONDARY EMERGENCY',
                value: _phoneLink(
                  info.emergencySecondaryPhone,
                  s,
                  color: const Color(0xFF1F2937),
                  onTap: onCallSecondary,
                ),
              ),
              _InfoRow(
                scale: s,
                label: 'RELATIONSHIP',
                value: _valueText(info.relationship, s),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _valueText(String value, double s) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 13 * s,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppPalette.headingText,
      ),
    );
  }

  Widget _phoneLink(
    String phone,
    double s, {
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6 * s),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2 * s),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.phone_in_talk_rounded, size: 14 * s, color: color),
            SizedBox(width: 4 * s),
            Flexible(
              child: Text(
                phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width "Edit Information" action with the verification caption.
class _EditGuardianAction extends StatelessWidget {
  const _EditGuardianAction({required this.scale, required this.onEdit});

  final double scale;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 50 * s,
          child: FilledButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 17 * s),
            label: Text(
              'Edit Information',
              style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFDF2F4),
              foregroundColor: const Color(0xFF7D1128),
              overlayColor: const Color(0xFFF9D5DC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * s),
                side: const BorderSide(color: Color(0xFFF9D5DC)),
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          'Changes are validated by the School Administration.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11 * s,
            color: const Color(0xFF9CA3AF),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
