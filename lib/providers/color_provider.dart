import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

import '../domain/anime.dart';
import '../theme/app_palette.dart';
import 'repositories_provider.dart';

final animeColorProvider =
    FutureProvider.autoDispose.family<Color, Anime>((ref, anime) async {
  if (anime.ambientColorValue != null) {
    return Color(anime.ambientColorValue!);
  }

  if (anime.coverUrl == null || anime.coverUrl!.isEmpty) {
    return AppPalette.fallbackAccent;
  }

  try {
    ImageProvider provider = anime.coverUrl!.startsWith('http')
        ? NetworkImage(anime.coverUrl!) as ImageProvider
        : FileImage(File(anime.coverUrl!));

    final resizedProvider = ResizeImage(provider, width: 100);

    final palette = await PaletteGenerator.fromImageProvider(
      resizedProvider,
      maximumColorCount: 10,
    );

    final calcColor = palette.vibrantColor?.color ??
        palette.dominantColor?.color ??
        palette.darkVibrantColor?.color ??
        AppPalette.fallbackAccent;

    // Cache the extracted color on the anime record.
    await ref
        .read(animeRepoProvider)
        .updateAmbientColor(anime.id, anime.coverUrl, calcColor.toARGB32());

    return calcColor;
  } catch (e) {
    return AppPalette.fallbackAccent;
  }
});
