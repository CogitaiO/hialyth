import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_motion.dart';

/// State changes stay quiet; tactile feedback belongs to the button itself.
class AnimatedPlayPauseIcon extends StatelessWidget {
  const AnimatedPlayPauseIcon({
    super.key,
    required this.playing,
    this.size,
    this.color,
  });

  final bool playing;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      playing ? AppIcons.transportPause : AppIcons.transportPlay,
      key: ValueKey(playing),
      size: size,
      color: color,
    );
    if (MediaQuery.disableAnimationsOf(context)) return glyph;
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      // Each outgoing fade keeps its own identity during rapid toggles.
      transitionBuilder: (child, opacity) => FadeTransition(
        key: ObjectKey(opacity),
        opacity: opacity,
        child: child,
      ),
      child: glyph,
    );
  }
}
