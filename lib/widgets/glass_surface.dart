import 'package:flutter/material.dart';
import '../theme/app_surfaces.dart';
import '../core/app_features.dart';

/// A bounded translucent surface for controls placed over video.
///
/// When transparency is reduced, this keeps the same shape and border while
/// replacing translucency with the opaque overlay surface. It intentionally
/// does not sample/blur the live video backdrop, which correlated with raster
/// spikes on Linux.
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
    final opaque = reduceTransparency || !AppFeatures.designV2;
    final borderColor = AppSurfaces.resolveGlassBorder(
      brightness: brightness,
      reduceTransparency: opaque,
    );

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        // Compose the scrim into the tint once. Keep text readable even over
        // white video frames without stacking another translucent widget.
        color: opaque
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

    return ClipRRect(borderRadius: borderRadius, child: surface);
  }
}
