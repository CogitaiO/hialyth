import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n.dart';
import '../../../providers/player/player_provider.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../widgets/animated_state_icon.dart';
import '../../../widgets/play_pause_button.dart';
import 'player_progress_bar.dart';
import 'track_selector_dialog.dart';

enum _PlayerSetting { audio, speed, episodes }

/// Touch controls: actions at the top, transport in the centre, timeline below.
class MobilePlayerOverlay extends ConsumerWidget {
  const MobilePlayerOverlay({super.key, required this.title});

  final String title;

  Future<void> _tracks(BuildContext context, WidgetRef ref, int index) async {
    ref.read(playerProvider.notifier).showUi();
    await showDialog<void>(
      context: context,
      builder: (_) => TrackSelectorDialog(initialIndex: index),
    );
    if (context.mounted) ref.read(playerProvider.notifier).showUi();
  }

  Future<void> _settings(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(playerProvider.notifier);
    notifier.showUi();
    final action = await showModalBottomSheet<_PlayerSetting>(
      context: context,
      useSafeArea: true,
      backgroundColor: context.appTheme.cardSurface,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.audiotrack_outlined),
                title: Text(context.l10n.playerAudioTracks),
                onTap: () => Navigator.pop(sheetContext, _PlayerSetting.audio),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: Text(context.l10n.playerSpeed),
                trailing: Text('${ref.read(playerProvider).playbackSpeed}x'),
                onTap: () => Navigator.pop(sheetContext, _PlayerSetting.speed),
              ),
              ListTile(
                leading: const Icon(Icons.playlist_play),
                title: Text(context.l10n.playerEpisodesNotes),
                onTap: () =>
                    Navigator.pop(sheetContext, _PlayerSetting.episodes),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case _PlayerSetting.audio:
        await _tracks(context, ref, 0);
      case _PlayerSetting.speed:
        final speed = await showModalBottomSheet<double>(
          context: context,
          useSafeArea: true,
          backgroundColor: context.appTheme.cardSurface,
          builder: (sheetContext) => SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final speed in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
                    ListTile(
                      title: Text('${speed}x'),
                      trailing: speed == ref.read(playerProvider).playbackSpeed
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, speed),
                    ),
                ],
              ),
            ),
          ),
        );
        if (!context.mounted) return;
        if (speed != null) notifier.setPlaybackSpeed(speed);
      case _PlayerSetting.episodes:
        notifier.toggleSideBar();
      case null:
        break;
    }
    if (context.mounted) notifier.showUi();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(playerProvider.select((s) => s.isUiVisible));
    final playing = ref.watch(playerProvider.select((s) => s.isPlaying));
    final ready = ref.watch(
      playerProvider.select((s) => !s.isLoading && s.errorCode == null),
    );
    final skip = ref.watch(playerProvider.select((s) => s.activeSkip));
    final episode = ref.watch(
      playerProvider.select((s) {
        final index = s.playlist.indexOf(s.videoPath ?? '');
        return (
          animeId: s.animeId,
          previous: index > 0 ? s.playlist[index - 1] : null,
          hasNext: index >= 0 && index + 1 < s.playlist.length,
        );
      }),
    );
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final notifier = ref.read(playerProvider.notifier);
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 140),
          child: IconButtonTheme(
            data: IconButtonThemeData(
              style: IconButton.styleFrom(foregroundColor: Colors.white),
            ),
            child: Stack(
              children: [
                // Decoration must not consume taps intended for the video.
                const Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xB3000000),
                            Color(0x40000000),
                            Color(0x40000000),
                            Color(0xB3000000),
                          ],
                          stops: [0, 0.3, 0.65, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 28 : 8,
                      8,
                      wide ? 28 : 8,
                      8,
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            children: [
                              IconButton(
                                key: const ValueKey('mobile-player-back'),
                                tooltip: context.l10n.playerBack,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 32,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: wide ? 20 : 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                key: const ValueKey('mobile-player-subtitles'),
                                tooltip: context.l10n.playerSubtitleTracks,
                                icon: const Icon(
                                  Icons.closed_caption_outlined,
                                  size: 28,
                                ),
                                onPressed: () => _tracks(context, ref, 1),
                              ),
                              IconButton(
                                key: const ValueKey('mobile-player-settings'),
                                tooltip: context.l10n.settingsTitle,
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  size: 28,
                                ),
                                onPressed: () => _settings(context, ref),
                              ),
                            ],
                          ),
                        ),
                        if (ready)
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 56,
                                  child:
                                      episode.animeId != null &&
                                          episode.previous != null
                                      ? _TransportButton(
                                          controlKey: const ValueKey(
                                            'mobile-player-previous',
                                          ),
                                          tooltip: context
                                              .l10n
                                              .playerPreviousEpisode,
                                          icon: Icons.skip_previous,
                                          onPressed: () => notifier.loadVideo(
                                            episode.animeId!,
                                            episode.previous!,
                                          ),
                                        )
                                      : null,
                                ),
                                SizedBox(width: wide ? 40 : 24),
                                PlayPauseButton(
                                  key: const ValueKey('mobile-player-play'),
                                  tooltip: context.l10n.playerPlayPause,
                                  playing: playing,
                                  size: 80,
                                  iconSize: 52,
                                  onPressed: notifier.togglePlay,
                                ),
                                SizedBox(width: wide ? 40 : 24),
                                SizedBox(
                                  width: 56,
                                  height: 56,
                                  child:
                                      episode.animeId != null && episode.hasNext
                                      ? _TransportButton(
                                          controlKey: const ValueKey(
                                            'mobile-player-next',
                                          ),
                                          tooltip:
                                              context.l10n.playerNextEpisode,
                                          icon: Icons.skip_next,
                                          onPressed: notifier.playNext,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (skip != null)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => notifier.seek(
                                        Duration(
                                          milliseconds: (skip.endTime * 1000)
                                              .toInt(),
                                        ),
                                      ),
                                      child: Text(
                                        skip.type == 'op'
                                            ? context.l10n.playerSkipOpening
                                            : context.l10n.playerSkipEnding,
                                      ),
                                    ),
                                  ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 12,
                                    bottom: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const PlayerTimeLabel(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const PlayerProgressBar(
                                  timelineOnly: true,
                                  mobileStyle: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({
    required this.controlKey,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final Key controlKey;
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return IconButton(
      key: controlKey,
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 32,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(56),
        backgroundColor: tokens.scrim(.38),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      icon: AnimatedStateIcon(icon),
    );
  }
}
