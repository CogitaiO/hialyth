import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme_extension.dart';

class AnimeArtwork extends StatelessWidget {
  const AnimeArtwork({
    super.key,
    this.cover,
    this.title,
    this.radius = 12,
    this.cacheWidth = 440,
  });

  final String? cover;

  /// Used by the fallback so a missing poster still has a recognisable,
  /// stable identity instead of a generic broken-image box.
  final String? title;
  final double radius;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final placeholder = _ArtworkFallback(title: title);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: cover == null || cover!.isEmpty
          ? placeholder
          : cover!.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: cover!,
              fit: BoxFit.cover,
              memCacheWidth: cacheWidth,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            )
          : cover!.startsWith('asset:')
          ? Image.asset(
              cover!.substring('asset:'.length),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            )
          : Image.file(
              File(cover!),
              fit: BoxFit.cover,
              cacheWidth: cacheWidth,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({this.title});

  final String? title;

  static Color _tint(String? title) {
    final hash = (title ?? '').codeUnits.fold<int>(
      0,
      (value, unit) => (value * 31 + unit) & 0x7fffffff,
    );
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), .34, .30).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final initial = (title ?? '').trim().isEmpty
        ? null
        : title!.trim().substring(0, 1).toUpperCase();
    final tint = _tint(title);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth * .38).clamp(20.0, 44.0);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(tint.withValues(alpha: .72), tokens.container),
                tokens.container,
              ],
            ),
          ),
          child: Center(
            child: initial == null
                ? Icon(AppIcons.image, color: tokens.textMuted, size: size)
                : Text(
                    initial,
                    style: TextStyle(
                      color: tokens.textPrimary.withValues(alpha: .62),
                      fontSize: size,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
