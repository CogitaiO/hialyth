import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekaido_pre/presentation/player/widgets/skip_interval_track_shape.dart';
import 'track_selector_dialog.dart';
import '../../../../providers/player/player_provider.dart';
import '../../../../domain/anime.dart';
import '../../../../providers/settings_provider.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme_extension.dart';

class PlayerProgressBar extends ConsumerStatefulWidget {
  const PlayerProgressBar({super.key});
  @override
  ConsumerState<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<PlayerProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _isHoveringBar = false;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(playerProvider.select((s) => s.position));
    final duration = ref.watch(playerProvider.select((s) => s.duration));
    final volume = ref.watch(playerProvider.select((s) => s.volume));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final notifier = ref.read(playerProvider.notifier);
    final activeSkips =
        ref.watch(playerProvider.select((s) => s.skipIntervals));
    final playbackSpeed =
        ref.watch(playerProvider.select((s) => s.playbackSpeed));
    final tokens = context.appTheme;
    final accentColor = Color(ref.watch(settingsProvider).accentColorValue);
    double maxDuration = duration.inSeconds.toDouble();
    double currentPosition =
        _isDragging ? _dragValue : position.inSeconds.toDouble();
    if (currentPosition > maxDuration) currentPosition = maxDuration;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHoveringBar = true),
            onExit: (_) => setState(() => _isHoveringBar = false),
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              height: AppSpacing.s20, // Larger hit area for the slider.
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  // Thicken the track on hover or drag.
                  trackHeight: _isHoveringBar || _isDragging ? 4.0 : 2.0,
                  // Hide the thumb when idle.
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius:
                        _isHoveringBar || _isDragging ? 6.0 : 0.0,
                  ),
                  overlayShape: SliderComponentShape
                      .noOverlay, // Remove the Material overlay.
                  activeTrackColor: accentColor,
                  inactiveTrackColor: tokens.borderStrong,
                  thumbColor: accentColor,

                  trackShape: SkipIntervalTrackShape(
                    intervals: activeSkips
                        .map((s) => SkipIntervalDb()
                          ..startTime = s.startTime
                          ..endTime = s.endTime)
                        .toList(),
                    durationInSeconds: maxDuration,
                    skipColor: AppPalette.skipMarker,
                    activeFallbackColor: accentColor,
                    inactiveFallbackColor: tokens.borderStrong,
                  ),
                ),
                child: Slider(
                  value: maxDuration > 0 ? currentPosition : 0.0,
                  min: 0.0,
                  max: maxDuration > 0 ? maxDuration : 1.0,
                  onChangeStart: (val) {
                    setState(() {
                      _isDragging = true;
                      _dragValue = val;
                    });
                  },
                  onChanged: (val) {
                    setState(() {
                      _dragValue = val;
                    });
                  },
                  onChangeEnd: (val) {
                    notifier.seek(Duration(seconds: val.toInt()));
                    setState(() {
                      _isDragging = false;
                    });
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                iconSize: 32,
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: tokens.textPrimary,
                ),
                onPressed: () => notifier.togglePlay(),
              ),
              if (notifier.hasNextEpisode)
                IconButton(
                  iconSize: 28,
                  icon:
                      Icon(Icons.skip_next_rounded, color: tokens.textPrimary),
                  onPressed: () => notifier.playNext(),
                ),
              const SizedBox(width: AppSpacing.xs),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 24,
                    icon: Icon(
                      volume == 0
                          ? Icons.volume_off
                          : (volume < 50 ? Icons.volume_down : Icons.volume_up),
                      color: tokens.textPrimary,
                    ),
                    onPressed: () => notifier.toggleMute(),
                  ),
                  SizedBox(
                    width: 80,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.0,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5.0),
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

              Text(
                '${_format(Duration(seconds: currentPosition.toInt()))} / ${_format(duration)}',
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

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
                  tooltip: "Playback Speed",
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
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: playbackSpeed == speed
                                ? Color(ref
                                    .watch(settingsProvider)
                                    .accentColorValue)
                                : tokens.textSubtle,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            speed == 1.0 ? "Normal" : "${speed}x",
                            style: TextStyle(
                              color: playbackSpeed == speed
                                  ? Color(ref
                                      .watch(settingsProvider)
                                      .accentColorValue)
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
                            ? Color(ref
                                    .watch(settingsProvider)
                                    .accentColorValue)
                                .withValues(alpha: 0.2)
                            : tokens.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                            color: playbackSpeed != 1.0
                                ? Color(ref
                                        .watch(settingsProvider)
                                        .accentColorValue)
                                    .withValues(alpha: 0.5)
                                : Colors.transparent)),
                    child: Text(
                      "${playbackSpeed}x",
                      style: TextStyle(
                        color: playbackSpeed != 1.0
                            ? Color(
                                ref.watch(settingsProvider).accentColorValue)
                            : tokens.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.subtitles_rounded, color: tokens.textPrimary),
                tooltip: "Dubs & Subs",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TrackSelectorDialog(),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_in_picture_alt_rounded,
                  color: tokens.textPrimary,
                ),
                tooltip: "Picture in picture",
                onPressed: () => notifier.togglePiP(),
              ),
              IconButton(
                icon: Icon(
                  Icons.format_list_bulleted_rounded,
                  color: tokens.textPrimary,
                ),
                tooltip: "Episodes and notes",
                onPressed: () => notifier.toggleSideBar(),
              ),
              IconButton(
                iconSize: 28,
                icon: Icon(Icons.fullscreen_rounded, color: tokens.textPrimary),
                onPressed: () => notifier.toggleFullscreen(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) return '${twoDigits(d.inHours)}:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}
