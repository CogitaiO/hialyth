import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/anime.dart';
import '../../data/repositories/anime_repository.dart';
import '../../data/services/aniskip_service.dart';
import '../../data/services/anime_filename_parser.dart';
import '../../data/services/playback_progress_service.dart';
import '../../providers/repositories_provider.dart';
import 'playback_engine.dart';
import 'playback_progress_tracker.dart';
import 'player_lifecycle.dart';
import 'player_state.dart';
import '../../core/logger.dart';
import '../library_provider.dart';
import '../../data/services/discord_service.dart';

final playerProvider =
    StateNotifierProvider.autoDispose<PlayerNotifier, AppPlayerState>((ref) {
  final repo = ref.watch(animeRepoProvider);
  // SharedPreferences is stable, so watching it is safe.
  final prefs = ref.watch(sharedPrefsProvider);
  return PlayerNotifier(repo, prefs);
});

class PlayerNotifier extends StateNotifier<AppPlayerState> {
  final SharedPreferences _prefs;
  final AnimeRepository _repository;
  final PlaybackProgressTracker _progress;
  final PlaybackEngine _engine;
  late final PlayerLifecycle _lifecycle;
  final DiscordService _discordService = DiscordService();

  int _lastStateSeconds = -1; // Throttle UI updates to one per second.
  bool _isAutoSkipping = false;
  bool _wasFullScreen = false;
  bool _wasMaximized = false;
  Size _previousSize = const Size(1280, 720);
  Offset _previousPosition = Offset.zero;
  double _lastVolume = 100.0;

  Player get player => _engine.player;

  PlayerNotifier(
    AnimeRepository repository,
    SharedPreferences prefs, {
    PlaybackProgressTracker? progress,
    PlaybackEngine? engine,
  })  : _repository = repository,
        _prefs = prefs,
        _progress = progress ??
            PlaybackProgressTracker(PlaybackProgressService(repository)),
        _engine = engine ?? PlaybackEngine(),
        super(AppPlayerState(
          tracks: PlayerTracksState(
            volume: prefs.getDouble('player_volume') ?? 100.0,
          ),
        )) {
    _lifecycle = PlayerLifecycle(
      positionStream: _engine.positionStream,
      durationStream: _engine.durationStream,
      playingStream: _engine.playingStream,
      volumeStream: _engine.volumeStream,
      tracksStream: _engine.tracksStream,
      trackStream: _engine.trackStream,
      completedStream: _engine.completedStream,
      logStream: _engine.logStream,
      handlers: PlayerLifecycleHandlers(
        onPosition: _handlePosition,
        onDuration: _handleDuration,
        onPlaying: _handlePlaying,
        onVolume: _handleVolume,
        onTracks: _handleTracks,
        onTrack: _handleTrack,
        onCompleted: _handleCompleted,
        onLog: _handleLog,
      ),
    );
    _initPlayer();
  }

  void _initPlayer() {
    _engine.initialize(
      volume: _prefs.getDouble('player_volume') ?? 100.0,
      audioLanguages: _prefs.getString('pref_alang') ?? 'jpn,jp,eng,en,rus,ru',
      subtitleLanguages: _prefs.getString('pref_slang') ?? 'rus,ru,eng,en',
    );
    _lifecycle.start();
  }

