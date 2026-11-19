import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_theme.dart' show AppShadows, AppSpacing;

/// The dashboard's feature card: the campus photograph carrying the school
/// motto.
///
/// The photograph ships with the app rather than being hot-linked, so the card
/// renders instantly and cannot break offline; the scrim is what carries the
/// motto over the bright sky and facade.
class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({super.key, required this.imageAsset});

  final String imageAsset;

  static const double _height = 144;
  static const double _radius = 16;
  static const double _padding = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    final double s = AppLayout.scaleOf(context);

    return Container(
      height: _height * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius * s),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: AppShadows.feature(s),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius * s),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Fallback while the photograph decodes.
            const ColoredBox(color: Color(0xFF1C1917)),
            Image.asset(imageAsset, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  // Never resolves to fully clear: without a floor the campus
                  // photograph goes washed out on wide layouts and the motto
                  // loses its contrast.
                  colors: <Color>[
                    Color(0xD9000000),
                    Color(0x80000000),
                    Color(0x26000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_padding * s),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Keep learning\nand keep growing',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22 * s,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4 * s,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 12 * s,
                        offset: Offset(0, 2 * s),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
