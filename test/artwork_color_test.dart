import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/providers/color_provider.dart';
import 'package:nekaido_pre/providers/repositories_provider.dart';

class _ColorCache extends Fake implements AnimeRepository {
  final writes = <(int, String?, int)>[];

  @override
  Future<void> updateAmbientColor(
    int id,
    String? expectedCover,
    int color,
  ) async {
    writes.add((id, expectedCover, color));
  }
}

void main() {
  testWidgets('extracts a real poster color and caches it against its cover', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final cache = _ColorCache();
      final container = ProviderContainer(
        overrides: [animeRepoProvider.overrideWithValue(cache)],
      );
      addTearDown(container.dispose);
      final anime = Anime()
        ..id = 2
        ..title = 'Ocean'
        ..coverUrl = 'asset:assets/showcase/posters/ocean.png';
      final provider = animeColorProvider(anime);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final color = await container.read(provider.future);
      expect(color, isNotNull);
      expect(cache.writes, [(2, anime.coverUrl, color!.toARGB32())]);
    });
  });

  test(
    'uses cached colors without writing, and leaves missing covers untinted',
    () async {
      final cache = _ColorCache();
      final container = ProviderContainer(
        overrides: [animeRepoProvider.overrideWithValue(cache)],
      );
      addTearDown(container.dispose);
      final cached = Anime()
        ..id = 3
        ..title = 'Cached'
        ..coverUrl = '/no-such-cover.png'
        ..ambientColorValue = 0xff308c85;
      final empty = Anime()
        ..id = 4
        ..title = 'No cover';
      expect(
        await container.read(animeColorProvider(cached).future),
        const Color(0xff308c85),
      );
      expect(await container.read(animeColorProvider(empty).future), isNull);
      expect(cache.writes, isEmpty);
    },
  );
}