  void _handlePosition(Duration pos) {
    final currentSeconds = pos.inSeconds;
    SkipInterval? currentActiveSkip;
    final currentPosInDouble = pos.inMilliseconds / 1000.0;

    for (var skip in state.skipIntervals) {
      if (currentPosInDouble >= skip.startTime &&
          currentPosInDouble <= skip.endTime) {
        currentActiveSkip = skip;

        if (_prefs.getBool('pref_autoskip') == true && !_isAutoSkipping) {
          _isAutoSkipping = true;
          talker.info('Auto-skipping ${skip.type}...');

          _engine.seek(
            Duration(milliseconds: (skip.endTime * 1000).toInt() + 500),
          );

          Future.delayed(const Duration(seconds: 2), () {
            _isAutoSkipping = false;
          });
        }
        break;
      }
    }

    if (state.activeSkip != currentActiveSkip) {
      talker.debug(
        'AniSkip UI trigger: button changed to -> '
        '${currentActiveSkip?.type ?? "Hidden"}',
      );
      state = state.copyWith(
        playback: state.playback.copyWith(
          activeSkip: currentActiveSkip,
          clearActiveSkip: currentActiveSkip == null,
        ),
      );
    }

    if (currentSeconds != _lastStateSeconds) {
      _lastStateSeconds = currentSeconds;
      state = state.copyWith(
        playback: state.playback.copyWith(position: pos),
      );
    }

    unawaited(_progress.onPosition(
      animeId: state.animeId,
      videoPath: state.videoPath,
      position: state.position,
      duration: state.duration,
    ));
  }

  void _handleDuration(Duration dur) {
    state = state.copyWith(
      playback: state.playback.copyWith(duration: dur),
    );
  }

  void _handlePlaying(bool playing) {
    state = state.copyWith(
      playback: state.playback.copyWith(isPlaying: playing),
    );
    if (playing) {
      _startUiHider();
    } else {
      unawaited(_progress.saveNow(
        animeId: state.animeId,
        videoPath: state.videoPath,
        position: state.position,
      ));
    }
  }

  void _handleVolume(double vol) {
    state = state.copyWith(
      tracks: state.tracks.copyWith(volume: vol),
    );
  }

  void _handleTracks(Tracks tracks) {
    state = state.copyWith(
      tracks: state.tracks.copyWith(
        audioTracks: tracks.audio,
        subtitleTracks: tracks.subtitle,
      ),
    );
  }

  void _handleTrack(Track track) {
    state = state.copyWith(
      tracks: state.tracks.copyWith(
        currentAudio: track.audio,
        currentSubtitle: track.subtitle,
      ),
    );
  }

  void _handleCompleted(bool completed) {
    if (!completed || !hasNextEpisode) return;

    state = state.copyWith(
      playback: state.playback.copyWith(isVideoCompleted: true),
    );

    _lifecycle.scheduleNextEpisode(const Duration(seconds: 5), () {
      if (mounted && state.isVideoCompleted) {
        playNext();
      }
    });
  }

  void _handleLog(PlayerLog event) {
    final msg = '[MPV ${event.prefix}] ${event.text}';
    if (event.level == 'fatal' || event.level == 'error') {
      talker.error(msg);
    } else if (event.level == 'warn') {
      talker.warning(msg);
    } else if (event.level == 'info') {
      talker.info(msg);
    } else {
      talker.debug(msg);
    }
  }

  void setVolume(double value) {
    _engine.setVolume(value);
    _prefs.setDouble('player_volume', value);
    showUi();
  }

  void changeVolume(double delta) {
    double newVolume = (state.volume + delta).clamp(0.0, 100.0);
    setVolume(newVolume);
  }

  void toggleMute() {
    if (state.volume > 0) {
      _lastVolume = state.volume;
      setVolume(0.0);
    } else {
      // Restore the previous volume, or 100 if it was zero.
      setVolume(_lastVolume > 0 ? _lastVolume : 100.0);
    }
  }

  void cancelAutoPlay() {
    _lifecycle.cancelNextEpisode();
    state = state.copyWith(
      playback: state.playback.copyWith(isVideoCompleted: false),
    );
  }

  bool get hasNextEpisode {
    final currentIndex = state.playlist.indexOf(state.videoPath ?? '');
    return currentIndex != -1 && currentIndex + 1 < state.playlist.length;
  }

  Future<void> playNext() async {
    if (!hasNextEpisode || state.animeId == null) return;

    final currentIndex = state.playlist.indexOf(state.videoPath!);
    final nextPath = state.playlist[currentIndex + 1];

    await loadVideo(state.animeId!, nextPath);
  }

