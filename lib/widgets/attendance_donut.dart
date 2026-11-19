import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_palette.dart';

/// Circular attendance ring with the percentage readout in the middle,
/// matching the reference's SVG donut.
class AttendanceDonut extends StatelessWidget {
  const AttendanceDonut({super.key, required this.percent});

  final int percent;

  static const Color _track = AppGray.shade200;
  static const Color _progress = AppPalette.success;
  static const double _stroke = 10;
  static const double _diameter = 112;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);
    final double size = _diameter * s;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              strokeWidth: _stroke * s,
              backgroundColor: _track,
              valueColor: const AlwaysStoppedAnimation<Color>(_progress),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: AppPalette.headingText,
                ),
              ),
              Text(
                'Attendance',
                style: TextStyle(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: AppGray.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
