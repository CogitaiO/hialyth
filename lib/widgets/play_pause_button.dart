import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme_extension.dart';
import 'animated_play_pause_icon.dart';

/// A borderless transport button with independent press and playback timelines.
/// The fixed hit target doesn't shrink with the painted surface.
class PlayPauseButton extends StatefulWidget {
  const PlayPauseButton({
    super.key,
    required this.playing,
    required this.tooltip,
    required this.onPressed,
    this.size = 80,
    this.iconSize = 52,
  });

  final bool playing;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin {
  final _states = WidgetStatesController();
  late final AnimationController _feedback;
  Timer? _release;
  int? _pointer;
  bool _held = false;
  bool _reduceMotion = false;

  bool get _highlighted =>
      _states.value.contains(WidgetState.focused) ||
      _states.value.contains(WidgetState.hovered);

  @override
  void initState() {
    super.initState();
    _feedback = AnimationController(vsync: this);
    _states.addListener(_updateFeedback);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AppMotion.isReduced(context);
    if (reduced != _reduceMotion) {
      _reduceMotion = reduced;
      _release?.cancel();
      _feedback.value = _held ? 1 : (_highlighted ? .35 : 0);
    }
  }

  void _animateTo(double target) {
    if (_reduceMotion) {
      _feedback.value = target;
    } else {
      _feedback.animateTo(
        target,
        duration: target > _feedback.value
            ? AppMotion.pressIn
            : AppMotion.pressOut,
        curve: AppMotion.enter,
      );
    }
  }

  void _updateFeedback() {
    final held =
        _pointer != null || _states.value.contains(WidgetState.pressed);
    final wasHeld = _held;
    _held = held;
    if (held) {
      _release?.cancel();
      if (!wasHeld) _animateTo(1);
    } else if (wasHeld && !_reduceMotion) {
      // A quick tap still reaches its highlighted frame. The command itself
      // is never delayed: this timer only controls the visual release.
      _release?.cancel();
      _release = Timer(AppMotion.pressHold, () {
        _release = null;
        _animateTo(_highlighted ? .35 : 0);
      });
    } else if (_release == null || !_release!.isActive) {
      _animateTo(_highlighted ? .35 : 0);
    }
  }

  void _endPointer(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    _updateFeedback();
  }

  @override
  void dispose() {
    _release?.cancel();
    _states.removeListener(_updateFeedback);
    _states.dispose();
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return SizedBox.square(
      dimension: widget.size,
      child: Listener(
        onPointerDown: (event) {
          if (_pointer != null || event.buttons != kPrimaryButton) return;
          _pointer = event.pointer;
          _updateFeedback();
        },
        onPointerUp: _endPointer,
        onPointerCancel: _endPointer,
        child: AnimatedBuilder(
          animation: _feedback,
          builder: (context, child) {
            final value = _feedback.value;
            final surface = Color.lerp(
              Colors.black54,
              const Color(0xCC383838),
              value,
            );
            return Transform.scale(
              scale: _reduceMotion ? 1 : 1 - .03 * value,
              transformHitTests: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surface,
                  border: Border.all(
                    color: Color.lerp(Colors.white24, Colors.white70, value)!,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: IconButton(
            statesController: _states,
            tooltip: widget.tooltip,
            onPressed: widget.onPressed,
            iconSize: widget.iconSize,
            style: IconButton.styleFrom(
              fixedSize: Size.square(widget.size),
              foregroundColor: tokens.textPrimary,
              backgroundColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              side: BorderSide.none,
              shape: const CircleBorder(),
            ),
            icon: AnimatedPlayPauseIcon(playing: widget.playing),
          ),
        ),
      ),
    );
  }
}