  Future<void> loadVideo(int animeId, String path) async {
    if (!_lifecycle.beginLoading()) {
      talker.warning('loadVideo: Blocked (already loading)');
      return;
    }

    try {
      talker.info('loadVideo: START LOADING: $path');
      _lifecycle.cancelNextEpisode();
      if (!File(path).existsSync()) {
        talker.error('loadVideo: File not found!');
        return;
      }

      final subsMap = await _applyExternalMedia(path);
      final anime = await _repository.getAnimeById(animeId);
      final savedSeconds = _progress.restore(anime, path);
      List<SkipInterval> skips = [];

      if (anime != null) {
        final existingData =
            anime.skipData.where((e) => e.episodePath == path).firstOrNull;

        if (existingData != null) {
          skips = existingData.intervals
              .map((i) => SkipInterval(
                  type: i.type ?? 'op',
                  startTime: i.startTime ?? 0.0,
                  endTime: i.endTime ?? 0.0))
              .toList();
          talker
              .info('AniSkip: Timestamps loaded from local DB (instant)');
        } else {
          // No cached timestamps: fetch them from AniSkip.
          if (anime.shikimoriId == null) {
            talker.warning(
                'AniSkip: Skipping unavailable. shikimoriId = null (Use "Refresh data from network" on the poster)');
          } else {
            final fileName = path.split(Platform.pathSeparator).last;

            final epNumber = AnimeFilenameParser.parseEpisodeNumber(fileName);

            if (epNumber != null) {
              talker.info(
                  'AniSkip: DB is empty. Fetching timestamps for episode $epNumber (MAL ID: ${anime.shikimoriId}) from network...');
              skips = await AniSkipService()
                  .getSkipTimes(anime.shikimoriId!, epNumber);

              if (skips.isNotEmpty) {
                final newSkipDb = EpisodeSkipData()
                  ..episodePath = path
                  ..intervals = skips
                      .map((s) => SkipIntervalDb()
                        ..type = s.type
                        ..startTime = s.startTime
                        ..endTime = s.endTime)
                      .toList();

                anime.skipData = [...anime.skipData, newSkipDb];
                await _repository.saveAnime(anime);
                talker.info('AniSkip: Timestamps saved to DB!');
              } else {
                talker.info(
                    'AniSkip: Server did not find timestamps for this episode (or no one has added them yet).');
              }
            } else {
              talker.warning(
                  'AniSkip: Failed to parse episode number from file: $fileName');
            }
            for (var s in skips) {
              talker.info(
                  'AniSkip: ${s.type} from ${s.startTime.toInt()} to ${s.endTime.toInt()} seconds');
            }
          }
        }
      }

      talker.info('LOADING VIDEO: Saved position = $savedSeconds sec.');

      // Reset per-video state.
      _lastStateSeconds = -1;

      state = state.copyWith(
        playback: state.playback.copyWith(
          animeId: animeId,
          videoPath: path,
          windowTitle: anime?.title,
          isPlaying: false,
          position: Duration.zero,
          isVideoCompleted: false,
          playlist: anime?.sortedEpisodes ?? [],
          skipIntervals: skips,
          activeSkip: null,
          clearActiveSkip: true,
        ),
        tracks: state.tracks.copyWith(externalSubsMap: subsMap),
      );

      await _engine.open(path);
      if (savedSeconds > 0) {
        await _engine.waitForDuration();
        await _engine.seek(Duration(seconds: savedSeconds));
      }

      await _engine.play();
      _startUiHider();
      _discordService.updatePresence(
        title: anime?.title ?? 'Anime',
        episode: 'Watching',
        currentPositionSeconds: savedSeconds,
        durationSeconds:
            state.duration.inSeconds > 0 ? state.duration.inSeconds : null,
        isPlaying: true,
      );
    } finally {
      // Always release the load lock.
      _lifecycle.endLoading();
    }
  }

