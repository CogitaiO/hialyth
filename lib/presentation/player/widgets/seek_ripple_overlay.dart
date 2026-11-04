import 'package:flutter/material.dart';
import '../../../theme/app_theme_extension.dart';

class SeekRippleOverlay extends StatefulWidget {
  final bool isLeft;
  final bool isRight;
  final int seconds;

  const SeekRippleOverlay({
    super.key,
    required this.isLeft,
    required this.isRight,
    required this.seconds,
  });

  @override
  State<SeekRippleOverlay> createState() => _SeekRippleOverlayState();
}

class _SeekRippleOverlayState extends State<SeekRippleOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _rippleController;

  late final AnimationController _textPulseController;

  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;

  late final Animation<double> _arrow1;
  late final Animation<double> _arrow2;
  late final Animation<double> _arrow3;

  late final Animation<double> _textScale;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textPulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _rippleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCubic),
    );
    _rippleOpacity = Tween<double>(begin: 0.25, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Each arrow fades in, holds, then fades out.
    Animation<double> buildArrowAnimation(double startDelay) {
      return TweenSequence<double>([
        TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
        TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 30),
        TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.0), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _rippleController,
          curve: Interval(startDelay, startDelay + 0.6, curve: Curves.linear),
        ),
      );
    }

    _arrow1 = buildArrowAnimation(0.0);
    _arrow2 = buildArrowAnimation(0.15);
    _arrow3 = buildArrowAnimation(0.30);

    _textScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _textPulseController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant SeekRippleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart both animations for each new seek.
    if (widget.seconds != oldWidget.seconds && widget.seconds != 0) {
      _rippleController.forward(from: 0.0);
      _textPulseController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _textPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.isLeft) _buildSide(isRight: false),

          if (widget.isRight) _buildSide(isRight: true),
        ],
      ),
    );
  }

  Widget _buildSide({required bool isRight}) {
    final tokens = context.appTheme;
    // Scale from the edge being seeked.
    final align = isRight ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: FractionallySizedBox(
        widthFactor: 0.35,
        heightFactor: 1.0,
        child: Stack(
          alignment: align,
          children: [
            ScaleTransition(
              alignment: align,
              scale: _rippleScale,
              child: FadeTransition(
                opacity: _rippleOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    color: tokens
                        .textPrimary, // Opacity is animated by FadeTransition (peak 0.25).
                    borderRadius: BorderRadius.only(
                      topLeft:
                          isRight ? const Radius.circular(1000) : Radius.zero,
                      bottomLeft:
                          isRight ? const Radius.circular(1000) : Radius.zero,
                      topRight:
                          !isRight ? const Radius.circular(1000) : Radius.zero,
                      bottomRight:
                          !isRight ? const Radius.circular(1000) : Radius.zero,
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconSequence(isRight: isRight),
                  const SizedBox(height: AppSpacing.sm),
                  _buildLabelLayer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSequence({required bool isRight}) {
    // Mirror the arrow when seeking backward.
    Widget buildArrow(bool right) {
      return Transform.scale(
        scaleX: right ? 1.0 : -1.0,
        child: Icon(
          Icons.play_arrow_rounded,
          color: context.appTheme.textPrimary,
          size: 36,
        ),
      );
    }

    // Reverse the sequence for backward seeks so the nearest arrow lights first.
    List<Widget> arrows = [
      FadeTransition(opacity: _arrow1, child: buildArrow(isRight)),
      FadeTransition(opacity: _arrow2, child: buildArrow(isRight)),
      FadeTransition(opacity: _arrow3, child: buildArrow(isRight)),
    ];

    if (!isRight) {
      arrows = arrows.reversed.toList();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: arrows,
    );
  }

  Widget _buildLabelLayer() {
    return ScaleTransition(
      scale: _textScale,
      child: Text(
        "${widget.seconds > 0 ? '+' : ''}${widget.seconds} sec",
        style: TextStyle(
          color: context.appTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: context.appTheme.scrim(0.54),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
