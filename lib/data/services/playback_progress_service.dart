import '../../domain/anime.dart';
import '../repositories/playback_progress_store.dart';

/// Player-specific persistence operations.
///
/// This service deliberately knows nothing about media_kit, timers, or UI.
/// It only translates player progress into repository calls.
class PlaybackProgressService {
  PlaybackProgressService(this._store);

  final PlaybackProgressStore _store;

  /// Returns the saved position for [videoPath] from an already loaded anime.
  ///
  /// The first matching entry wins, preserving the previous lookup behavior.
  int savedSecondsFor(Anime? anime, String videoPath) {
    if (anime == null) return 0;

    for (final entry in anime.playbackPositions) {
      if (entry.path == videoPath) {
        return entry.position ?? 0;
      }
    }

    return 0;
  }

  Future<void> savePosition(
    int animeId,
    String videoPath,
    Duration position,
  ) {
    return _store.savePlaybackPosition(
      animeId,
      videoPath,
      position.inSeconds,
    );
  }

  Future<void> markWatched(int animeId, String videoPath) {
    return _store.markEpisodeAsWatched(animeId, videoPath);
  }
}
