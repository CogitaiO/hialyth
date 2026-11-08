import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_surfaces.dart';

/// A bounded frosted surface for controls placed over video.
///
/// When transparency is reduced, this keeps the same shape and border while
/// replacing blur and translucency with the opaque overlay surface.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool reduceTransparency;

  const GlassSurface({
    super.key,
    required this.child,
    required this.reduceTransparency,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final borderColor = AppSurfaces.resolveGlassBorder(
      brightness: brightness,
      reduceTransparency: reduceTransparency,
    );

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        // Compose the scrim into the tint once. Keep text readable even over
        // white video frames without stacking another translucent widget.
        color: reduceTransparency
            ? AppSurfaces.overlayFor(brightness)
            : Color.alphaBlend(
                    AppSurfaces.scrim, AppSurfaces.glassFor(brightness))
                .withValues(alpha: 0.80),
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: Padding(
          padding: padding,
          child: Material(type: MaterialType.transparency, child: child)),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: reduceTransparency
          ? surface
          : BackdropFilter(
              // Opacity creates a saveLayer; srcOver would blend the captured
              // video a second time and can brighten the panel during fades.
              blendMode: BlendMode.src,
              filter: ImageFilter.blur(
                sigmaX: AppSurfaces.glassBlur,
                sigmaY: AppSurfaces.glassBlur,
              ),
              child: surface,
            ),
    );
  }
}
