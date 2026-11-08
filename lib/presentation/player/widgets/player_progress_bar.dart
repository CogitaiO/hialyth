import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'track_selector_dialog.dart';
import '../../../../providers/player/player_provider.dart';
import '../../../../domain/anime.dart';
import 'playback_timeline.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';

class PlayerProgressBar extends StatelessWidget {
  const PlayerProgressBar({super.key});

  @override
  Widget build(BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(child: _PlayerTimeline()),
          SizedBox(height: 4),
          _TransportControls(),
        ],
      );
}

class _TransportControls extends ConsumerWidget {
  const _TransportControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(playerProvider.select((s) => s.volume));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final playbackSpeed =
        ref.watch(playerProvider.select((s) => s.playbackSpeed));
    final hasNextEpisode = ref.watch(playerProvider.select((s) {
      final index = s.playlist.indexOf(s.videoPath ?? '');
      return index >= 0 && index + 1 < s.playlist.length;
    }));
    final notifier = ref.read(playerProvider.notifier);
    final tokens = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            iconSize: 32,
            tooltip: context.l10n.playerPlayPause,
            icon: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Icon(isPlaying ? AppIcons.pause : AppIcons.play,
                  key: ValueKey(isPlaying), color: tokens.textPrimary),
            ),
            onPressed: () => notifier.togglePlay(),
          ),
          IconButton(
            iconSize: 28,
            icon: Icon(AppIcons.next, color: tokens.textPrimary),
            tooltip: context.l10n.playerNextEpisode,
            onPressed: hasNextEpisode ? () => notifier.playNext() : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 24,
                tooltip: context.l10n.playerMute,
                icon: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Icon(
                    volume == 0
                        ? AppIcons.volumeOff
                        : (volume < 50
                            ? AppIcons.volumeDown
                            : AppIcons.volumeUp),
                    key: ValueKey(volume == 0 ? 0 : (volume < 50 ? 1 : 2)),
                    color: tokens.textPrimary,
                  ),
                ),
                onPressed: () => notifier.toggleMute(),
              ),
              if (MediaQuery.sizeOf(context).width >= 900)
                SizedBox(
                  width: 80,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.0,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: tokens.textPrimary,
                      inactiveTrackColor: tokens.borderStrong,
                      thumbColor: tokens.textPrimary,
                    ),
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 100.0,
                      onChanged: (val) => notifier.setVolume(val),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          const _PlaybackTimeLabel(),
          const Spacer(),
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: tokens.cardSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
            ),
            child: PopupMenuButton<double>(
              tooltip: context.l10n.playerSpeed,
              offset: const Offset(0, -250),
              onSelected: (speed) => notifier.setPlaybackSpeed(speed),
              itemBuilder: (context) =>
                  [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                return PopupMenuItem<double>(
                  value: speed,
                  child: Row(
                    children: [
                      Icon(
                        playbackSpeed == speed
                            ? AppIcons.checkCircle
                            : AppIcons.circleOutline,
                        color: playbackSpeed == speed
                            ? Theme.of(context).colorScheme.primary
                            : tokens.textSubtle,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        speed == 1.0
                            ? context.l10n.playerSpeedNormal
                            : "${speed}x",
                        style: TextStyle(
                          color: playbackSpeed == speed
                              ? Theme.of(context).colorScheme.primary
                              : tokens.textPrimary,
                          fontWeight: playbackSpeed == speed
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s6,
                ),
                decoration: BoxDecoration(
                    color: playbackSpeed != 1.0
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2)
                        : tokens.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                        color: playbackSpeed != 1.0
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5)
                            : Colors.transparent)),
                child: Text(
                  "${playbackSpeed}x",
                  style: TextStyle(
                    color: playbackSpeed != 1.0
                        ? Theme.of(context).colorScheme.primary
                        : tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.subtitles, color: tokens.textPrimary),
            tooltip: context.l10n.playerDubsSubs,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const TrackSelectorDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              AppIcons.pip,
              color: tokens.textPrimary,
            ),
            tooltip: context.l10n.playerPictureInPicture,
            onPressed: () => notifier.togglePiP(),
          ),
          IconButton(
            icon: Icon(
              AppIcons.playlist,
              color: tokens.textPrimary,
            ),
            tooltip: context.l10n.playerEpisodesNotes,
            onPressed: () => notifier.toggleSideBar(),
          ),
          IconButton(
            iconSize: 28,
            tooltip: context.l10n.playerFullscreen,
            icon: Icon(AppIcons.fullscreen, color: tokens.textPrimary),
            onPressed: () => notifier.toggleFullscreen(),
          ),
        ],
      ),
    );
  }
}

class _PlayerTimeline extends ConsumerWidget {
  const _PlayerTimeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(playerProvider
        .select((s) => (s.animeId, s.videoPath, s.playback.sessionId)));
    final duration = ref.watch(playerProvider.select((s) => s.duration));
    final playing = ref.watch(playerProvider.select((s) => s.isPlaying));
    final visible = ref.watch(playerProvider.select((s) => s.isUiVisible));
    final intervals = ref.watch(playerProvider.select((s) => s.skipIntervals));
    final notifier = ref.read(playerProvider.notifier);
    return StreamBuilder<Duration>(
      key: ValueKey(identity),
      stream: visible ? notifier.player.stream.position : null,
      initialData: ref.read(playerProvider).position,
      builder: (context, snapshot) => PlaybackTimeline(
        position: snapshot.data ?? Duration.zero,
        duration: duration,
        playing: playing && visible,
        intervals: intervals
            .map((s) => SkipIntervalDb()
              ..startTime = s.startTime
              ..endTime = s.endTime)
            .toList(),
        onSeek: notifier.seek,
      ),
    );
  }
}

class _PlaybackTimeLabel extends ConsumerWidget {
  const _PlaybackTimeLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds =
        ref.watch(playerProvider.select((s) => s.position.inSeconds));
    final duration = ref.watch(playerProvider.select((s) => s.duration));
    return Text('${_format(Duration(seconds: seconds))} / ${_format(duration)}',
        style:
            AppTypography.mono.copyWith(color: context.appTheme.textSecondary));
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return d.inHours > 0
        ? '${twoDigits(d.inHours)}:$minutes:$seconds'
        : '$minutes:$seconds';
  }
}
