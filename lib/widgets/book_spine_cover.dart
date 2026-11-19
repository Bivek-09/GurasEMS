import 'package:flutter/material.dart';

import '../models/library_book.dart';

/// The painted cover of a book row.
///
/// Reproduces the reference's treatment: a diagonal gradient, a dark spine
/// shading down the binding edge, a small publisher tag, a centre glyph and a
/// caption. Sized by the caller because the issued cards and the catalogue use
/// slightly different proportions.
class BookSpineCover extends StatelessWidget {
  const BookSpineCover({
    super.key,
    required this.cover,
    required this.scale,
    this.width = 66,
    this.height = 88,
  });

  final BookCover cover;
  final double scale;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double s = scale;
    final double w = width * s;
    final double h = height * s;
    final double radius = 8 * s;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            cover.start,
            if (cover.mid != null) cover.mid!,
            cover.end,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6 * s,
            offset: Offset(0, 3 * s),
          ),
          BoxShadow(
            color: cover.start.withValues(alpha: 0.28),
            blurRadius: 10 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: <Widget>[
            // Binding-edge shading, replacing the mock's inset box-shadow.
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: w * 0.18,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[Color(0x59000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4 * s,
                      vertical: 1 * s,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(3 * s),
                    ),
                    child: Text(
                      cover.tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 6.5 * s,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4 * s,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            cover.glyph,
                            size: 16 * s,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                          if (cover.label.isNotEmpty) ...<Widget>[
                            SizedBox(height: 3 * s),
                            Text(
                              cover.label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 7.5 * s,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (cover.footer.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 3 * s),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                        ),
                      ),
                      child: Text(
                        cover.footer,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 6 * s,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2 * s,
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
