import 'dart:async';

import 'package:media_kit/media_kit.dart';

/// Thin adapter around media_kit's [Player].
///
/// Keeping this in one place means the notifier no longer talks to media_kit
/// directly for playback controls. The [player] getter is still exposed because
/// `VideoController` needs the raw player instance.
class PlaybackEngine {
  PlaybackEngine({Player? player}) : _player = player ?? Player();

  final Player _player;

  Player get player => _player;

  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<double> get volumeStream => _player.stream.volume;
  Stream<Tracks> get tracksStream => _player.stream.tracks;
  Stream<Track> get trackStream => _player.stream.track;
  Stream<bool> get completedStream => _player.stream.completed;
  Stream<PlayerLog> get logStream => _player.stream.log;

  void initialize({
    required double volume,
    required String audioLanguages,
    required String subtitleLanguages,
  }) {
    unawaited(_player.setVolume(volume));
    setProperty('sub-ass', 'yes');
    setProperty('sub-ass-override', 'scale');
    setProperty('sub-pos', '90');
    setProperty('alang', audioLanguages);
    setProperty('slang', subtitleLanguages);
    setProperty('cache', 'yes');
    setProperty('cache-on-disk', 'no');
    setProperty('demuxer-max-bytes', '150M');
  }

  void setProperty(String key, String value) {
    final dynamic platform = _player.platform;
    platform.setProperty(key, value);
  }

  Future<void> open(String path) => _player.open(Media(path), play: true);

  Future<void> play() => _player.play();

  Future<void> playOrPause() => _player.playOrPause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> setRate(double rate) => _player.setRate(rate);

  Future<void> setAudioTrack(AudioTrack track) => _player.setAudioTrack(track);

  Future<void> setSubtitleTrack(SubtitleTrack track) =>
      _player.setSubtitleTrack(track);

  Future<void> waitForDuration() =>
      _player.stream.duration.firstWhere((d) => d.inMilliseconds > 0);

  Future<void> dispose() => _player.dispose();
}
