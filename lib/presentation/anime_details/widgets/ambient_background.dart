import 'package:flutter/material.dart';
import '../../../core/app_features.dart';
import '../../../theme/app_theme_extension.dart';

/// Artwork tint is painted directly; no full-screen backdrop sampling or shadow blur.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        decoration: BoxDecoration(
            gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.3,
          colors: [
            AppFeatures.designV2
                ? Color.alphaBlend(
                    color.withValues(alpha: .16), context.appTheme.pageSurface)
                : context.appTheme.pageSurface,
            context.appTheme.pageSurface
          ],
        )),
      );
}
