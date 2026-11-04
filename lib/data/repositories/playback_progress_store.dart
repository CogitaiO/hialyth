/// Narrow persistence contract used by the player progress tracker.
///
/// Keeping this separate from the Isar repository lets the progress logic be
/// tested without opening an actual database.
abstract interface class PlaybackProgressStore {
  Future<void> savePlaybackPosition(int id, String path, int seconds);

  Future<void> markEpisodeAsWatched(int id, String episodePath);
}
