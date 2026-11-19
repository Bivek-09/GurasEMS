import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart' show AppRadii, AppSpacing;
import '../models/transport_data.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_screen_bar.dart';
import '../widgets/app_toast.dart';
import '../widgets/transport_sheets.dart';

/// Transport — live bus tracking for the student's route.
///
/// Opened from the dashboard's Transport quick action. A maroon bar carries the
/// title and a live-tracking toggle, the primary card summarises the bus, the
/// driver and the route progress, and a pair of quick actions open the
/// emergency and GPS-radar sheets. Tapping the ETA badge or a stop advances the
/// simulated journey; the bottom nav keeps Home active, as in the reference.
class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  /// Route name declared in `MaterialApp.routes`.
  static const String routeName = AppRoutes.transport;

  // ── Header geometry ───────────────────────────────────────────────────
  static const double _barTopPadding = 12;
  static const double _control = 40;
  static const double _barBottomPadding = 12;

  /// Full height of the maroon header, which [AppScreenBar] now renders.
  static double barHeightOf(BuildContext context) => AppScreenBar.heightOf(
    context,
    topPadding: _barTopPadding,
    bottomPadding: _barBottomPadding,
  );

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  /// Index into [kTransportMilestones]; the pickup stop is the default.
  int _milestone = 1;

  bool _simulationActive = true;

  String? _toastMessage;
  Timer? _toastTimer;

  TransportMilestone get _step => kTransportMilestones[_milestone];

  // ── Toast ─────────────────────────────────────────────────────────────
  void _showToast(String message) {
    if (!mounted) return;
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

  // ── Simulation ────────────────────────────────────────────────────────
  void _toggleSimulation() {
    setState(() => _simulationActive = !_simulationActive);
    _showToast(
      _simulationActive
          ? 'Live GPS Simulation: Active'
          : 'Live GPS Simulation: Paused',
    );
  }

  void _advanceMilestone() {
    setState(() => _milestone = (_milestone + 1) % kTransportMilestones.length);
    _showToast('Simulation updated: Bus reached milestone ${_milestone + 1}');
  }

  void _selectStop(int index) {
    if (index < 0 || index >= kTransportStops.length) return;
    setState(() => _milestone = index);
    _showToast(_step.toast);
  }

  // ── Sheets ────────────────────────────────────────────────────────────
  Future<void> _callDriver() async {
    final bool? call = await TransportCallSheet.show(
      context,
      title: 'Call Driver',
      lead: 'Calling ',
      name: kTransport.driverName,
      trail: ' for ${kTransport.busNumber} inquiries at',
      number: kTransport.driverDial,
      confirmLabel: 'Call Now',
      accent: AppPalette.statusGreen,
      accentSurface: AppPalette.statusGreenBorder,
      icon: Icons.call_rounded,
    );
    if (!mounted || call != true) return;
    _showToast(
      'Dialing ${kTransport.driverName} (${kTransport.driverDial})...',
    );
  }

  Future<void> _callAttendant() async {
    final bool? call = await TransportCallSheet.show(
      context,
      title: 'Contact Bus Attendant',
      lead: 'Reach helper ',
      name: kTransport.attendantName,
      trail: ' for boarding assistance & luggage support:',
      number: kTransport.attendantDial,
      confirmLabel: 'Call Attendant',
      accent: AppPalette.maroon800,
      accentSurface: const Color(0xFFFFE4E6),
      initials: kTransport.attendantInitials,
    );
    if (!mounted || call != true) return;
    _showToast(
      'Calling Attendant ${kTransport.attendantName} '
      '(${kTransport.attendantDial})...',
    );
  }

  Future<void> _reportEmergency() async {
    final EmergencyReason? reason = await TransportEmergencySheet.show(context);
    if (!mounted || reason == null) return;
    _showToast('SOS Sent: "${reason.message}" dispatched!');
  }

  Future<void> _openRadar() => TransportRadarSheet.show(context);

  // ── Navigation ────────────────────────────────────────────────────────
  int get _homeIndex => kBottomNavDestinations.indexWhere(
    (BottomNavDestination d) => d.label == 'Home',
  );

  void _onTabSelected(int index) =>
      AppRoutes.switchTab(context, index, _homeIndex);

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double barHeight = TransportScreen.barHeightOf(context);
    final double navHeight = AppBottomNav.heightOf(context);

    return Scaffold(
      backgroundColor: AppPalette.dashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Layer 1 — the scrolling body.
          Positioned.fill(
            child: Column(
              children: <Widget>[
                SizedBox(height: barHeight),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg * s,
                      AppSpacing.md * s,
                      AppSpacing.lg * s,
                      navHeight + AppSpacing.block * s,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppLayout.maxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _BusCard(
                              step: _step,
                              scale: s,
                              onCallDriver: _callDriver,
                              onAdvance: _advanceMilestone,
                              onSelectStop: _selectStop,
                            ),
                            SizedBox(height: AppSpacing.md * s),
                            _QuickActions(
                              scale: s,
                              onEmergency: _reportEmergency,
                              onRadar: _openRadar,
                            ),
                            SizedBox(height: AppSpacing.md * s),
                            _AttendantCard(scale: s, onContact: _callAttendant),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Layer 2 — pinned maroon app bar.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppScreenBar(
              title: 'Transport',
              leadingIcon: Icons.arrow_back_rounded,
              iconSize: 20,
              topPadding: TransportScreen._barTopPadding,
              bottomPadding: TransportScreen._barBottomPadding,
              horizontalPadding: 12,
              titleSize: 18,
              titleWeight: FontWeight.w700,
              titleLetterSpacing: -0.2,
              onBack: () => Navigator.of(context).maybePop(),
              trailing: _PulseButton(
                scale: s,
                active: _simulationActive,
                onTap: _toggleSimulation,
              ),
            ),
          ),

          // Layer 3 — toast, floating above the nav bar.
          if (_toastMessage != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: navHeight + 12 * s,
              child: Center(child: AppToast(message: _toastMessage!)),
            ),

          // Layer 4 — persistent navigation.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              selectedIndex: _homeIndex,
              enabledIndices: <int>{0, 1, 2, 3},
              onSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Live-tracking pulse button
// ─────────────────────────────────────────────────────────────────────────

/// Live-tracking status toggle: a green dot while the feed is live, grey when
/// paused.
class _PulseButton extends StatelessWidget {
  const _PulseButton({
    required this.scale,
    required this.active,
    required this.onTap,
  });

  final double scale;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final Color core = active ? const Color(0xFF34D399) : AppSlate.shade300;

    return SizedBox(
      width: TransportScreen._control * s,
      height: TransportScreen._control * s,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            button: true,
            label: 'Live Tracking Status',
            child: Center(
              child: SizedBox(
                width: 14 * s,
                height: 14 * s,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    if (active)
                      Container(
                        width: 14 * s,
                        height: 14 * s,
                        decoration: BoxDecoration(
                          color: core.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Container(
                      width: 8 * s,
                      height: 8 * s,
                      decoration: BoxDecoration(
                        color: core,
                        shape: BoxShape.circle,
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

// ─────────────────────────────────────────────────────────────────────────
// Primary bus card
// ─────────────────────────────────────────────────────────────────────────

class _BusCard extends StatelessWidget {
  const _BusCard({
    required this.step,
    required this.scale,
    required this.onCallDriver,
    required this.onAdvance,
    required this.onSelectStop,
  });

  final TransportMilestone step;
  final double scale;
  final VoidCallback onCallDriver;
  final VoidCallback onAdvance;
  final ValueChanged<int> onSelectStop;

  static const Color _label = AppSlate.shade400;
  static const Color _value = AppGray.shade800;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _header(s),
          SizedBox(height: AppSpacing.md * s),
          _DriverRow(scale: s, label: 'Driver', onCall: onCallDriver),
          _Hairline(scale: s),
          _DetailRow(
            scale: s,
            label: 'Route',
            value: _RouteLine(scale: s),
          ),
          _Hairline(scale: s),
          _DetailRow(
            scale: s,
            label: 'Departure Time',
            value: Text(
              kTransport.departureTime,
              style: TextStyle(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: _value,
              ),
            ),
            trailing: _OnTimeBadge(scale: s),
          ),
          _Hairline(scale: s),
          _DetailRow(
            scale: s,
            label: 'Pickup Point',
            value: Text(
              kTransport.pickupPoint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * s,
                fontWeight: FontWeight.w700,
                color: _value,
              ),
            ),
            trailing: _YourStopBadge(scale: s),
          ),
          SizedBox(height: 10 * s),
          _RouteTimeline(
            step: step,
            scale: s,
            onAdvance: onAdvance,
            onSelectStop: onSelectStop,
          ),
        ],
      ),
    );
  }

  Widget _header(double s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 44 * s,
          height: 44 * s,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14 * s),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Icon(
            Icons.directions_bus_rounded,
            size: 22 * s,
            color: AppPalette.accentBlue,
          ),
        ),
        SizedBox(width: AppSpacing.md * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                kTransport.busNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17 * s,
                  fontWeight: FontWeight.w700,
                  color: AppSlate.shade900,
                ),
              ),
              SizedBox(height: 5 * s),
              _ActivePill(scale: s),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm * s),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Current Speed',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5 * s,
                  fontWeight: FontWeight.w500,
                  color: _label,
                ),
              ),
              SizedBox(height: 3 * s),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm * s,
                  vertical: 3 * s,
                ),
                decoration: BoxDecoration(
                  color: AppSlate.shade50,
                  borderRadius: BorderRadius.circular(AppRadii.micro * s),
                  border: Border.all(color: AppSlate.shade200),
                ),
                child: Text(
                  step.speed,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5 * s,
                    fontWeight: FontWeight.w700,
                    color: AppSlate.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: AppPalette.statusGreenBg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppPalette.statusGreenBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 9 * s,
            height: 9 * s,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 9 * s,
                  height: 9 * s,
                  decoration: BoxDecoration(
                    color: AppPalette.statusGreen.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 5 * s,
                  height: 5 * s,
                  decoration: const BoxDecoration(
                    color: AppPalette.statusGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * s),
          Flexible(
            child: Text(
              'Active',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF047857),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row for the driver, which carries the call affordance.
class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.scale,
    required this.label,
    required this.onCall,
  });

  final double scale;
  final String label;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final k = kTransport;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm * s),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _FieldLabel(text: label, scale: s),
                SizedBox(height: 2 * s),
                Text(
                  k.driverName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: AppGray.shade800,
                  ),
                ),
                SizedBox(height: 1 * s),
                Text(
                  k.driverPhone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    color: AppSlate.shade500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm * s),
          SizedBox(
            width: 40 * s,
            height: 40 * s,
            child: Material(
              color: AppPalette.statusGreenBg,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onCall,
                child: Semantics(
                  button: true,
                  label: 'Call Driver ${k.driverName}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.statusGreenBorder),
                    ),
                    child: Icon(
                      Icons.call_rounded,
                      size: 18 * s,
                      color: AppPalette.statusGreen,
                    ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.scale,
    required this.label,
    required this.value,
    this.trailing,
  });

  final double scale;
  final String label;
  final Widget value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm * s),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _FieldLabel(text: label, scale: s),
                SizedBox(height: 3 * s),
                value,
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            SizedBox(width: AppSpacing.sm * s),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.scale});
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Text(
      text,
      style: TextStyle(
        fontSize: 11 * s,
        fontWeight: FontWeight.w500,
        color: AppSlate.shade400,
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AppSlate.shade50);
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Wrap(
      spacing: 6 * s,
      runSpacing: 4 * s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          kTransport.from,
          style: TextStyle(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: AppGray.shade800,
          ),
        ),
        Icon(Icons.east_rounded, size: 16 * s, color: AppSlate.shade400),
        Text(
          kTransport.to,
          style: TextStyle(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: AppGray.shade800,
          ),
        ),
      ],
    );
  }
}

