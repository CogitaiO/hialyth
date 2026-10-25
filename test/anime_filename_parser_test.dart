import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/services/anime_filename_parser.dart';

void main() {
  group('AnimeFilenameParser.parseTitle', () {
    test('removes release tags, quality and episode suffix', () {
      expect(
        AnimeFilenameParser.parseTitle(
          '[SubsPlease] Bocchi the Rock! - 01 (1080p) [ABC123].mkv',
        ),
        'Bocchi the Rock!',
      );
    });

    test('normalizes separators and accepts uppercase extensions', () {
      expect(
        AnimeFilenameParser.parseTitle('My_Anime.Episode_12.MP4'),
        'My Anime',
      );
    });

    test('preserves title when there is no episode suffix', () {
      expect(
          AnimeFilenameParser.parseTitle('Cowboy Bebop.avi'), 'Cowboy Bebop');
    });
  });

  group('AnimeFilenameParser.parseEpisodeNumber', () {
    test('parses a number after a release-group dash', () {
      expect(
        AnimeFilenameParser.parseEpisodeNumber(
            '[SubsPlease] Anime - 01 [1080p].mkv'),
        1,
      );
    });

    test('parses episode labels and release versions', () {
      expect(AnimeFilenameParser.parseEpisodeNumber('Anime Ep 12v2.mkv'), 12);
      expect(AnimeFilenameParser.parseEpisodeNumber('Anime [24].mkv'), 24);
    });

    test('uses the trailing-number fallback for simple filenames', () {
      expect(AnimeFilenameParser.parseEpisodeNumber('Наруто 01.mkv'), 1);
    });

    test('rejects resolution tags and likely release years', () {
      expect(AnimeFilenameParser.parseEpisodeNumber('Anime 1080p.mkv'), isNull);
      expect(AnimeFilenameParser.parseEpisodeNumber('Anime 2023.mkv'), isNull);
    });

    test('returns null when no episode number is present', () {
      expect(AnimeFilenameParser.parseEpisodeNumber('Anime Movie.mkv'), isNull);
    });
  });
}
