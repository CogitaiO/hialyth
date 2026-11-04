import 'dart:async';

import 'package:media_kit/media_kit.dart';

/// Event handlers invoked by [PlayerLifecycle].
class PlayerLifecycleHandlers {
  const PlayerLifecycleHandlers({
    required this.onPosition,
    required this.onDuration,
    required this.onPlaying,
    required this.onVolume,
    required this.onTracks,
    required this.onTrack,
    required this.onCompleted,
    required this.onLog,
  });

  final void Function(Duration position) onPosition;
  final void Function(Duration duration) onDuration;
  final void Function(bool playing) onPlaying;
  final void Function(double volume) onVolume;
  final void Function(Tracks tracks) onTracks;
  final void Function(Track track) onTrack;
  final void Function(bool completed) onCompleted;
  final void Function(PlayerLog event) onLog;
}

/// Owns the player's stream subscriptions, timers and load lock.
///
/// The notifier remains responsible for turning the events into state; this
/// class makes sure none of those resources outlive the player session.
class PlayerLifecycle {
  PlayerLifecycle({
    required Stream<Duration> positionStream,
    required Stream<Duration> durationStream,
    required Stream<bool> playingStream,
    required Stream<double> volumeStream,
    required Stream<Tracks> tracksStream,
    required Stream<Track> trackStream,
    required Stream<bool> completedStream,
    required Stream<PlayerLog> logStream,
    required this.handlers,
  })  : _positionStream = positionStream,
        _durationStream = durationStream,
        _playingStream = playingStream,
        _volumeStream = volumeStream,
        _tracksStream = tracksStream,
        _trackStream = trackStream,
        _completedStream = completedStream,
        _logStream = logStream;

  final Stream<Duration> _positionStream;
  final Stream<Duration> _durationStream;
  final Stream<bool> _playingStream;
  final Stream<double> _volumeStream;
  final Stream<Tracks> _tracksStream;
  final Stream<Track> _trackStream;
  final Stream<bool> _completedStream;
  final Stream<PlayerLog> _logStream;

  final PlayerLifecycleHandlers handlers;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Timer? _uiHideTimer;
  Timer? _nextEpisodeTimer;
  bool _loading = false;
  bool _started = false;
  bool _disposed = false;

  bool get isLoading => _loading;

  void start() {
    if (_started || _disposed) return;
    _started = true;

    _subscriptions.add(_positionStream.listen(handlers.onPosition));
    _subscriptions.add(_durationStream.listen(handlers.onDuration));
    _subscriptions.add(_playingStream.listen(handlers.onPlaying));
    _subscriptions.add(_volumeStream.listen(handlers.onVolume));
    _subscriptions.add(_tracksStream.listen(handlers.onTracks));
    _subscriptions.add(_trackStream.listen(handlers.onTrack));
    _subscriptions.add(_completedStream.listen(handlers.onCompleted));
    _subscriptions.add(_logStream.listen(handlers.onLog));
  }

  /// Returns false when another load is already in progress.
  bool beginLoading() {
    if (_loading || _disposed) return false;
    _loading = true;
    return true;
  }

  void endLoading() {
    _loading = false;
  }

  void scheduleUiHide(Duration delay, void Function() onHide) {
    _uiHideTimer?.cancel();
    if (_disposed) return;
    _uiHideTimer = Timer(delay, onHide);
  }

  void cancelUiHide() {
    _uiHideTimer?.cancel();
    _uiHideTimer = null;
  }

  void scheduleNextEpisode(Duration delay, void Function() onNext) {
    _nextEpisodeTimer?.cancel();
    if (_disposed) return;
    _nextEpisodeTimer = Timer(delay, onNext);
  }

  void cancelNextEpisode() {
    _nextEpisodeTimer?.cancel();
    _nextEpisodeTimer = null;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    cancelUiHide();
    cancelNextEpisode();

    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    _loading = false;
  }
}
