import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../../../../providers/player/player_provider.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';

class TrackSelectorDialog extends ConsumerWidget {
  const TrackSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final playerState = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);

    return Dialog(
      backgroundColor: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: SizedBox(
        width: 400,
        height: 500,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                unselectedLabelColor: tokens.textMuted,
                tabs: [
                  Tab(
                      icon: Icon(AppIcons.audio),
                      text: context.l10n.playerAudioTracks),
                  Tab(
                      icon: Icon(AppIcons.subtitles),
                      text: context.l10n.playerSubtitleTracks),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTrackList<AudioTrack>(
                      context: context,
                      tracks: playerState.audioTracks,
                      currentTrack: playerState.currentAudio,
                      onSelect: (track) => notifier.setAudioTrack(track),
                      externalSubsMap: playerState.externalSubsMap,
                    ),
                    _buildTrackList<SubtitleTrack>(
                      context: context,
                      tracks: playerState.subtitleTracks,
                      currentTrack: playerState.currentSubtitle,
                      onSelect: (track) => notifier.setSubtitleTrack(track),
                      externalSubsMap: playerState.externalSubsMap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackList<T>({
    required BuildContext context,
    required List<T> tracks,
    required T? currentTrack,
    required Function(T) onSelect,
    required Map<String, List<String>> externalSubsMap,
  }) {
    if (tracks.isEmpty) {
      return Center(
        child: Text(
          context.l10n.playerNoTracks,
          style: TextStyle(color: context.appTheme.textMuted),
        ),
      );
    }

    // Precompute names; list items are rebuilt while scrolling.
    final Map<T, String> trackNames = {};
    final Map<String, int> fileCounters =
        {}; // Disambiguate duplicate subtitle files.

    for (var track in tracks) {
      String name = context.l10n.commonUnknown;

      if (track is AudioTrack) {
        name = track.title ?? track.language ?? track.id;
      } else if (track is SubtitleTrack) {
        String baseName = track.title ?? track.language ?? track.id;

        if (baseName.endsWith('.ass') || baseName.endsWith('.srt')) {
          if (externalSubsMap.containsKey(baseName)) {
            final studios = externalSubsMap[baseName]!;
            int count = fileCounters[baseName] ?? 0;

            // Use the next studio name for each duplicate file.
            if (count < studios.length) {
              name = "[${studios[count]}] $baseName";
              fileCounters[baseName] = count + 1;
            } else {
              name = baseName;
            }
          } else {
            name = baseName;
          }
        } else {
          name = baseName;
        }
      }

      // Friendlier names for special tracks.
      if (track is AudioTrack && track.id == 'auto') {
        name = context.l10n.playerTrackAuto;
      }
      if (track is AudioTrack && track.id == 'no') {
        name = context.l10n.playerTrackOff;
      }
      if (track is SubtitleTrack && track.id == 'auto') {
        name = context.l10n.playerTrackAuto;
      }
      if (track is SubtitleTrack && track.id == 'no') {
        name = context.l10n.playerTrackOff;
      }

      trackNames[track] = name;
    }

    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isSelected = currentTrack == track;
        final trackName = trackNames[track]!;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xxs,
          ),
          title: Text(
            trackName,
            style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : context.appTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isSelected
              ? Icon(
                  AppIcons.check,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          onTap: () {
            onSelect(track);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
