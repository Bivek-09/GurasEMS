import 'package:flutter/material.dart';

/// Plays a one-shot entrance for a vertical stack of dashboard blocks.
///
/// Each child fades in and rises a few pixels, offset slightly from the one
/// above, so the dashboard assembles instead of appearing all at once. A single
/// [AnimationController] drives every stage, so there are no per-item timers to
/// leak, and the reveal runs exactly once — returning to Home does not replay
/// it, because the [State] (and therefore the completed controller) survives.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 520),
    this.stagger = 0.12,
    this.rise = 0.06,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  /// Blocks to reveal, top to bottom.
  final List<Widget> children;

  /// Length of the whole reveal.
  final Duration duration;

  /// Fraction of [duration] each subsequent child is offset by.
  final double stagger;

  /// How far each child rises, as a fraction of its own height.
  final double rise;

  /// Forwarded to the inner [Column] so full-width cards keep stretching.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Stage for child [index]. The start is clamped so the last child still gets
  /// a usable window even when the list is long.
  Animation<double> _stage(int index) {
    final double start = (widget.stagger * index).clamp(0.0, 0.75);
    return _controller.drive(
      CurveTween(curve: Interval(start, 1, curve: Curves.easeOutCubic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      return Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children,
      );
    }

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: <Widget>[
        for (int i = 0; i < widget.children.length; i++)
          FadeTransition(
            opacity: _stage(i),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, widget.rise),
                end: Offset.zero,
              ).animate(_stage(i)),
              child: widget.children[i],
            ),
          ),
      ],
    );
  }
}
