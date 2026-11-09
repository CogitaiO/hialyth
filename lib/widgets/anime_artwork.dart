import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme_extension.dart';

class AnimeArtwork extends StatelessWidget {
  const AnimeArtwork(
      {super.key, this.cover, this.radius = 12, this.cacheWidth = 440});
  final String? cover;
  final double radius;
  final int cacheWidth;
  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
        color: context.appTheme.containerHigh,
        child: Center(
            child: Icon(AppIcons.image,
                color: context.appTheme.textMuted, size: 32)));
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: cover == null || cover!.isEmpty
            ? placeholder
            : cover!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: cover!,
                    fit: BoxFit.cover,
                    memCacheWidth: cacheWidth,
                    placeholder: (_, __) => placeholder,
                    errorWidget: (_, __, ___) => placeholder)
                : cover!.startsWith('asset:')
                    ? Image.asset(cover!.substring('asset:'.length),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => placeholder)
                    : Image.file(File(cover!),
                        fit: BoxFit.cover,
                        cacheWidth: cacheWidth,
                        errorBuilder: (_, __, ___) => placeholder));
  }
}
