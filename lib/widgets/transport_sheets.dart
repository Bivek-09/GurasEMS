import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';
import '../models/transport_data.dart';

// ─────────────────────────────────────────────────────────────────────────
// Call confirmation — driver / attendant
// ─────────────────────────────────────────────────────────────────────────

/// Bottom sheet that confirms a phone call, mirroring the reference's
/// "Call Driver" and "Contact Bus Attendant" modals.
///
/// Pops `true` when the call is confirmed, `false` when cancelled and `null`
/// when dismissed by dragging or tapping the scrim.
class TransportCallSheet extends StatelessWidget {
  const TransportCallSheet({
    super.key,
    required this.title,
    required this.lead,
    required this.name,
    required this.trail,
    required this.number,
    required this.confirmLabel,
    required this.accent,
    required this.accentSurface,
    this.icon,
    this.initials,
  });

  final String title;

  /// Copy around the bolded [name], e.g. `Calling ` … ` for Bus No. 3`.
  final String lead;
  final String name;
  final String trail;

  /// International number, shown large and in the accent colour.
  final String number;
  final String confirmLabel;
  final Color accent;
  final Color accentSurface;

  /// Mutually exclusive avatar content: an [icon] or short [initials].
  final IconData? icon;
  final String? initials;

  /// Opens the sheet and resolves with the caller's confirmation.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String lead,
    required String name,
    required String trail,
    required String number,
    required String confirmLabel,
    required Color accent,
    required Color accentSurface,
    IconData? icon,
    String? initials,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => TransportCallSheet(
        title: title,
        lead: lead,
        name: name,
        trail: trail,
        number: number,
        confirmLabel: confirmLabel,
        accent: accent,
        accentSurface: accentSurface,
        icon: icon,
        initials: initials,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.all(12 * s),
        padding: EdgeInsets.fromLTRB(20 * s, 22 * s, 20 * s, 20 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * s),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56 * s,
              height: 56 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentSurface,
                shape: BoxShape.circle,
              ),
              child: icon != null
                  ? Icon(icon, size: 26 * s, color: accent)
                  : Text(
                      initials ?? '',
                      style: TextStyle(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
            ),
            SizedBox(height: 14 * s),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6 * s),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12 * s,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
                children: <InlineSpan>[
                  TextSpan(text: lead),
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextSpan(text: trail),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6 * s),
            Text(
              number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4 * s,
                color: accent,
              ),
            ),
            SizedBox(height: 20 * s),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 46 * s,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF475569),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * s),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: SizedBox(
                    height: 46 * s,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * s),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: TextStyle(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Emergency sheet
// ─────────────────────────────────────────────────────────────────────────

/// Bottom sheet that dispatches an urgent transport alert, mirroring the
/// reference's "Transport Emergency Alert" sheet.
///
/// Pops the chosen [EmergencyReason] on submit, or `null` when cancelled.
class TransportEmergencySheet extends StatefulWidget {
  const TransportEmergencySheet({super.key});

  static const Color _rose = Color(0xFFE11D48);
  static const Color _roseDark = Color(0xFF881337);
  static const Color _roseSurface = Color(0xFFFFF1F2);

  /// Opens the sheet and resolves with the selected reason.
  static Future<EmergencyReason?> show(BuildContext context) {
    return showModalBottomSheet<EmergencyReason>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const TransportEmergencySheet(),
    );
  }

  @override
  State<TransportEmergencySheet> createState() =>
      _TransportEmergencySheetState();
}

class _TransportEmergencySheetState extends State<TransportEmergencySheet> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28 * s)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 18 * s, 18 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 28 * s,
                    height: 28 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: TransportEmergencySheet._rose,
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                    child: Text(
                      '!',
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: Text(
                      'Transport Emergency Alert',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30 * s,
                    height: 30 * s,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18 * s,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * s),
              Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9)),
              SizedBox(height: 12 * s),
              Text(
                'Choose the category to immediately alert School Transport '
                'Dispatch & Guardians:',
                style: TextStyle(
                  fontSize: 11 * s,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 12 * s),
              _optionRow(s, 0, 1),
              SizedBox(height: 8 * s),
              _optionRow(s, 2, 3),
              SizedBox(height: 16 * s),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 46 * s,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF475569),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46 * s,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context)
                                .pop(kEmergencyReasons[_selected]),
                        style: FilledButton.styleFrom(
                          backgroundColor: TransportEmergencySheet._rose,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                        ),
                        child: Text(
                          'Submit Urgent Alert',
                          style: TextStyle(
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionRow(double s, int first, int second) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _EmergencyOption(
            reason: kEmergencyReasons[first],
            active: _selected == first,
            scale: s,
            onTap: () => setState(() => _selected = first),
          ),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: _EmergencyOption(
            reason: kEmergencyReasons[second],
            active: _selected == second,
            scale: s,
            onTap: () => setState(() => _selected = second),
          ),
        ),
      ],
    );
  }
}

class _EmergencyOption extends StatelessWidget {
  const _EmergencyOption({
    required this.reason,
    required this.active,
    required this.scale,
    required this.onTap,
  });

  final EmergencyReason reason;
  final bool active;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: active ? TransportEmergencySheet._roseSurface : Colors.white,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
              color: active
                  ? TransportEmergencySheet._rose
                  : const Color(0xFFE2E8F0),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Text(
            '${reason.emoji} ${reason.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5 * s,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              color: active
                  ? TransportEmergencySheet._roseDark
                  : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Live radar sheet
// ─────────────────────────────────────────────────────────────────────────

/// Simulated GPS map, mirroring the reference's "Live GPS Radar" modal.
///
/// Zoom and layer controls are live and confirm through an in-card toast, so
/// feedback stays visible while the sheet is open.
class TransportRadarSheet extends StatefulWidget {
  const TransportRadarSheet({super.key});

  /// Opens the radar sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const TransportRadarSheet(),
    );
  }