class _OnTimeBadge extends StatelessWidget {
  const _OnTimeBadge({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    // The reference stacks the two words over two lines.
    final List<String> words = kTransport.onTimeLabel.split(' ');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm * s,
        vertical: AppSpacing.xs * s,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(AppRadii.micro * s),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final String word in words)
            Text(
              word,
              style: TextStyle(
                fontSize: 9 * s,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: 0.6 * s,
                color: const Color(0xFFB45309),
              ),
            ),
        ],
      ),
    );
  }
}

class _YourStopBadge extends StatelessWidget {
  const _YourStopBadge({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Text(
        kTransport.pickupBadge,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11 * s,
          fontWeight: FontWeight.w600,
          color: AppPalette.accentBlue,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Live route timeline
// ─────────────────────────────────────────────────────────────────────────

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline({
    required this.step,
    required this.scale,
    required this.onAdvance,
    required this.onSelectStop,
  });

  final TransportMilestone step;
  final double scale;
  final VoidCallback onAdvance;
  final ValueChanged<int> onSelectStop;

  /// Height of the bus-pin slot above every node, so nodes stay aligned.
  static const double _pinSlot = 32;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(height: 1, thickness: 1, color: AppSlate.shade100),
        SizedBox(height: AppSpacing.md * s),
        Row(
          children: <Widget>[
            Container(
              width: 8 * s,
              height: 8 * s,
              decoration: const BoxDecoration(
                color: AppPalette.accentBlue,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6 * s),
            Expanded(
              child: Text(
                'Live Route Progress',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w700,
                  color: AppSlate.shade800,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm * s),
            _EtaBadge(text: step.eta, scale: s, onTap: onAdvance),
          ],
        ),
        SizedBox(height: AppSpacing.xs * s),
        SizedBox(
          height: 100 * s,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double w = constraints.maxWidth;
              final double trackLeft = w / 6;
              final double trackWidth = w * 2 / 3;
              final double nodeCenterY = (_pinSlot + 8) * s;

              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    left: trackLeft,
                    width: trackWidth,
                    top: nodeCenterY - 2 * s,
                    child: _Track(scale: s),
                  ),
                  Positioned(
                    left: trackLeft,
                    width: trackWidth * step.progress,
                    top: nodeCenterY - 2 * s,
                    child: _Track(scale: s, active: true),
                  ),
                  Positioned.fill(
                    child: Row(
                      children: <Widget>[
                        for (int i = 0; i < kTransportStops.length; i++)
                          Expanded(
                            child: _StopNode(
                              stop: kTransportStops[i],
                              index: i,
                              active: i == step.activeStop,
                              status: step.pickupStatus,
                              pinSlot: _pinSlot,
                              scale: s,
                              onTap: () => onSelectStop(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: AppSpacing.sm * s),
        _StopInfoBubble(step: step, scale: s),
      ],
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.scale, this.active = false});
  final double scale;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      height: 4 * s,
      decoration: BoxDecoration(
        color: active ? AppPalette.accentBlue : AppSlate.shade200,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

class _StopNode extends StatelessWidget {
  const _StopNode({
    required this.stop,
    required this.index,
    required this.active,
    required this.status,
    required this.pinSlot,
    required this.scale,
    required this.onTap,
  });

  final TransportStop stop;
  final int index;
  final bool active;
  final String status;
  final double pinSlot;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final bool pickup = stop.isPickup;
    final Color nameColor = pickup
        ? AppPalette.accentBlue
        : (index == 0 ? AppSlate.shade700 : AppSlate.shade500);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: pinSlot * s,
            child: active ? _BusPin(scale: s) : null,
          ),
          _nodeCircle(s, pickup),
          SizedBox(height: 6 * s),
          Text(
            stop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: pickup ? FontWeight.w700 : FontWeight.w600,
              color: nameColor,
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            pickup ? status : stop.time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9 * s,
              fontWeight: pickup ? FontWeight.w600 : FontWeight.w500,
              color: pickup ? AppPalette.statusGreen : AppSlate.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeCircle(double s, bool pickup) {
    if (pickup) {
      return Container(
        width: 16 * s,
        height: 16 * s,
        decoration: BoxDecoration(
          color: AppPalette.accentBlue,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFDBEAFE),
              spreadRadius: 3 * s,
              blurRadius: 0,
            ),
          ],
        ),
      );
    }
    return Container(
      width: 16 * s,
      height: 16 * s,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: index == 0 ? AppPalette.accentBlue : AppSlate.shade300,
          width: 3 * s,
        ),
      ),
    );
  }
}

class _BusPin extends StatelessWidget {
  const _BusPin({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return SizedBox(
      width: 32 * s,
      height: 32 * s,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              color: AppPalette.accentBlue.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 26 * s,
            height: 26 * s,
            decoration: BoxDecoration(
              color: AppPalette.accentBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2 * s),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6 * s,
                  offset: Offset(0, 2 * s),
                ),
              ],
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              size: 14 * s,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EtaBadge extends StatelessWidget {
  const _EtaBadge({
    required this.text,
    required this.scale,
    required this.onTap,
  });

  final String text;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.statusGreenBg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppPalette.statusGreenBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * s,
              vertical: AppSpacing.xs * s,
            ),
            child: Text(
              text,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w600,
                color: AppPalette.statusGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StopInfoBubble extends StatelessWidget {
  const _StopInfoBubble({required this.step, required this.scale});
  final TransportMilestone step;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md * s,
        vertical: 9 * s,
      ),
      decoration: BoxDecoration(
        color: AppSlate.shade50,
        borderRadius: BorderRadius.circular(AppRadii.small * s),
        border: Border.all(color: AppPalette.cardBorder),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 11 * s,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppSlate.shade600,
                ),
                children: <InlineSpan>[
                  const TextSpan(text: '📍 '),
                  TextSpan(
                    text: step.infoTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppSlate.shade800,
                    ),
                  ),
                  TextSpan(text: ' ${step.infoDetail}'),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSpacing.sm * s),
          Text(
            step.infoDistance,
            maxLines: 1,
            style: TextStyle(
              fontSize: 11 * s,
              fontWeight: FontWeight.w700,
              color: AppPalette.statusGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Quick actions + attendant
// ─────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.scale,
    required this.onEmergency,
    required this.onRadar,
  });

  final double scale;
  final VoidCallback onEmergency;
  final VoidCallback onRadar;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickActionCard(
            title: 'Emergency',
            subtitle: 'Report Issue',
            icon: Icons.warning_amber_rounded,
            background: const Color(0xFFFFF1F2),
            border: const Color(0xFFFECDD3),
            iconBackground: const Color(0xFFE11D48),
            titleColor: const Color(0xFF881337),
            subtitleColor: const Color(0xFFE11D48),
            scale: s,
            onTap: onEmergency,
          ),
        ),
        SizedBox(width: AppSpacing.md * s),
        Expanded(
          child: _QuickActionCard(
            title: 'Live Radar',
            subtitle: 'Expand GPS View',
            icon: Icons.map_outlined,
            background: const Color(0xFFEFF6FF),
            border: const Color(0xFFBFDBFE),
            iconBackground: AppPalette.accentBlue,
            titleColor: const Color(0xFF1E3A8A),
            subtitleColor: AppPalette.accentBlue,
            scale: s,
            onTap: onRadar,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.titleColor,
    required this.subtitleColor,
    required this.scale,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color titleColor;
  final Color subtitleColor;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md * s),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32 * s,
                  height: 32 * s,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(AppRadii.small * s),
                  ),
                  child: Icon(icon, size: 17 * s, color: Colors.white),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5 * s,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      ),
                    ],
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

class _AttendantCard extends StatelessWidget {
  const _AttendantCard({required this.scale, required this.onContact});
  final double scale;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final k = kTransport;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.block * s),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34 * s,
            height: 34 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppSlate.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: AppSlate.shade200),
            ),
            child: Text(
              k.attendantInitials,
              style: TextStyle(
                fontSize: 11 * s,
                fontWeight: FontWeight.w700,
                color: AppSlate.shade500,
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  k.attendantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5 * s,
                    fontWeight: FontWeight.w700,
                    color: AppSlate.shade800,
                  ),
                ),
                SizedBox(height: 1 * s),
                Text(
                  'Bus Attendant • Helper',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w500,
                    color: AppSlate.shade400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm * s),
          Material(
            color: AppPalette.maroonSurface,
            borderRadius: BorderRadius.circular(AppRadii.tiny * s),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onContact,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md * s,
                  vertical: 7 * s,
                ),
                child: Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.maroon800,
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