  Future<Map<String, List<String>>> _applyExternalMedia(
      String videoPath) async {
    Map<String, List<String>> subsMap = {};
    try {
      final parentDir = File(videoPath).parent;
      Set<String> audioDirs = {};
      Set<String> subDirs = {};
      String? fontsDir;

      await for (var entity
          in parentDir.list(recursive: true, followLinks: false)) {
        final path = entity.path;
        final pathLower = path.toLowerCase();

        if (entity is File) {
          if (pathLower.endsWith('.mka') ||
              pathLower.endsWith('.m4a') ||
              pathLower.endsWith('.ac3') ||
              pathLower.endsWith('.flac')) {
            audioDirs.add(entity.parent.path);
          } else if (pathLower.endsWith('.ass') || pathLower.endsWith('.srt')) {
            subDirs.add(entity.parent.path);

            final parts = entity.parent.path.replaceAll('\\', '/').split('/');
            String folderName = parts.last;
            if (parts.length > 1 &&
                (folderName.toLowerCase() == 'надписи' ||
                    folderName.toLowerCase() == 'signs')) {
              folderName = "${parts[parts.length - 2]} $folderName";
            }

            final fileName = entity.uri.pathSegments.last;
            subsMap.putIfAbsent(fileName, () => []).add(folderName);
          }
        } else if (entity is Directory) {
          if (pathLower.endsWith('fonts') || pathLower.endsWith('шрифты')) {
            fontsDir = path;
          }
        }
      }

      _engine.setProperty('sub-auto', 'fuzzy');
      _engine.setProperty('audio-file-auto', 'fuzzy');
      String sep = Platform.isWindows ? ';' : ':';

      final sortedAudioDirs = audioDirs.toList()..sort();
      final sortedSubDirs = subDirs.toList()..sort();

      if (sortedAudioDirs.isNotEmpty) {
        _engine.setProperty('audio-file-paths', sortedAudioDirs.join(sep));
      }
      if (sortedSubDirs.isNotEmpty) {
        _engine.setProperty('sub-file-paths', sortedSubDirs.join(sep));
      }
      if (fontsDir != null) _engine.setProperty('sub-fonts-dir', fontsDir);
    } catch (e, st) {
      talker.handle(e, st, 'Failed to auto-detect external media');
    }

    return subsMap;
  }

  void togglePlay() {
    _engine.playOrPause();
    unawaited(_progress.saveNow(
      animeId: state.animeId,
      videoPath: state.videoPath,
      position: state.position,
    ));
    _startUiHider();

    final isGoingToPlay = !state.isPlaying;

    String epString = "Watching";
    if (state.videoPath != null) {
      final epIndex = state.playlist.indexOf(state.videoPath!) + 1;
      if (epIndex > 0) epString = 'Episode $epIndex';
    }

    _discordService.updatePresence(
      title: state.windowTitle ?? 'Anime',
      episode: isGoingToPlay ? epString : 'Paused',
      currentPositionSeconds: state.position.inSeconds,
      durationSeconds: state.duration.inSeconds,
      isPlaying: isGoingToPlay,
    );
  }

  void seek(Duration position) => _engine.seek(position);

  void toggleUi() {
    state = state.copyWith(
      ui: state.ui.copyWith(isUiVisible: !state.isUiVisible),
    );

    _engine.setProperty('sub-pos', state.isUiVisible ? '88' : '100');

    if (state.isUiVisible) _startUiHider();
  }

  void showUi() {
    if (!state.isUiVisible) {
      state = state.copyWith(ui: state.ui.copyWith(isUiVisible: true));
    }
    _startUiHider();
  }

  void _startUiHider() {
    _lifecycle.cancelUiHide();
    if (!state.isUiVisible) return;

    _lifecycle.scheduleUiHide(const Duration(seconds: 3), () {
      if (mounted && state.isPlaying && !state.isSidebarOpen) {
        state = state.copyWith(ui: state.ui.copyWith(isUiVisible: false));
      }
    });
  }

  void setAudioTrack(AudioTrack track) {
    _engine.setAudioTrack(track);
  }

