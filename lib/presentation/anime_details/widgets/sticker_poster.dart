import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_motion.dart';
import '../../../theme/app_theme_extension.dart';

/// Adds a touch gesture to the poster on the compact details screen.
class StickerPoster extends StatelessWidget {
  const StickerPoster({super.key, required this.child});

  final Widget child;

  static bool supportsPlatform(BuildContext context) =>
      switch (Theme.of(context).platform) {
        TargetPlatform.android || TargetPlatform.iOS => true,
        _ => false,
      };

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReduced(context) || !supportsPlatform(context)) {
      return child;
    }
    return _PeelGesture(child: child);
  }
}

class _PeelGesture extends StatefulWidget {
  const _PeelGesture({required this.child});

  final Widget child;

  @override
  State<_PeelGesture> createState() => _PeelGestureState();
}

class _PeelGestureState extends State<_PeelGesture>
    with SingleTickerProviderStateMixin {
  static const _corners = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ];
  static const _pullLimit = 44.0;

  late final _release = AnimationController(vsync: this);
  Alignment _corner = Alignment.topRight;
  Offset _pull = Offset.zero;
  bool _dragging = false;

  @override
  void dispose() {
    _release.dispose();
    super.dispose();
  }

  void _start(Alignment corner) {
    if (_dragging) return;
    _dragging = true;
    setState(() {
      _pull = _corner == corner ? _pull * _release.value : Offset.zero;
      _corner = corner;
      _release.value = 1;
    });
  }

  void _update(Alignment corner, DragUpdateDetails details) {
    if (!_dragging || corner != _corner) return;
    final next = _pull + details.delta;
    setState(() {
      _pull = next.distance <= _pullLimit
          ? next
          : next / next.distance * _pullLimit;
    });
  }

  void _finish(Alignment corner) {
    if (!_dragging || corner != _corner) return;
    _dragging = false;
    _release.animateBack(0, duration: AppMotion.slow, curve: AppMotion.enter);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md);
    final edgeColor = Theme.of(context).colorScheme.onSurface;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _release,
          child: RepaintBoundary(child: widget.child),
          builder: (context, child) {
            final pull = _pull * _release.value / _pullLimit;
            final lift = pull.distance;
            final turn = (_corner.x * pull.dy - _corner.y * pull.dx) * .07;
            final transform = Matrix4.identity();
            if (lift > 0) {
              transform
                ..setEntry(3, 2, .00065)
                ..translateByDouble(pull.dx * 7, pull.dy * 5 - lift * 3, 0, 1)
                ..rotateZ(turn)
                ..rotateX(_corner.y * lift * -.09)
                ..rotateY(_corner.x * lift * .11);
            }
            return Transform(
              alignment: Alignment(-_corner.x, -_corner.y),
              transform: transform,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    if (lift > 0)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: lift * .48),
                        blurRadius: 16 * lift,
                        offset: Offset(0, 9 * lift),
                      ),
                  ],
                ),
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: lift > 0
                        ? Border.all(
                            color: edgeColor.withValues(alpha: lift * .36),
                          )
                        : null,
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
        for (final corner in _corners)
          Align(
            alignment: corner,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _CornerDragRecognizer:
                    GestureRecognizerFactoryWithHandlers<_CornerDragRecognizer>(
                      _CornerDragRecognizer.new,
                      (gesture) {
                        gesture.onStart = (_) => _start(corner);
                        gesture.onUpdate = (event) => _update(corner, event);
                        gesture.onEnd = (_) => _finish(corner);
                        gesture.onCancel = () => _finish(corner);
                      },
                    ),
              },
              child: const SizedBox.square(dimension: 44),
            ),
          ),
      ],
    );
  }
}

class _CornerDragRecognizer extends PanGestureRecognizer {
  _CornerDragRecognizer()
    : super(supportedDevices: const {PointerDeviceKind.touch}) {
    dragStartBehavior = DragStartBehavior.down;
  }

  // A touch on a corner is an explicit grab. Claim it before the enclosing
  // vertical scroll can turn it into page stretch. Other touches never reach
  // this recognizer, so normal scrolling and overscroll keep their behavior.
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
