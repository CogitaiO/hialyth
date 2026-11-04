import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nekaido_pre/data/services/aniskip_service.dart';
import 'package:nekaido_pre/providers/player/player_state.dart';

void main() {
  group('AppPlayerState', () {
    test('starts with playback, UI and track defaults', () {
      const state = AppPlayerState();

      expect(state.animeId, isNull);
      expect(state.videoPath, isNull);
      expect(state.playlist, isEmpty);
      expect(state.isPlaying, isFalse);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.playbackSpeed, 1.0);
      expect(state.isVideoCompleted, isFalse);

      expect(state.isFullscreen, isFalse);
      expect(state.isUiVisible, isTrue);
      expect(state.isPiP, isFalse);
      expect(state.isSidebarOpen, isFalse);

      expect(state.volume, 100.0);
      expect(state.audioTracks, isEmpty);
      expect(state.subtitleTracks, isEmpty);
      expect(state.currentAudio, isNull);
      expect(state.currentSubtitle, isNull);
      expect(state.externalSubsMap, isEmpty);
    });

    test('updates only the selected state group', () {
      const state = AppPlayerState();

      final updated = state.copyWith(
        playback: state.playback.copyWith(
          animeId: 7,
          videoPath: '/anime/7/01.mkv',
          playlist: const ['/anime/7/01.mkv', '/anime/7/02.mkv'],
          position: const Duration(seconds: 42),
          duration: const Duration(minutes: 24),
          isPlaying: true,
          playbackSpeed: 1.25,
        ),
        ui: state.ui.copyWith(isUiVisible: false, isSidebarOpen: true),
        tracks: state.tracks.copyWith(
          volume: 65,
          audioTracks: const [AudioTrack('jpn', null, null)],
          subtitleTracks: const [SubtitleTrack('rus', null, null)],
        ),
      );

      expect(updated.animeId, 7);
      expect(updated.videoPath, '/anime/7/01.mkv');
      expect(updated.playlist, ['/anime/7/01.mkv', '/anime/7/02.mkv']);
      expect(updated.position, const Duration(seconds: 42));
      expect(updated.duration, const Duration(minutes: 24));
      expect(updated.isPlaying, isTrue);
      expect(updated.playbackSpeed, 1.25);

      expect(updated.isUiVisible, isFalse);
      expect(updated.isSidebarOpen, isTrue);
      expect(updated.isPiP, isFalse);

      expect(updated.volume, 65);
      expect(updated.audioTracks, const [AudioTrack('jpn', null, null)]);
      expect(updated.subtitleTracks, const [SubtitleTrack('rus', null, null)]);
    });

    test('keeps flat getters in sync with grouped state', () {
      final skip = SkipInterval(type: 'op', startTime: 10, endTime: 90);
      final playback = PlayerPlaybackState(
        animeId: 3,
        videoPath: '/anime/3/02.mkv',
        windowTitle: 'Test Anime',
        isPlaying: true,
        skipIntervals: [skip],
        activeSkip: skip,
      );
      const ui = PlayerUiState(isFullscreen: true, isPiP: true);
      const tracks = PlayerTracksState(
        volume: 55,
        externalSubsMap: {
          '02.ass': ['Надписи'],
        },
      );

      final state = AppPlayerState(playback: playback, ui: ui, tracks: tracks);

      expect(state.animeId, 3);
      expect(state.videoPath, '/anime/3/02.mkv');
      expect(state.windowTitle, 'Test Anime');
      expect(state.isPlaying, isTrue);
      expect(state.skipIntervals, [skip]);
      expect(state.activeSkip, skip);
      expect(state.isFullscreen, isTrue);
      expect(state.isPiP, isTrue);
      expect(state.volume, 55);
      expect(state.externalSubsMap, {
        '02.ass': ['Надписи'],
      });
    });

    test('clearActiveSkip removes the active interval', () {
      final skip = SkipInterval(type: 'ed', startTime: 1300, endTime: 1380);
      final state = AppPlayerState(
        playback: PlayerPlaybackState(activeSkip: skip),
      );

      final cleared = state.copyWith(
        playback: state.playback.copyWith(clearActiveSkip: true),
      );

      expect(cleared.activeSkip, isNull);
    });
  });
}
