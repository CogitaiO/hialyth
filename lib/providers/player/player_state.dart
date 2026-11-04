import 'package:media_kit/media_kit.dart';
import '../../data/services/aniskip_service.dart';

/// Immutable state for the currently loaded playback session.
class PlayerPlaybackState {
  const PlayerPlaybackState({
    this.animeId,
    this.videoPath,
    this.playlist = const [],
    this.windowTitle,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.isVideoCompleted = false,
    this.skipIntervals = const [],
    this.activeSkip,
  });

  final int? animeId;
  final String? videoPath;
  final List<String> playlist;
  final String? windowTitle;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final bool isVideoCompleted;
  final List<SkipInterval> skipIntervals;
  final SkipInterval? activeSkip;

  PlayerPlaybackState copyWith({
    int? animeId,
    String? videoPath,
    List<String>? playlist,
    String? windowTitle,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    bool? isVideoCompleted,
    List<SkipInterval>? skipIntervals,
    SkipInterval? activeSkip,
    bool clearActiveSkip = false,
  }) {
    return PlayerPlaybackState(
      animeId: animeId ?? this.animeId,
      videoPath: videoPath ?? this.videoPath,
      playlist: playlist ?? this.playlist,
      windowTitle: windowTitle ?? this.windowTitle,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isVideoCompleted: isVideoCompleted ?? this.isVideoCompleted,
      skipIntervals: skipIntervals ?? this.skipIntervals,
      activeSkip: clearActiveSkip ? null : (activeSkip ?? this.activeSkip),
    );
  }
}

/// Window and overlay state that is independent from media playback.
class PlayerUiState {
  const PlayerUiState({
    this.isFullscreen = false,
    this.isUiVisible = true,
    this.isPiP = false,
    this.isSidebarOpen = false,
  });

  final bool isFullscreen;
  final bool isUiVisible;
  final bool isPiP;
  final bool isSidebarOpen;

  PlayerUiState copyWith({
    bool? isFullscreen,
    bool? isUiVisible,
    bool? isPiP,
    bool? isSidebarOpen,
  }) {
    return PlayerUiState(
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isUiVisible: isUiVisible ?? this.isUiVisible,
      isPiP: isPiP ?? this.isPiP,
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
    );
  }
}

/// Audio, subtitle and volume state exposed by media_kit.
class PlayerTracksState {
  const PlayerTracksState({
    this.volume = 100.0,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.currentAudio,
    this.currentSubtitle,
    this.externalSubsMap = const {},
  });

  final double volume;
  final List<AudioTrack> audioTracks;
  final List<SubtitleTrack> subtitleTracks;
  final AudioTrack? currentAudio;
  final SubtitleTrack? currentSubtitle;
  final Map<String, List<String>> externalSubsMap;

  PlayerTracksState copyWith({
    double? volume,
    List<AudioTrack>? audioTracks,
    List<SubtitleTrack>? subtitleTracks,
    AudioTrack? currentAudio,
    SubtitleTrack? currentSubtitle,
    Map<String, List<String>>? externalSubsMap,
  }) {
    return PlayerTracksState(
      volume: volume ?? this.volume,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      currentAudio: currentAudio ?? this.currentAudio,
      currentSubtitle: currentSubtitle ?? this.currentSubtitle,
      externalSubsMap: externalSubsMap ?? this.externalSubsMap,
    );
  }
}

/// Aggregate state exposed to the player UI.
///
/// The flat getters keep the existing widget API stable while the state is
/// internally split into cohesive groups. UI call sites can gradually switch
/// to reading [playback], [ui] and [tracks] directly.
class AppPlayerState {
  const AppPlayerState({
    this.playback = const PlayerPlaybackState(),
    this.ui = const PlayerUiState(),
    this.tracks = const PlayerTracksState(),
  });

  final PlayerPlaybackState playback;
  final PlayerUiState ui;
  final PlayerTracksState tracks;

  int? get animeId => playback.animeId;
  String? get videoPath => playback.videoPath;
  List<String> get playlist => playback.playlist;
  String? get windowTitle => playback.windowTitle;
  bool get isPlaying => playback.isPlaying;
  Duration get position => playback.position;
  Duration get duration => playback.duration;
  double get playbackSpeed => playback.playbackSpeed;
  bool get isVideoCompleted => playback.isVideoCompleted;
  List<SkipInterval> get skipIntervals => playback.skipIntervals;
  SkipInterval? get activeSkip => playback.activeSkip;

  bool get isFullscreen => ui.isFullscreen;
  bool get isUiVisible => ui.isUiVisible;
  bool get isPiP => ui.isPiP;
  bool get isSidebarOpen => ui.isSidebarOpen;

  double get volume => tracks.volume;
  List<AudioTrack> get audioTracks => tracks.audioTracks;
  List<SubtitleTrack> get subtitleTracks => tracks.subtitleTracks;
  AudioTrack? get currentAudio => tracks.currentAudio;
  SubtitleTrack? get currentSubtitle => tracks.currentSubtitle;
  Map<String, List<String>> get externalSubsMap => tracks.externalSubsMap;

  AppPlayerState copyWith({
    PlayerPlaybackState? playback,
    PlayerUiState? ui,
    PlayerTracksState? tracks,
  }) {
    return AppPlayerState(
      playback: playback ?? this.playback,
      ui: ui ?? this.ui,
      tracks: tracks ?? this.tracks,
    );
  }
}
