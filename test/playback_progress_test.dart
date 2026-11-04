import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/repositories/playback_progress_store.dart';
import 'package:nekaido_pre/data/services/playback_progress_service.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/providers/player/playback_progress_tracker.dart';

void main() {
  group('PlaybackProgressService', () {
    late _FakePlaybackProgressStore store;
    late PlaybackProgressService service;

    setUp(() {
      store = _FakePlaybackProgressStore();
      service = PlaybackProgressService(store);
    });

    test('finds the saved position for a video path', () {
      final anime = Anime()
        ..playbackPositions = [
          PlaybackEntry()
            ..path = '/anime/1.mkv'
            ..position = 42,
          PlaybackEntry()
            ..path = '/anime/2.mkv'
            ..position = 7,
        ];

      expect(service.savedSecondsFor(anime, '/anime/2.mkv'), 7);
    });

    test('returns zero for a missing path or anime', () {
      final anime = Anime()
        ..playbackPositions = [
          PlaybackEntry()
            ..path = '/anime/1.mkv'
            ..position = 42,
        ];

      expect(service.savedSecondsFor(anime, '/anime/missing.mkv'), 0);
      expect(service.savedSecondsFor(null, '/anime/1.mkv'), 0);
    });

    test('saves position in whole seconds', () async {
      await service.savePosition(
        1,
        '/anime/1.mkv',
        const Duration(seconds: 42, milliseconds: 900),
      );

      expect(store.saved, [(1, '/anime/1.mkv', 42)]);
    });

    test('marks the episode as watched', () async {
      await service.markWatched(1, '/anime/1.mkv');

      expect(store.watched, [(1, '/anime/1.mkv')]);
    });
  });

  group('PlaybackProgressTracker', () {
    late _FakePlaybackProgressStore store;
    late PlaybackProgressTracker tracker;

    setUp(() {
      store = _FakePlaybackProgressStore();
      tracker = PlaybackProgressTracker(PlaybackProgressService(store));
    });

    test('does not save before 15 seconds from the restored position',
        () async {
      final anime = Anime()
        ..playbackPositions = [
          PlaybackEntry()
            ..path = '/anime/1.mkv'
            ..position = 10,
        ];

      expect(tracker.restore(anime, '/anime/1.mkv'), 10);

      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 20),
        duration: const Duration(seconds: 100),
      );
      expect(store.saved, isEmpty);

      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 25),
        duration: const Duration(seconds: 100),
      );
      expect(store.saved, [(1, '/anime/1.mkv', 25)]);
    });

    test('saves at the 15 second mark after a fresh start', () async {
      tracker.restore(null, '/anime/1.mkv');

      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 14),
        duration: const Duration(seconds: 100),
      );
      expect(store.saved, isEmpty);

      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 15),
        duration: const Duration(seconds: 100),
      );
      expect(store.saved, [(1, '/anime/1.mkv', 15)]);
    });

    test('does not save at the beginning of playback', () async {
      tracker.restore(null, '/anime/1.mkv');

      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: Duration.zero,
        duration: const Duration(seconds: 100),
      );

      expect(store.saved, isEmpty);
    });

    test('marks watched once at 90 percent', () async {
      final anime = Anime()
        ..playbackPositions = [
          PlaybackEntry()
            ..path = '/anime/1.mkv'
            ..position = 90,
        ];
      tracker.restore(anime, '/anime/1.mkv');

      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 90),
        duration: const Duration(seconds: 100),
      );
      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 95),
        duration: const Duration(seconds: 100),
      );

      expect(store.saved, isEmpty);
      expect(store.watched, [(1, '/anime/1.mkv')]);
    });

    test('marks watched once when position updates overlap', () async {
      final delayedStore = _FakePlaybackProgressStore(
        saveDelay: const Duration(milliseconds: 20),
      );
      final delayedTracker =
          PlaybackProgressTracker(PlaybackProgressService(delayedStore));
      delayedTracker.restore(null, '/anime/1.mkv');

      final first = delayedTracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 90),
        duration: const Duration(seconds: 100),
      );
      final second = delayedTracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 91),
        duration: const Duration(seconds: 100),
      );
      await Future.wait([first, second]);

      expect(delayedStore.watched, [(1, '/anime/1.mkv')]);
    });

    test('restore resets watched state for a new episode', () async {
      final first = Anime()
        ..playbackPositions = [
          PlaybackEntry()
            ..path = '/anime/1.mkv'
            ..position = 90,
        ];
      tracker.restore(first, '/anime/1.mkv');
      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 90),
        duration: const Duration(seconds: 100),
      );
      expect(store.watched.length, 1);

      final second = Anime()
        ..playbackPositions = [
          PlaybackEntry()
            ..path = '/anime/2.mkv'
            ..position = 90,
        ];
      tracker.restore(second, '/anime/2.mkv');
      await tracker.onPosition(
        animeId: 1,
        videoPath: '/anime/2.mkv',
        position: const Duration(seconds: 90),
        duration: const Duration(seconds: 100),
      );

      expect(store.watched.length, 2);
    });

    test('saveNow persists the current position', () async {
      await tracker.saveNow(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 42),
      );

      expect(store.saved, [(1, '/anime/1.mkv', 42)]);
    });

    test('saveNow ignores a missing session', () async {
      await tracker.saveNow(
        animeId: null,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 42),
      );
      await tracker.saveNow(
        animeId: 1,
        videoPath: null,
        position: const Duration(seconds: 42),
      );

      expect(store.saved, isEmpty);
    });

    test('finalize saves the final position', () async {
      await tracker.finalize(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 42),
        duration: const Duration(seconds: 100),
      );

      expect(store.saved, [(1, '/anime/1.mkv', 42)]);
    });

    test('finalize resets positions near the end', () async {
      await tracker.finalize(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 97),
        duration: const Duration(seconds: 100),
      );

      expect(store.saved, [(1, '/anime/1.mkv', 0)]);
    });

    test('finalize ignores very short positions and missing sessions',
        () async {
      await tracker.finalize(
        animeId: 1,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 5),
        duration: const Duration(seconds: 100),
      );
      await tracker.finalize(
        animeId: null,
        videoPath: '/anime/1.mkv',
        position: const Duration(seconds: 42),
        duration: const Duration(seconds: 100),
      );
      await tracker.finalize(
        animeId: 1,
        videoPath: null,
        position: const Duration(seconds: 42),
        duration: const Duration(seconds: 100),
      );

      expect(store.saved, isEmpty);
    });
  });
}

class _FakePlaybackProgressStore implements PlaybackProgressStore {
  _FakePlaybackProgressStore({this.saveDelay = Duration.zero});

  final Duration saveDelay;
  final List<(int, String, int)> saved = [];
  final List<(int, String)> watched = [];

  @override
  Future<void> savePlaybackPosition(int id, String path, int seconds) async {
    if (saveDelay > Duration.zero) {
      await Future<void>.delayed(saveDelay);
    }
    saved.add((id, path, seconds));
  }

  @override
  Future<void> markEpisodeAsWatched(int id, String episodePath) async {
    watched.add((id, episodePath));
  }
}
