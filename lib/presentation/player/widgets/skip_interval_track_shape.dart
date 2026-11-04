import 'package:flutter/material.dart';
import '../../../../domain/anime.dart';

class SkipIntervalTrackShape extends RoundedRectSliderTrackShape {
  final List<SkipIntervalDb>? intervals;
  final double durationInSeconds;
  final Color skipColor;
  final Color activeFallbackColor;
  final Color inactiveFallbackColor;
  final double gapWidth;

  SkipIntervalTrackShape({
    required this.intervals,
    required this.durationInSeconds,
    required this.skipColor,
    required this.activeFallbackColor,
    required this.inactiveFallbackColor,
    this.gapWidth = 3.0,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
    double additionalActiveTrackHeight =
        2.0,
  }) {
    // Nothing to draw until the duration is known.
    if (durationInSeconds <= 0) return;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Canvas canvas = context.canvas;

    // Prefer the slider theme, then the caller's fallbacks.
    final Color activeColor =
        sliderTheme.activeTrackColor ?? activeFallbackColor;
    final Color inactiveColor =
        sliderTheme.inactiveTrackColor ?? inactiveFallbackColor;

    // No skip intervals: draw a normal track.
    if (intervals == null || intervals!.isEmpty) {
      _drawSegment(canvas, trackRect.left, trackRect.right, trackRect,
          thumbCenter.dx, activeColor, inactiveColor);
      return;
    }

    double currentX = trackRect.left;

    final sortedIntervals = List<SkipIntervalDb>.from(intervals!)
      ..sort((a, b) => (a.startTime ?? 0).compareTo(b.startTime ?? 0));

    for (var interval in sortedIntervals) {
      if (interval.startTime == null || interval.endTime == null) continue;

      double startPercent =
          (interval.startTime! / durationInSeconds).clamp(0.0, 1.0);
      double endPercent =
          (interval.endTime! / durationInSeconds).clamp(0.0, 1.0);

      double skipStartX = (trackRect.left + trackRect.width * startPercent)
          .clamp(trackRect.left, trackRect.right);
      double skipEndX = (trackRect.left + trackRect.width * endPercent)
          .clamp(trackRect.left, trackRect.right);

      // Leave a gap before the OP/ED segment.
      if (skipStartX - (gapWidth / 2) > currentX) {
        _drawSegment(canvas, currentX, skipStartX - (gapWidth / 2), trackRect,
            thumbCenter.dx, activeColor, inactiveColor);
      }

      // Draw the OP/ED segment with a gap on both sides.
      if (skipEndX - (gapWidth / 2) > skipStartX + (gapWidth / 2)) {
        _drawSegment(
            canvas,
            skipStartX + (gapWidth / 2),
            skipEndX - (gapWidth / 2),
            trackRect,
            thumbCenter.dx,
            activeColor,
            skipColor,
            );
      }

      currentX = skipEndX + (gapWidth / 2);
    }

    if (currentX < trackRect.right) {
      _drawSegment(canvas, currentX, trackRect.right, trackRect, thumbCenter.dx,
          activeColor, inactiveColor);
    }
  }

  // Draws one track segment, split at the thumb.
  void _drawSegment(Canvas canvas, double left, double right, Rect trackRect,
      double thumbX, Color activeCol, Color inactiveCol) {
    if (left >= right) return;

    final double radius = trackRect.height / 2;

    // Watched part.
    double activeRight =
        left < thumbX ? (right < thumbX ? right : thumbX) : left;

    if (activeRight > left) {
      final RRect activeRRect = RRect.fromLTRBR(left, trackRect.top,
          activeRight, trackRect.bottom, Radius.circular(radius));
      canvas.drawRRect(activeRRect, Paint()..color = activeCol);
    }

    // Unwatched part.
    double inactiveLeft =
        right > thumbX ? (left > thumbX ? left : thumbX) : right;

    if (inactiveLeft < right) {
      final RRect inactiveRRect = RRect.fromLTRBR(inactiveLeft, trackRect.top,
          right, trackRect.bottom, Radius.circular(radius));
      canvas.drawRRect(inactiveRRect, Paint()..color = inactiveCol);
    }
  }
}
