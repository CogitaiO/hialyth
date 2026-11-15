import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/providers/player/player_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'player_loading_test.dart' as fakes;

class _Backend extends fakes.Backend {
  final events = StreamController<Tracks>.broadcast(sync: true);
  final audio = <AudioTrack>[];
  final subtitlesSelected = <SubtitleTrack>[];
  Tracks available = const Tracks();
  @override
  Stream<Tracks> get tracksStream => events.stream;
  @override
  Future<void> open(String path) async {
    await super.open(path);
    events.add(available);
  }

  @override
  Future<void> setAudioTrack(AudioTrack track) async => audio.add(track);
  @override
  Future<void> setSubtitleTrack(SubtitleTrack track) async =>
      subtitlesSelected.add(track);
  @override
  Future<void> dispose() async {
    await events.close();
    await super.dispose();
  }
}

void main() {
  test(
    'manual choices restore on next episode and restart, not another anime',
    () async {
      SharedPreferences.setMockInitialValues({'pref_discord': false});
      final prefs = await SharedPreferences.getInstance();
      final dir = await Directory.systemTemp.createTemp('hialyth-track-test-');
      addTearDown(() => dir.delete(recursive: true));
      final first = (await File('${dir.path}/01.mkv').create()).path;
      final next = (await File('${dir.path}/02.mkv').create()).path;
      final repo = fakes.Repository();
      repo.records[1] = Anime()
        ..id = 1
        ..title = 'First'
        ..episodePaths = [first, next];
      repo.records[2] = Anime()
        ..id = 2
        ..title = 'Second'
        ..episodePaths = [first];
      final backend = _Backend();
      const dub = AudioTrack('2', 'Studio', 'rus');
      backend.available = Tracks(
        audio: [AudioTrack.auto(), dub],
        subtitle: [SubtitleTrack.no()],
      );
      var notifier = PlayerNotifier(
        repo,
        prefs,
        engine: backend,
        discordService: fakes.Presence(),
      );
      await notifier.loadVideo(1, first);
      notifier.setAudioTrack(dub);
      notifier.setSubtitleTrack(SubtitleTrack.no());
      await Future<void>.delayed(Duration.zero);
      backend.audio.clear();
      backend.subtitlesSelected.clear();
      const reorderedDub = AudioTrack('7', 'Studio', 'rus');
      backend.available = Tracks(
        audio: [AudioTrack.auto(), reorderedDub],
        subtitle: [SubtitleTrack.no()],
      );
      await notifier.loadVideo(1, next);
      expect(backend.audio, [reorderedDub]);
      expect(backend.subtitlesSelected.single.id, 'no');
      backend.audio.clear();
      backend.subtitlesSelected.clear();
      await notifier.loadVideo(2, first);
      expect(backend.audio, isEmpty);
      expect(backend.subtitlesSelected, isEmpty);
      notifier.dispose();
      await Future<void>.delayed(Duration.zero);

      final restarted = _Backend();
      notifier = PlayerNotifier(
        repo,
        prefs,
        engine: restarted,
        discordService: fakes.Presence(),
      );
      await notifier.loadVideo(1, next);
      // Track lists can arrive after open, especially for external media.
      restarted.events.add(backend.available);
      await Future<void>.delayed(Duration.zero);
      expect(restarted.audio, [reorderedDub]);
      expect(restarted.subtitlesSelected.single.id, 'no');
      notifier.dispose();
      await Future<void>.delayed(Duration.zero);
    },
  );
}
