import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';

import '../domain/anime.dart';
import 'repositories_provider.dart';

final animeColorProvider = FutureProvider.autoDispose.family<Color?, Anime>((
  ref,
  anime,
) async {
  final cover = anime.coverUrl;
  if (cover == null || cover.isEmpty) return null;
  final cached = anime.ambientColorValue;
  if (cached != null) return Color(cached);

  var disposed = false;
  ref.onDispose(() => disposed = true);
  final ImageProvider provider = cover.startsWith('http')
      ? CachedNetworkImageProvider(cover)
      : cover.startsWith('asset:')
      ? AssetImage(cover.substring('asset:'.length))
      : FileImage(File(cover));

  final int? argb;
  try {
    argb = await _extractArtworkColor(provider);
  } catch (_) {
    return null;
  }
  if (argb == null) return null;

  if (!disposed) {
    try {
      await ref
          .read(animeRepoProvider)
          .updateAmbientColor(anime.id, cover, argb);
    } catch (_) {
      // A failed cache write needn't suppress the color already extracted.
    }
  }
  return Color(argb);
});

Future<int?> _extractArtworkColor(ImageProvider image) async {
  final stream = ResizeImage(
    image,
    width: 48,
    height: 72,
    policy: ResizeImagePolicy.fit,
  ).resolve(ImageConfiguration.empty);
  final ready = Completer<ImageInfo>();
  final listener = ImageStreamListener(
    (info, _) {
      if (ready.isCompleted) {
        info.dispose();
      } else {
        ready.complete(info);
      }
    },
    onError: (error, stack) {
      if (!ready.isCompleted) ready.completeError(error, stack);
    },
  );
  stream.addListener(listener);
  final ImageInfo info;
  try {
    info = await ready.future.timeout(const Duration(seconds: 15));
  } finally {
    stream.removeListener(listener);
  }
  final EncodedImage sample;
  try {
    final pixels = await info.image.toByteData(
      format: ImageByteFormat.rawStraightRgba,
    );
    if (pixels == null) return null;
    sample = EncodedImage(
      pixels,
      width: info.image.width,
      height: info.image.height,
    );
  } finally {
    info.dispose();
  }
  return compute(_quantizeArtwork, sample, debugLabel: 'artwork palette');
}

Future<int?> _quantizeArtwork(EncodedImage sample) async {
  final palette = await PaletteGenerator.fromByteData(
    sample,
    maximumColorCount: 10,
  );
  return (palette.vibrantColor ??
          palette.dominantColor ??
          palette.darkVibrantColor)
      ?.color
      .toARGB32();
}
