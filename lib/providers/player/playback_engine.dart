import 'dart:async';

import 'package:media_kit/media_kit.dart';

abstract interface class PlaybackBackend {
  Player get player;
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get playingStream;
  Stream<double> get volumeStream;
  Stream<Tracks> get tracksStream;
  Stream<Track> get trackStream;
  Stream<bool> get completedStream;
  Stream<PlayerLog> get logStream;
  void initialize(
      {required double volume,
      required String audioLanguages,
      required String subtitleLanguages});
  void setProperty(String key, String value);
  Future<void> open(String path);
  Future<void> pause();
  Future<void> play();
  Future<void> playOrPause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setRate(double rate);
  Future<void> setAudioTrack(AudioTrack track);
  Future<void> setSubtitleTrack(SubtitleTrack track);
  Future<void> waitForDuration();
  Future<void> dispose();
}

/// Thin adapter around media_kit's [Player].
///
/// Keeping this in one place means the notifier no longer talks to media_kit
/// directly for playback controls. The [player] getter is still exposed because
/// `VideoController` needs the raw player instance.
class PlaybackEngine implements PlaybackBackend {
  PlaybackEngine({Player? player}) : _player = player ?? Player();

  final Player _player;

  @override
  Player get player => _player;

  @override
  Stream<Duration> get positionStream => _player.stream.position;
  @override
  Stream<Duration> get durationStream => _player.stream.duration;
  @override
  Stream<bool> get playingStream => _player.stream.playing;
  @override
  Stream<double> get volumeStream => _player.stream.volume;
  @override
  Stream<Tracks> get tracksStream => _player.stream.tracks;
  @override
  Stream<Track> get trackStream => _player.stream.track;
  @override
  Stream<bool> get completedStream => _player.stream.completed;
  @override
  Stream<PlayerLog> get logStream => _player.stream.log;

  @override
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

  @override
  void setProperty(String key, String value) {
    final dynamic platform = _player.platform;
    platform.setProperty(key, value);
  }

  @override
  Future<void> open(String path) => _player.open(Media(path), play: false);

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> playOrPause() => _player.playOrPause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setRate(double rate) => _player.setRate(rate);

  @override
  Future<void> setAudioTrack(AudioTrack track) => _player.setAudioTrack(track);

  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) =>
      _player.setSubtitleTrack(track);

  @override
  Future<void> waitForDuration() => _player.stream.duration
      .firstWhere((d) => d.inMilliseconds > 0)
      .timeout(const Duration(seconds: 5));

  @override
  Future<void> dispose() => _player.dispose();
}
