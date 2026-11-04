import '../../core/logger.dart';
import '../../data/services/playback_progress_service.dart';
import '../../domain/anime.dart';

/// Stateful progress policy for one player session.
///
/// Tracks when the position should be persisted and when the current episode
/// should be marked as watched. The actual storage work is delegated to
/// [PlaybackProgressService].
class PlaybackProgressTracker {
  PlaybackProgressTracker(this._service);

  final PlaybackProgressService _service;

  int _lastSavedSeconds = -1;
  bool _episodeMarkedWatched = false;

  /// Restores the saved position for a newly loaded episode and resets the
  /// per-episode throttling state.
  int restore(Anime? anime, String videoPath) {
    final savedSeconds = _service.savedSecondsFor(anime, videoPath);
    _lastSavedSeconds = savedSeconds;
    _episodeMarkedWatched = false;
    return savedSeconds;
  }

  /// Called for every position update from the player.
  ///
  /// Persists every 15 seconds of playback and marks the episode as watched
  /// once playback reaches 90% of its duration.
  Future<void> onPosition({
    required int? animeId,
    required String? videoPath,
    required Duration position,
    required Duration duration,
  }) async {
    if (animeId == null || videoPath == null) return;

    final currentSeconds = position.inSeconds;
    final shouldSave =
        currentSeconds > 0 && (currentSeconds - _lastSavedSeconds).abs() >= 15;
    if (shouldSave) {
      _lastSavedSeconds = currentSeconds;
    }

    final shouldMarkWatched = duration.inSeconds > 0 &&
        currentSeconds / duration.inSeconds >= 0.9 &&
        !_episodeMarkedWatched;
    if (shouldMarkWatched) {
      // Set the flag before awaiting storage so overlapping position events
      // cannot trigger duplicate writes.
      _episodeMarkedWatched = true;
    }

    final writes = <Future<void>>[];
    if (shouldSave) {
      writes.add(_service.savePosition(animeId, videoPath, position));
    }
    if (shouldMarkWatched) {
      writes.add(_service.markWatched(animeId, videoPath));
      talker.info('Episode marked as watched: $videoPath');
    }

    if (writes.isNotEmpty) {
      await Future.wait(writes);
    }
  }

  /// Persists the current position immediately.
  ///
  /// Used when playback is paused or when the user toggles play/pause.
  Future<void> saveNow({
    required int? animeId,
    required String? videoPath,
    required Duration position,
  }) async {
    if (animeId == null || videoPath == null) return;
    await _service.savePosition(animeId, videoPath, position);
  }

  /// Saves the final position when the player is disposed.
  ///
  /// Positions in the last five seconds are reset to zero so the next launch
  /// starts the episode from the beginning. Very short positions are ignored.
  Future<void> finalize({
    required int? animeId,
    required String? videoPath,
    required Duration position,
    required Duration duration,
  }) async {
    if (animeId == null || videoPath == null) return;

    final finalSeconds = position.inSeconds;
    if (finalSeconds <= 5) return;

    if (duration.inSeconds > 0 && (duration.inSeconds - finalSeconds) < 5) {
      await _service.savePosition(animeId, videoPath, Duration.zero);
    } else {
      await _service.savePosition(animeId, videoPath, position);
    }
  }
}
