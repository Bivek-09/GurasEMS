import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/personal_info.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/app_toast.dart';
import '../widgets/edit_personal_info_sheet.dart';

/// Personal Information — a section opened from the student profile.
///
/// Shows the record in a divided card and lets the student edit it through a
/// bottom sheet that returns a brand-new [PersonalInfo]. Copy actions use the
/// platform clipboard; the calendar button keeps the reference's demo toast
/// since a Nepali-era picker is out of scope. The global bottom nav keeps the
/// Profile tab active.
class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.personalInformation;

  // ── Geometry ──────────────────────────────────────────────────────────
  static const double _barTopPadding = 12;
  static const double _barBottomPadding = 12;

  /// Full height of the crimson app bar, which [AppScreenBar] now renders.
  static double barHeightOf(BuildContext context) => AppScreenBar.heightOf(
    context,
    topPadding: _barTopPadding,
    bottomPadding: _barBottomPadding,
  );

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  PersonalInfo _info = kPlaceholderStudent;
  String? _toastMessage;
  Timer? _toastTimer;

  // ── Toast ─────────────────────────────────────────────────────────────
  void _showToast(String message) {
    setState(() => _toastMessage = message);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy(String text, String feedback) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showToast(feedback);
  }

  // ── Edit sheet ────────────────────────────────────────────────────────
  Future<void> _openEdit() async {
    final PersonalInfo? updated = await showModalBottomSheet<PersonalInfo>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditPersonalInfoSheet(initial: _info),
    );

    if (updated != null && mounted) {
      setState(() => _info = updated);
      _showToast('Personal info saved successfully!');
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────
  int get _profileTabIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Profile',
  );

  int get _homeTabIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Home',
  );

  int get _noticesTabIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Notices',
  );

  void _handleTabSelected(int index) {
    if (index == _homeTabIndex) {
      // Return to the dashboard tab at the root of the profile stack.
      Navigator.of(context).popUntil(ModalRoute.withName('/home'));
    } else if (index == _noticesTabIndex) {
      // Swap the profile stack for the Notices screen without stacking tabs.
      AppRoutes.switchTab(context, index, _profileTabIndex);
    } else if (index == _profileTabIndex) {
      // Personal Information is pushed above Profile — popping returns to it.
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = PersonalInformationScreen.barHeightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: AppPalette.dashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — scrolling content.
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: barHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.gutter * s,
                  AppSpacing.lg * s,
                  AppLayout.gutter * s,
                  navHeight + AppSpacing.block * s,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContentWidth,
                    ),
                    child: _PersonalInfoCard(
                      info: _info,
                      scale: s,
                      onEdit: _openEdit,
                      onCopy: _copy,
                      onCalendar: () =>
                          _showToast('Calendar BS picker selected'),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Layer 2 — pinned crimson app bar.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppScreenBar(
              title: 'Personal Information',
              onBack: () => Navigator.of(context).maybePop(),
              topPadding: PersonalInformationScreen._barTopPadding,
              bottomPadding: PersonalInformationScreen._barBottomPadding,
              titleSize: 17,
              titleWeight: FontWeight.w700,
            ),
          ),

          // Layer 3 — toast, just under the app bar.
          if (_toastMessage != null)
            Positioned(
              left: 0,
              right: 0,
              top: barHeight + AppSpacing.sm * s,
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

/// The fields card.
class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({
    required this.info,
    required this.scale,
    required this.onEdit,
    required this.onCopy,
    required this.onCalendar,
  });

  final PersonalInfo info;
  final double scale;
  final VoidCallback onEdit;
  final void Function(String text, String feedback) onCopy;
  final VoidCallback onCalendar;

  static const Color _label = Color(0xFF71757E);
  static const Color _value = Color(0xFF1E232E);
  static const Color _hairline = Color(0xFFF1F2F5);

  Widget _fieldRow(String label, String value, {Widget? trailing}) {
    final double s = scale;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15 * s),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: 0.3 * s,
                    color: _label,
                  ),
                ),
                SizedBox(height: 2 * s),
                Text(
                  value,
                  maxLines: label == 'Permanent Address' ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: _value,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            SizedBox(width: AppSpacing.sm * s),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, color: _hairline);

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _fieldRow('Full Name', info.fullName),
          _divider(),
          _fieldRow(
            'Date of Birth',
            info.dob,
            trailing: IconButton(
              tooltip: 'Pick date',
              onPressed: onCalendar,
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 18 * s,
                color: const Color(0xFF9AA1AC),
              ),
            ),
          ),
          _divider(),
          _fieldRow('Gender', info.gender),
          _divider(),
          _fieldRow('Blood Group', info.bloodGroup),
          _divider(),
          _fieldRow('Nationality', info.nationality),
          _divider(),
          _fieldRow(
            'Phone Number',
            info.phone,
            trailing: CopyIconButton(
              onTap: () => onCopy(info.phone, 'Phone number copied!'),
            ),
          ),
          _divider(),
          _fieldRow(
            'Email',
            info.email,
            trailing: CopyIconButton(
              onTap: () => onCopy(info.email, 'Email address copied!'),
            ),
          ),
          _divider(),
          _fieldRow('Permanent Address', info.address),
          SizedBox(height: AppSpacing.lg * s),
          // Edit action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 16 * s),
              label: Text(
                'Edit Information',
                style: TextStyle(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1 * s,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF871730),
                backgroundColor: const Color(0xFFFFF0F2),
                side: BorderSide(
                  color: const Color(0xFFF9D5DC).withValues(alpha: 0.6),
                ),
                padding: EdgeInsets.symmetric(vertical: 13 * s),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.inner * s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
