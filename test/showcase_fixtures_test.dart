import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/demo/showcase_fixtures.dart';
import 'package:nekaido_pre/demo/showcase_storage.dart';
import 'package:nekaido_pre/domain/anime.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('showcase storage has its own database and preference namespace', () {
    final normalDatabase =
        '${Directory.systemTemp.path}${Platform.pathSeparator}Documents';
    final showcaseDatabase = ShowcaseStorage.databasePath(
        '${Directory.systemTemp.path}${Platform.pathSeparator}hialyth');

    expect(showcaseDatabase, isNot(normalDatabase));
    expect(showcaseDatabase.split(Platform.pathSeparator).last,
        ShowcaseStorage.databaseDirectoryName);
    expect(ShowcaseStorage.preferencesPrefix, isNotEmpty);
  });

  test('preset fixtures cover layout statuses, progress, posters and long text',
      () {
    final fixtures = ShowcaseFixtures.presetAnimes();

    expect(fixtures, hasLength(8));
    expect(fixtures.map((anime) => anime.status).toSet(),
        AnimeStatus.values.toSet());
    expect(fixtures.any((anime) => anime.coverUrl == null), isTrue);
    expect(fixtures.any((anime) => anime.title.length > 50), isTrue);
    expect(fixtures.any((anime) => anime.watchProgress > 0), isTrue);
    expect(
      fixtures
          .where((anime) => anime.coverUrl != null)
          .every((anime) => anime.coverUrl!.startsWith('asset:')),
      isTrue,
    );
    expect(
      fixtures.every((anime) =>
          anime.episodePaths.every((path) => path.startsWith('/showcase/'))),
      isTrue,
    );
  });

  test('bundles original local poster assets', () async {
    for (final asset in ShowcaseFixtures.posterAssets) {
      final image = await rootBundle.load(asset);
      expect(image.lengthInBytes, greaterThan(0));
    }
  });

  test('custom fixtures clamp episode values and accept local posters', () {
    final anime = ShowcaseFixtures.customAnime(
      title: ' Custom fixture ',
      episodes: 4,
      watched: 30,
      status: AnimeStatus.watching,
      cover: '/tmp/custom-poster.png',
    );

    expect(anime.title, 'Custom fixture');
    expect(anime.episodePaths, hasLength(4));
    expect(anime.watchedEpisodes, hasLength(4));
    expect(anime.coverUrl, '/tmp/custom-poster.png');
    expect(anime.status, AnimeStatus.watching);

    final windowsPoster = ShowcaseFixtures.customAnime(
      title: 'Windows poster',
      episodes: 1,
      watched: 0,
      status: AnimeStatus.planned,
      cover: r'C:\demo\poster.png',
    );
    expect(windowsPoster.coverUrl, r'C:\demo\poster.png');
  });
}
