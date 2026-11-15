import 'package:flutter/material.dart';

/// Fades player controls while keeping fully transparent or hidden controls
/// out of hit testing and semantics. Reversing the controller retargets from
/// its current opacity when visibility changes during an animation.
class PlayerControlFade extends StatefulWidget {
  const PlayerControlFade({
    super.key,
    required this.visible,
    required this.duration,
    required this.child,
    this.curve = Curves.easeOutCubic,
  });

  final bool visible;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  State<PlayerControlFade> createState() => _PlayerControlFadeState();
}

class _PlayerControlFadeState extends State<PlayerControlFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.visible ? 1 : 0,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(covariant PlayerControlFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (oldWidget.curve != widget.curve) {
      _opacity = CurvedAnimation(parent: _controller, curve: widget.curve);
    }
    if (oldWidget.visible != widget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _opacity,
    child: widget.child,
    builder: (context, child) {
      final hidden = !widget.visible || _opacity.value == 0;
      return IgnorePointer(
        ignoring: hidden,
        child: ExcludeSemantics(
          excluding: hidden,
          child: FadeTransition(
            key: const ValueKey('player-control-fade'),
            opacity: _opacity,
            child: child,
          ),
        ),
      );
    },
  );
}
