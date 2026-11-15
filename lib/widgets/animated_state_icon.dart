import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// A fixed footprint keeps neighbouring controls still during state changes.
class AnimatedStateIcon extends StatelessWidget {
  const AnimatedStateIcon(this.icon, {super.key, this.size, this.color});
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.resolveDuration(context, AppMotion.medium);
    if (duration == Duration.zero) {
      return Icon(icon, size: size, color: color);
    }
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color ?? IconTheme.of(context).color),
      duration: duration,
      curve: AppMotion.enter,
      builder: (context, value, _) => AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        child: Icon(icon, key: ValueKey(icon), size: size, color: value),
      ),
    );
  }
}
