import 'package:flutter/scheduler.dart';
import 'logger.dart';

/// Opt-in diagnostics for profile runs. This measures Flutter work, not decoded
/// video FPS. Build/raster durations are separate because the pipeline overlaps.
bool _started = false;

void startFrameMetrics() {
  if (_started || !const bool.fromEnvironment('profileFrames')) return;
  _started = true;
  final build = <int>[];
  final raster = <int>[];
  var overBudget = 0;
  SchedulerBinding.instance.addTimingsCallback((frames) {
    for (final frame in frames) {
      build.add(frame.buildDuration.inMicroseconds);
      raster.add(frame.rasterDuration.inMicroseconds);
      if (frame.buildDuration.inMicroseconds > 16667 ||
          frame.rasterDuration.inMicroseconds > 16667) {
        overBudget++;
      }
    }
    if (build.length < 120) return;
    build.sort();
    raster.sort();
    final index = ((build.length - 1) * .95).round();
    talker.info(
        'Flutter frame timing: samples=${build.length}, UI p95=${(build[index] / 1000).toStringAsFixed(2)}ms, raster p95=${(raster[index] / 1000).toStringAsFixed(2)}ms, over 60Hz budget=$overBudget');
    build.clear();
    raster.clear();
    overBudget = 0;
  });
}
