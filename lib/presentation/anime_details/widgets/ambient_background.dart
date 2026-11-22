import 'package:flutter/material.dart';
import '../../../core/app_features.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/app_surfaces.dart';
import '../../../theme/app_theme_extension.dart';

/// Artwork tint is painted directly; no full-screen backdrop sampling or shadow blur.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppMotion.resolveDuration(
      context,
      const Duration(milliseconds: 300),
    ),
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(-.72, -.84),
        radius: 1.1,
        colors: [
          if (AppFeatures.designV2)
            AppSurfaces.artworkWash(color, context.appTheme.titleBarSurface)
          else
            context.appTheme.pageSurface,
          AppFeatures.designV2
              ? context.appTheme.titleBarSurface
              : context.appTheme.pageSurface,
          context.appTheme.pageSurface,
        ],
        stops: const [0, .59, 1],
      ),
    ),
  );
}
