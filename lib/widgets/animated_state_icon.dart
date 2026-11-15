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
    if (MediaQuery.disableAnimationsOf(context)) {
      return Icon(icon, size: size, color: color);
    }
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color ?? IconTheme.of(context).color),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.medium,
      curve: AppMotion.enter,
      builder: (context, value, _) => AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.medium,
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        child: Icon(icon, key: ValueKey(icon), size: size, color: value),
      ),
    );
  }
}
