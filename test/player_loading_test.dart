import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/data/services/discord_service.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/providers/player/playback_engine.dart';
import 'package:nekaido_pre/providers/player/player_provider.dart';

class Repository extends Fake implements AnimeRepository {
  final records = <int, Anime>{};
  Completer<Anime?>? firstRead;
  @override
  Future<Anime?> getAnimeById(int id) => id == 1 && firstRead != null
      ? firstRead!.future
      : Future.value(records[id]);
  @override
  Future<void> savePlaybackPosition(int id, String path, int seconds) async {}
  @override
  Future<void> markEpisodeAsWatched(int id, String path) async {}
}

class Backend extends Fake implements PlaybackBackend {
  final opened = <String>[];
  final properties = <String, String>{};
  bool disposed = false;
  bool failDuration = false;
  String? subtitles;
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration> get durationStream => const Stream.empty();
  @override
  Stream<bool> get playingStream => const Stream.empty();
  @override
  Stream<double> get volumeStream => const Stream.empty();
  @override
  Stream<Tracks> get tracksStream => const Stream.empty();
  @override
  Stream<Track> get trackStream => const Stream.empty();
  @override
  Stream<bool> get completedStream => const Stream.empty();
  @override
  Stream<PlayerLog> get logStream => const Stream.empty();
  @override
  void initialize(
      {required double volume,
      required String audioLanguages,
      required String subtitleLanguages}) {
    subtitles = subtitleLanguages;
  }

  @override
  void setProperty(String key, String value) {
    properties[key] = value;
  }

  @override
  Future<void> pause() async {}
  @override
  Future<void> open(String path) async {
    opened.add(path);
  }

  @override
  Future<void> seek(Duration value) async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> waitForDuration() async {
    if (failDuration) throw TimeoutException('No duration');
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class Presence extends Fake implements DiscordService {
  int updates = 0;
  int disposals = 0;
  @override
  void updatePresence(
      {required String title,
      required String episode,
      int? currentPositionSeconds,
      int? durationSeconds,
      bool isPlaying = true}) {
    updates++;
  }

  @override
  void dispose() {
    disposals++;
  }
}

void main() {
  late Directory dir;
  late Repository repo;
  late Backend backend;
  late Presence presence;
  late PlayerNotifier notifier;
  late String one, two;
  setUp(() async {
    SharedPreferences.setMockInitialValues({'pref_discord': false});
    final prefs = await SharedPreferences.getInstance();
    dir = await Directory.systemTemp.createTemp('hialyth-player-');
    one = (await File('${dir.path}/one.mkv').create()).path;
    two = (await File('${dir.path}/two.mkv').create()).path;
    repo = Repository();
    backend = Backend();
    presence = Presence();
    repo.records[1] = Anime()
      ..id = 1
      ..title = 'One'
      ..episodePaths = [one];
    repo.records[2] = Anime()
      ..id = 2
      ..title = 'Two'
      ..episodePaths = [two];
    notifier =
        PlayerNotifier(repo, prefs, engine: backend, discordService: presence);
  });
  tearDown(() async {
    if (notifier.mounted) notifier.dispose();
    await Future<void>.delayed(Duration.zero);
    await dir.delete(recursive: true);
  });
  test(
      'opens local video, uses shared language defaults and respects disabled RPC',
      () async {
    await notifier.loadVideo(1, one);
    expect(backend.opened, [one]);
    expect(notifier.state.isPlaying, isTrue);
    expect(notifier.state.isLoading, isFalse);
    expect(presence.updates, 0);
    expect(backend.subtitles, 'eng,en,rus,ru');
    notifier.applyPreferences(
        audioLanguage: 'eng', subtitleLanguage: 'rus', discordEnabled: true);
    expect(backend.properties['slang'], 'rus');
    expect(presence.updates, 1);
    notifier.applyPreferences(
        audioLanguage: 'eng', subtitleLanguage: 'eng', discordEnabled: false);
    expect(presence.disposals, 1);
  });
  test('newest request wins while an older repository request is pending',
      () async {
    repo.firstRead = Completer();
    final first = notifier.loadVideo(1, one);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final second = notifier.loadVideo(2, two);
    repo.firstRead!.complete(repo.records[1]);
    await Future.wait([first, second]);
    expect(backend.opened, [two]);
    expect(notifier.state.videoPath, two);
  });
  test('closing during load prevents state updates and native opens', () async {
    repo.firstRead = Completer();
    final operation = notifier.loadVideo(1, one);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    notifier.dispose();
    repo.firstRead!.complete(repo.records[1]);
    await operation;
    await Future<void>.delayed(Duration.zero);
    expect(backend.opened, isEmpty);
    expect(backend.disposed, isTrue);
  });
  test('missing file becomes a recoverable error', () async {
    await notifier.loadVideo(1, '${dir.path}/missing.mkv');
    expect(notifier.state.errorCode, 'missing');
    expect(notifier.state.isLoading, isFalse);
    await notifier.loadVideo(1, one);
    expect(notifier.state.errorCode, isNull);
    expect(backend.opened, [one]);
  });
  test('duration failure releases loading and supports retry', () async {
    repo.records[1]!.playbackPositions = [
      PlaybackEntry()
        ..path = one
        ..position = 30
    ];
    backend.failDuration = true;
    await notifier.loadVideo(1, one);
    expect(notifier.state.errorCode, 'load');
    expect(notifier.state.isLoading, isFalse);
    backend.failDuration = false;
    await notifier.loadVideo(1, one);
    expect(notifier.state.isPlaying, isTrue);
    expect(notifier.state.errorCode, isNull);
  });
}
