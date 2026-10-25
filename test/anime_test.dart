import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/domain/anime.dart';

void main() {
  group('Anime episode and progress getters', () {
    test('sorts episodes naturally without mutating the stored order', () {
      final anime = Anime()
        ..title = 'Example'
        ..episodePaths = ['/anime/10.mkv', '/anime/2.mkv', '/anime/1.mkv'];

      expect(anime.sortedEpisodes,
          ['/anime/1.mkv', '/anime/2.mkv', '/anime/10.mkv']);
      expect(anime.episodePaths,
          ['/anime/10.mkv', '/anime/2.mkv', '/anime/1.mkv']);
    });

    test('returns zero progress for an empty episode list', () {
      final anime = Anime()..title = 'Example';

      expect(anime.watchProgress, 0.0);
      expect(anime.progressPercentage, '0%');
      expect(anime.progressFraction, '0 / 0');
      expect(anime.nextEpisodeToPlay, isNull);
    });

    test('calculates progress and returns the first unwatched sorted episode',
        () {
      final anime = Anime()
        ..title = 'Example'
        ..episodePaths = ['/anime/10.mkv', '/anime/2.mkv', '/anime/1.mkv']
        ..watchedEpisodes = ['/anime/1.mkv'];

      expect(anime.watchProgress, 1 / 3);
      expect(anime.progressPercentage, '33%');
      expect(anime.progressFraction, '1 / 3');
      expect(anime.nextEpisodeToPlay, '/anime/2.mkv');
    });

    test('returns no next episode when all episodes are watched', () {
      final anime = Anime()
        ..title = 'Example'
        ..episodePaths = ['/anime/1.mkv', '/anime/2.mkv']
        ..watchedEpisodes = ['/anime/1.mkv', '/anime/2.mkv'];

      expect(anime.nextEpisodeToPlay, isNull);
      expect(anime.progressPercentage, '100%');
    });
  });
}
