import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/anime_repository.dart';
import '../domain/anime.dart';

/// Data used only by the isolated Showcase build.
abstract final class ShowcaseFixtures {
  static const posterAssets = <String>[
    'assets/showcase/posters/violet.png',
    'assets/showcase/posters/ocean.png',
    'assets/showcase/posters/ember.png',
    'assets/showcase/posters/forest.png',
    'assets/showcase/posters/nocturne.png',
    'assets/showcase/posters/petals.png',
  ];

  static const _seededPreference = 'showcase_initial_fixtures_seeded';

  static Future<void> seedOnFirstLaunch(
    AnimeRepository repository,
    SharedPreferences preferences,
  ) async {
    if (preferences.getBool(_seededPreference) ?? false) return;

    await repository.db.writeTxn(() async {
      if (await repository.db.animes.count() == 0) {
        await repository.db.animes.putAll(presetAnimes());
      }
    });
    await preferences.setBool(_seededPreference, true);
  }

  /// Adds the standard fixture set, skipping titles already in the demo DB.
  static Future<int> addPresetSet(AnimeRepository repository) async {
    var added = 0;
    for (final anime in presetAnimes()) {
      if (await repository.getAnimeByTitle(anime.title) != null) continue;
      await repository.saveAnime(anime);
      added++;
    }
    return added;
  }

  static List<Anime> presetAnimes() => [
        _fixture(
          'Asterion: The Last Observatory',
          status: AnimeStatus.watching,
          episodes: 24,
          watched: 7,
          poster: posterAssets[0],
          daysAgo: 1,
        ),
        _fixture(
          'Tideglass Chronicles',
          status: AnimeStatus.watching,
          episodes: 12,
          watched: 3,
          poster: posterAssets[1],
          daysAgo: 2,
        ),
        _fixture(
          'Ember of the Quiet Moon',
          status: AnimeStatus.planned,
          episodes: 26,
          watched: 0,
          poster: posterAssets[2],
        ),
        _fixture(
          'The Greenhouse at the End of Spring',
          status: AnimeStatus.completed,
          episodes: 13,
          watched: 13,
          poster: posterAssets[3],
          daysAgo: 12,
        ),
        _fixture(
          'Nocturne for a Blue Comet',
          status: AnimeStatus.dropped,
          episodes: 18,
          watched: 5,
          poster: posterAssets[4],
          daysAgo: 18,
        ),
        _fixture(
          'Petals Beneath the Station Clock',
          status: AnimeStatus.planned,
          episodes: 1,
          watched: 0,
          poster: posterAssets[5],
        ),
        _fixture(
          'A Very Long Title for Compact Layout Testing: Season Two',
          status: AnimeStatus.watching,
          episodes: 36,
          watched: 19,
          poster: posterAssets[0],
          daysAgo: 4,
        ),
        _fixture(
          'The Unillustrated Archive',
          status: AnimeStatus.planned,
          episodes: 8,
          watched: 0,
          poster: null,
        ),
      ];

  static Anime customAnime({
    required String title,
    required int episodes,
    required int watched,
    required AnimeStatus status,
    String? cover,
  }) {
    return _fixture(
      title.trim(),
      status: status,
      episodes: episodes.clamp(1, 999).toInt(),
      watched: watched.clamp(0, episodes.clamp(1, 999)).toInt(),
      poster: cover,
    );
  }

  static Anime _fixture(
    String title, {
    required AnimeStatus status,
    required int episodes,
    required int watched,
    required String? poster,
    int daysAgo = 0,
  }) {
    final paths = List.generate(
      episodes,
      (index) =>
          '/showcase/$title/episode_${(index + 1).toString().padLeft(2, '0')}.mkv',
    );
    final watchedPaths = paths.take(watched).toList();
    final anime = Anime()
      ..title = title
      ..scanTitle = title
      ..status = status
      ..episodePaths = paths
      ..watchedEpisodes = watchedPaths
      ..coverUrl = poster == null
          ? null
          : poster.startsWith('asset:') ||
                  poster.startsWith('/') ||
                  RegExp(r'^[A-Za-z]:[\\/]').hasMatch(poster)
              ? poster
              : 'asset:$poster'
      ..dateAdded = DateTime.now().subtract(Duration(days: daysAgo + 2))
      ..customCollections = ['Showcase'];

    if (watchedPaths.isNotEmpty) {
      anime.lastWatchedAt = DateTime.now().subtract(Duration(days: daysAgo));
      final nextEpisode = anime.nextEpisodeToPlay;
      if (nextEpisode != null) {
        anime.playbackPositions = [
          PlaybackEntry()
            ..path = nextEpisode
            ..position = 8 * 60 + 24,
        ];
      }
    }
    return anime;
  }
}
