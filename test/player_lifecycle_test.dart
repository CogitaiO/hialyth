import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nekaido_pre/providers/player/player_lifecycle.dart';

void main() {
  group('PlayerLifecycle', () {
    test('routes stream events to the matching handlers', () async {
      final streams = _LifecycleStreams();
      addTearDown(streams.close);

      Duration? position;
      Duration? duration;
      bool? playing;
      double? volume;
      Tracks? tracks;
      Track? track;
      bool? completed;
      PlayerLog? log;

      final lifecycle = PlayerLifecycle(
        positionStream: streams.position.stream,
        durationStream: streams.duration.stream,
        playingStream: streams.playing.stream,
        volumeStream: streams.volume.stream,
        tracksStream: streams.tracks.stream,
        trackStream: streams.track.stream,
        completedStream: streams.completed.stream,
        logStream: streams.log.stream,
        handlers: PlayerLifecycleHandlers(
          onPosition: (value) => position = value,
          onDuration: (value) => duration = value,
          onPlaying: (value) => playing = value,
          onVolume: (value) => volume = value,
          onTracks: (value) => tracks = value,
          onTrack: (value) => track = value,
          onCompleted: (value) => completed = value,
          onLog: (value) => log = value,
        ),
      );
      addTearDown(lifecycle.dispose);

      lifecycle.start();
      streams.position.add(const Duration(seconds: 12));
      streams.duration.add(const Duration(minutes: 24));
      streams.playing.add(true);
      streams.volume.add(55);
      streams.tracks.add(const Tracks());
      streams.track.add(const Track());
      streams.completed.add(true);
      streams.log
          .add(const PlayerLog(prefix: 'mpv', level: 'info', text: 'ok'));

      await pumpEventQueue();

      expect(position, const Duration(seconds: 12));
      expect(duration, const Duration(minutes: 24));
      expect(playing, isTrue);
      expect(volume, 55);
      expect(tracks, const Tracks());
      expect(track, const Track());
      expect(completed, isTrue);
      expect(log?.text, 'ok');
    });

    test('dispose cancels subscriptions and timers', () async {
      final streams = _LifecycleStreams();
      addTearDown(streams.close);

      var positions = 0;
      var timerCalled = false;
      final lifecycle = PlayerLifecycle(
        positionStream: streams.position.stream,
        durationStream: streams.duration.stream,
        playingStream: streams.playing.stream,
        volumeStream: streams.volume.stream,
        tracksStream: streams.tracks.stream,
        trackStream: streams.track.stream,
        completedStream: streams.completed.stream,
        logStream: streams.log.stream,
        handlers: PlayerLifecycleHandlers(
          onPosition: (_) => positions++,
          onDuration: (_) {},
          onPlaying: (_) {},
          onVolume: (_) {},
          onTracks: (_) {},
          onTrack: (_) {},
          onCompleted: (_) {},
          onLog: (_) {},
        ),
      );

      lifecycle.start();
      lifecycle.scheduleUiHide(
        const Duration(milliseconds: 20),
        () => timerCalled = true,
      );
      lifecycle.dispose();
      await pumpEventQueue();

      streams.position.add(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(positions, 0);
      expect(timerCalled, isFalse);
    });

    test('load lock allows one load at a time', () {
      final streams = _LifecycleStreams();
      addTearDown(streams.close);

      final lifecycle = PlayerLifecycle(
        positionStream: streams.position.stream,
        durationStream: streams.duration.stream,
        playingStream: streams.playing.stream,
        volumeStream: streams.volume.stream,
        tracksStream: streams.tracks.stream,
        trackStream: streams.track.stream,
        completedStream: streams.completed.stream,
        logStream: streams.log.stream,
        handlers: PlayerLifecycleHandlers(
          onPosition: (_) {},
          onDuration: (_) {},
          onPlaying: (_) {},
          onVolume: (_) {},
          onTracks: (_) {},
          onTrack: (_) {},
          onCompleted: (_) {},
          onLog: (_) {},
        ),
      );
      addTearDown(lifecycle.dispose);

      expect(lifecycle.beginLoading(), isTrue);
      expect(lifecycle.beginLoading(), isFalse);
      lifecycle.endLoading();
      expect(lifecycle.beginLoading(), isTrue);
    });

    test('schedules the next episode callback', () async {
      final streams = _LifecycleStreams();
      addTearDown(streams.close);

      var called = false;
      final lifecycle = PlayerLifecycle(
        positionStream: streams.position.stream,
        durationStream: streams.duration.stream,
        playingStream: streams.playing.stream,
        volumeStream: streams.volume.stream,
        tracksStream: streams.tracks.stream,
        trackStream: streams.track.stream,
        completedStream: streams.completed.stream,
        logStream: streams.log.stream,
        handlers: PlayerLifecycleHandlers(
          onPosition: (_) {},
          onDuration: (_) {},
          onPlaying: (_) {},
          onVolume: (_) {},
          onTracks: (_) {},
          onTrack: (_) {},
          onCompleted: (_) {},
          onLog: (_) {},
        ),
      );
      addTearDown(lifecycle.dispose);

      lifecycle.scheduleNextEpisode(
        const Duration(milliseconds: 10),
        () => called = true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(called, isTrue);
    });
  });
}

class _LifecycleStreams {
  final position = StreamController<Duration>.broadcast();
  final duration = StreamController<Duration>.broadcast();
  final playing = StreamController<bool>.broadcast();
  final volume = StreamController<double>.broadcast();
  final tracks = StreamController<Tracks>.broadcast();
  final track = StreamController<Track>.broadcast();
  final completed = StreamController<bool>.broadcast();
  final log = StreamController<PlayerLog>.broadcast();

  Future<void> close() async {
    await Future.wait([
      position.close(),
      duration.close(),
      playing.close(),
      volume.close(),
      tracks.close(),
      track.close(),
      completed.close(),
      log.close(),
    ]);
  }
}
