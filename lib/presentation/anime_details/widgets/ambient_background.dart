import 'package:flutter/material.dart';
import '../../../core/app_features.dart';
import '../../../theme/app_surfaces.dart';
import '../../../theme/app_theme_extension.dart';

/// Artwork tint is painted directly; no full-screen backdrop sampling or shadow blur.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    if (!AppFeatures.designV2) return const SizedBox.shrink();
    final black = context.appTheme.pageSurface;
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-.54, 0),
            radius: .47,
            colors: [AppSurfaces.artworkWash(color, black), black],
            stops: const [.04, 1],
          ),
        ),
      ),
    );
  }
}