  @override
  State<TransportRadarSheet> createState() => _TransportRadarSheetState();
}

class _TransportRadarSheetState extends State<TransportRadarSheet> {
  double _zoom = 1;
  bool _satellite = false;

  String? _message;
  Timer? _messageTimer;

  void _flash(String message) {
    if (!mounted) return;
    setState(() => _message = message);
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _zoomBy(double delta) {
    setState(() => _zoom = (_zoom + delta).clamp(0.8, 1.4));
    _flash('Map Zoom: ${(_zoom * 100).round()}%');
  }

  void _toggleLayer() {
    setState(() => _satellite = !_satellite);
    _flash(
      _satellite ? 'Switched to Satellite View' : 'Switched to Streets View',
    );
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28 * s)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 16 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Live GPS Radar',
                          style: TextStyle(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 3 * s),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 6 * s,
                              height: 6 * s,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4 * s),
                            Flexible(
                              child: Text(
                                'GPS Lock • 26.4525° N, 87.2718° E',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10 * s,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  SizedBox(
                    width: 32 * s,
                    height: 32 * s,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close_rounded,
                          size: 19 * s,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              SizedBox(
                height: 216 * s,
                child: _RadarMap(
                  satellite: _satellite,
                  zoom: _zoom,
                  scale: s,
                  onZoomIn: () => _zoomBy(0.15),
                  onZoomOut: () => _zoomBy(-0.15),
                  onToggleLayer: _toggleLayer,
                ),
              ),
              SizedBox(height: 12 * s),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                        children: const <InlineSpan>[
                          TextSpan(text: 'Next Stop: '),
                          TextSpan(
                            text: 'School Gate',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                      children: const <InlineSpan>[
                        TextSpan(text: 'ETA: '),
                        TextSpan(
                          text: '~15 mins',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              SizedBox(
                height: 44 * s,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.maroon800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * s),
                    ),
                  ),
                  child: Text(
                    'Back to Route Summary',
                    style: TextStyle(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              SizedBox(
                height: 32 * s,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _message == null ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * s,
                        vertical: 8 * s,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _message ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5 * s,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
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

class _RadarMap extends StatelessWidget {
  const _RadarMap({
    required this.satellite,
    required this.zoom,
    required this.scale,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleLayer,
  });

  final bool satellite;
  final double zoom;
  final double scale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleLayer;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final Color background = satellite
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final Color grid = satellite
        ? Colors.white.withValues(alpha: 0.18)
        : const Color(0xFF94A3B8).withValues(alpha: 0.55);
    final Color diagonal = satellite
        ? Colors.white.withValues(alpha: 0.14)
        : const Color(0xFFCBD5E1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20 * s),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DotGridPainter(
                      color: grid,
                      spacing: 16 * s,
                      radius: 0.9 * s,
                    ),
                  ),
                ),
                // Diagonal avenue.
                Positioned(
                  top: h * 0.5 - 6 * s,
                  left: -24,
                  width: w + 48,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: Container(height: 12 * s, color: diagonal),
                  ),
                ),
                // Two cross streets.
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: w * 0.32,
                  child: Container(
                    width: 14 * s,
                    color: satellite
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: w * 0.66,
                  child: Container(
                    width: 10 * s,
                    color: satellite
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFBFDBFE),
                  ),
                ),
                Positioned(
                  top: 12 * s,
                  left: 12 * s,
                  child: _MapTag(text: '🏫 School', scale: s),
                ),
                Positioned(
                  bottom: 12 * s,
                  right: 12 * s,
                  child: _MapTag(text: '🏢 Depot', scale: s),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: zoom,
                    child: _RadarBusPin(scale: s),
                  ),
                ),
                Positioned(
                  top: 8 * s,
                  right: 8 * s,
                  child: Column(
                    children: <Widget>[
                      _MapButton(label: '+', scale: s, onTap: onZoomIn),
                      SizedBox(height: 6 * s),
                      _MapButton(label: '−', scale: s, onTap: onZoomOut),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8 * s,
                  left: 8 * s,
                  child: _MapLayerButton(
                    satellite: satellite,
                    scale: s,
                    onTap: onToggleLayer,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RadarBusPin extends StatelessWidget {
  const _RadarBusPin({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 44 * s,
          height: 44 * s,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Static radar halo in place of the reference's CSS pulse.
              Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 34 * s,
                height: 34 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2 * s),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8 * s,
                      offset: Offset(0, 3 * s),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  size: 18 * s,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4 * s),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Bus No. 3 (Arriving)',
            maxLines: 1,
            style: TextStyle(
              fontSize: 9 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapTag extends StatelessWidget {
  const _MapTag({required this.text, required this.scale});
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 3 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(6 * s),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          fontSize: 9 * s,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 26 * s,
          height: 26 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6 * s),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapLayerButton extends StatelessWidget {
  const _MapLayerButton({
    required this.satellite,
    required this.scale,
    required this.onTap,
  });

  final bool satellite;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double s = scale;

    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(6 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 4 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6 * s),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            satellite ? 'Layer: Satellite' : 'Layer: Streets',
            maxLines: 1,
            style: TextStyle(
              fontSize: 9 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dotted street-grid texture painted behind the radar map.
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({
    required this.color,
    required this.spacing,
    required this.radius,
  });

  final Color color;
  final double spacing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.radius != radius;
}