  void setSubtitleTrack(SubtitleTrack track) {
    _engine.setSubtitleTrack(track);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _discordService.clearPresence();
    final finalSeconds = state.position.inSeconds;
    final finalPath = state.videoPath;
    final finalId = state.animeId;
    final duration = state.duration.inSeconds;

    if (finalId != null && finalPath != null && finalSeconds > 5) {
      if (duration > 0 && (duration - finalSeconds) < 5) {
        talker.info('EXIT: Resetting position for $finalPath');
      } else {
        talker.info('EXIT: Saving position $finalSeconds sec.');
      }

      unawaited(_progress.finalize(
        animeId: finalId,
        videoPath: finalPath,
        position: Duration(seconds: finalSeconds),
        duration: Duration(seconds: duration),
      ));
    }

    if (state.isPiP) {
      windowManager.setAlwaysOnTop(false);
      windowManager.setMinimumSize(const Size(800, 600));
      windowManager.setSize(_previousSize);
      windowManager.setPosition(_previousPosition);
    }

    final engineToDispose = _engine;
    Future.delayed(const Duration(milliseconds: 300), () {
      engineToDispose.dispose();
    });

    super.dispose();
  }

  void setPlaybackSpeed(double speed) {
    _engine.setRate(speed);
    state = state.copyWith(
      playback: state.playback.copyWith(playbackSpeed: speed),
    );
    talker.info('Playback speed set to ${speed}x');
    showUi();
  }

  void seekRelative(int seconds) {
    int newSeconds = state.position.inSeconds + seconds;
    if (newSeconds < 0) newSeconds = 0;
    if (state.duration.inSeconds > 0 && newSeconds > state.duration.inSeconds) {
      newSeconds = state.duration.inSeconds;
    }

    _engine.seek(Duration(seconds: newSeconds));
    showUi();
    talker.debug('Seek relative: $seconds sec. New pos: $newSeconds');
  }

  Future<void> toggleFullscreen() async {
    // windowManager is desktop-only; calling it on mobile would crash.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final isFull = await windowManager.isFullScreen();
      await windowManager.setFullScreen(!isFull);
    }
  }

  void toggleSideBar() {
    state = state.copyWith(
      ui: state.ui.copyWith(isSidebarOpen: !state.isSidebarOpen),
    );
    if (state.isSidebarOpen) {
      showUi();
    } else {
      _startUiHider();
    }
  }

  Future<void> togglePiP() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (state.isPiP) {
        // Exit PiP.
        await windowManager.setAlwaysOnTop(false);
        // Restore the default minimum window size.
        await windowManager.setMinimumSize(const Size(800, 600));

        if (_wasFullScreen) {
          await windowManager.setFullScreen(true);
        } else if (_wasMaximized) {
          await windowManager.maximize();
        } else {
          await windowManager.setSize(_previousSize);
          await windowManager.setPosition(_previousPosition);
        }
        state = state.copyWith(ui: state.ui.copyWith(isPiP: false));
        talker.info('Exiting PiP mode');
      } else {
        // Enter PiP.
        _wasFullScreen = await windowManager.isFullScreen();
        _wasMaximized = await windowManager.isMaximized();
        _previousSize = await windowManager.getSize();
        _previousPosition = await windowManager.getPosition();

        if (_wasFullScreen) {
          await windowManager.setFullScreen(false);
        }

        state = state.copyWith(
            ui: state.ui.copyWith(
                isPiP:
                    true)); // Update the UI before resizing to avoid RenderFlex errors.
        await Future.delayed(
            const Duration(milliseconds: 50)); // Let the UI rebuild.

        await windowManager.setAlwaysOnTop(true);
        // Allow resizing the PiP window down to 320x180.
        await windowManager.setMinimumSize(const Size(320, 180));
        await windowManager.setSize(const Size(400, 225));
        await windowManager.setAlignment(Alignment.bottomRight);

        talker.info('Entering PiP mode');
      }
    }
  }
}
