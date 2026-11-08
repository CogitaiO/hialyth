import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../domain/anime.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme_extension.dart';
import 'skip_interval_track_shape.dart';

/// Smooths small playback samples locally; seeks and backward jumps stay instant.
/// Animation ticks rebuild only the slider, never the video or transport row.
class PlaybackTimeline extends StatefulWidget {
  const PlaybackTimeline({
    super.key,
    required this.position,
    required this.duration,
    required this.playing,
    required this.onSeek,
    this.intervals = const [],
  });

  final Duration position;
  final Duration duration;
  final bool playing;
  final ValueChanged<Duration> onSeek;
  final List<SkipIntervalDb> intervals;

  @override
  State<PlaybackTimeline> createState() => _PlaybackTimelineState();
}

class _PlaybackTimelineState extends State<PlaybackTimeline> {
  double? _dragValue;
  double? _pendingSeek;
  Timer? _seekTimeout;
  bool _hovering = false;
  bool _animate = false;
  Duration? _lastSampleAt;
  int _sampleIntervalMs = 200;

  @override
  void didUpdateWidget(PlaybackTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    final delta = widget.position - oldWidget.position;
    if (delta != Duration.zero) {
      final now = SchedulerBinding.instance.currentFrameTimeStamp;
      if (_lastSampleAt != null) {
        final elapsed = (now - _lastSampleAt!).inMilliseconds;
        if (elapsed > 0) _sampleIntervalMs = elapsed.clamp(16, 250);
      }
      _lastSampleAt = now;
    }
    _animate = widget.playing &&
        delta > Duration.zero &&
        delta <= const Duration(seconds: 1) &&
        _pendingSeek == null;
    if (_pendingSeek != null &&
        (widget.position.inMilliseconds - _pendingSeek!).abs() < 250) {
      _pendingSeek = null;
      _seekTimeout?.cancel();
    }
  }

  @override
  void dispose() {
    _seekTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maximum = widget.duration.inMilliseconds.toDouble();
    final position = (_dragValue ??
            _pendingSeek ??
            widget.position.inMilliseconds.toDouble())
        .clamp(0.0, maximum > 0 ? maximum : 1.0);
    final accent = Theme.of(context).colorScheme.primary;
    final tokens = context.appTheme;
    final active = _hovering || _dragValue != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: SizedBox(
          height: 28,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: active ? 4 : 2,
              thumbShape:
                  RoundSliderThumbShape(enabledThumbRadius: active ? 6 : 0),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: accent,
              inactiveTrackColor: tokens.borderStrong,
              thumbColor: accent,
              trackShape: SkipIntervalTrackShape(
                intervals: widget.intervals,
                durationInSeconds: maximum / 1000,
                skipColor: AppPalette.skipMarker,
                activeFallbackColor: accent,
                inactiveFallbackColor: tokens.borderStrong,
              ),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: position),
              duration: _animate &&
                      _dragValue == null &&
                      _pendingSeek == null &&
                      !MediaQuery.disableAnimationsOf(context)
                  ? Duration(milliseconds: _sampleIntervalMs)
                  : Duration.zero,
              curve: Curves.linear,
              builder: (context, value, _) => Slider(
                value: value.clamp(0, maximum > 0 ? maximum : 1),
                max: maximum > 0 ? maximum : 1,
                onChangeStart: maximum <= 0
                    ? null
                    : (value) {
                        _seekTimeout?.cancel();
                        setState(() {
                          _dragValue = value;
                          _pendingSeek = null;
                        });
                      },
                onChanged: maximum <= 0
                    ? null
                    : (value) => setState(() => _dragValue = value),
                onChangeEnd: maximum <= 0
                    ? null
                    : (value) {
                        setState(() {
                          _pendingSeek = value;
                          _dragValue = null;
                        });
                        _seekTimeout = Timer(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _pendingSeek = null);
                        });
                        widget.onSeek(Duration(milliseconds: value.round()));
                      },
              ),
            ),
          )),
    );
  }
}
