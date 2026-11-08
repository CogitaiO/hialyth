import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/player/player_provider.dart';
import '../../../../providers/library_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../widgets/custom_title_bar.dart';
import 'player_progress_bar.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';
import '../../../../widgets/glass_surface.dart';

class PlayerOverlay extends ConsumerWidget {
  const PlayerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final isVisible = ref.watch(playerProvider.select((s) => s.isUiVisible));
    final activeSkip = ref.watch(playerProvider.select((s) => s.activeSkip));
    final reduceTransparency =
        ref.watch(settingsProvider.select((s) => s.reduceTransparency));

    final videoPath =
        ref.watch(playerProvider.select((s) => s.videoPath)) ?? '';
    final animeId = ref.watch(playerProvider.select((s) => s.animeId));
    final playlist = ref.watch(playerProvider.select((s) => s.playlist));

    final sidebarOpen =
        ref.watch(playerProvider.select((s) => s.isSidebarOpen));

    final isOp = activeSkip?.type == 'op';

    String displayTitle = context.l10n.playerLoading;

    if (videoPath.isNotEmpty) {
      // Start with the file name as a fallback.
      displayTitle = videoPath.split(Platform.pathSeparator).last;
    }

    if (animeId != null) {
      final animeSync = ref.watch(animeDetailsProvider(animeId));
      if (animeSync.value != null) {
        final anime = animeSync.value!;
        // Playlist indices are zero-based.
        final epIndex = playlist.indexOf(videoPath) + 1;

        if (epIndex > 0) {
          displayTitle =
              '${anime.title} · ${context.l10n.playerEpisodeNumber(epIndex)}';
        } else {
          displayTitle = anime.title;
        }
      }
    }

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !isVisible,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            curve: Curves.easeOutCubic,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [tokens.scrim(0.8), Colors.transparent],
                      ),
                    ),
                    child: CustomTitleBar(
                      backgroundColor: Colors.transparent,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: AppSpacing.xxs),
                          Tooltip(
                            message: context.l10n.playerBack,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            margin: const EdgeInsets.only(top: AppSpacing.s10),
                            decoration: BoxDecoration(
                              color:
                                  tokens.surfaceOverlay.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(color: tokens.borderStrong),
                            ),
                            textStyle: TextStyle(
                              color: tokens.textSubtle,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            waitDuration: const Duration(milliseconds: 500),
                            showDuration: const Duration(seconds: 2),
                            child: IconButton(
                              icon: Icon(
                                AppIcons.back,
                                color: tokens.textPrimary,
                                size: 24,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                      ),
                      title: Expanded(
                        child: Text(
                          displayTitle,
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.s64,
                      bottom: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [tokens.scrim(0.9), Colors.transparent],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassSurface(
                        reduceTransparency: reduceTransparency || sidebarOpen,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const PlayerProgressBar(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: 48,
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: activeSkip == null
                ? const SizedBox.shrink(key: ValueKey('empty_skip'))
                : GlassSurface(
                    key: const ValueKey('skip_button'),
                    reduceTransparency: reduceTransparency || sidebarOpen,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: tokens.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      icon: const Icon(AppIcons.skipForward, size: 24),
                      label: Text(
                        isOp
                            ? context.l10n.playerSkipOpening
                            : context.l10n.playerSkipEnding,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ref.read(playerProvider.notifier).seek(Duration(
                            milliseconds: (activeSkip.endTime * 1000).toInt()));
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
