import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/anime.dart';
import '../../../../widgets/anime_artwork.dart';
import '../../../../providers/repositories_provider.dart';
import '../../player/player_screen.dart';
import '../dialogs/anime_dialogs.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';

class LeftControlPanel extends ConsumerWidget {
  final Anime anime;
  final Color accentColor;
  final String heroTag;
  final bool showPoster;

  const LeftControlPanel({
    super.key,
    required this.anime,
    required this.accentColor,
    required this.heroTag,
    this.showPoster = true,
  });

  void _playEpisode(BuildContext context, String path) {
    if (!File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.detailsMissingFile),
          backgroundColor: context.appTheme.destructive,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PlayerScreen(animeId: anime.id, videoPath: path)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final sortedEpisodes = anime.sortedEpisodes;
    final nextEpisodePath = anime.nextEpisodeToPlay ??
        (sortedEpisodes.isNotEmpty ? sortedEpisodes.first : '');
    final nextEpisodeIndex = sortedEpisodes.isNotEmpty
        ? sortedEpisodes.indexOf(nextEpisodePath) + 1
        : 0;
    final isAllWatched = anime.nextEpisodeToPlay == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPoster)
          AspectRatio(
              aspectRatio: 2 / 3,
              child: Hero(
                  tag: heroTag,
                  child: AnimeArtwork(
                      cover: anime.coverUrl, radius: 16, cacheWidth: 560))),
        if (showPoster) const SizedBox(height: AppSpacing.lg),
        if (sortedEpisodes.isNotEmpty)
          ElevatedButton(
            onPressed: () => _playEpisode(context, nextEpisodePath),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              backgroundColor:
                  isAllWatched ? tokens.surfaceDisabled : accentColor,
              foregroundColor: isAllWatched
                  ? tokens.textPrimary
                  : Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isAllWatched ? AppIcons.replay : AppIcons.play, size: 26),
                Transform.translate(
                  offset: const Offset(0, -1.5),
                  child: Text(
                    isAllWatched
                        ? context.l10n.detailsReplay
                        : context.l10n.detailsEpisodeNumber(nextEpisodeIndex),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, height: 1.1),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs)
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
                flex: 2,
                child: _StatusMenu(anime: anime, accentColor: accentColor)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
                flex: 1,
                child: _HoverButton(
                  icon: AppIcons.collectionAdd,
                  tooltip: context.l10n.detailsCollection,
                  accentColor: accentColor,
                  onTap: () => AnimeDialogs.showCollectionDialog(
                      context, ref, anime, accentColor),
                )),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
                flex: 1,
                child: _MoreMenu(anime: anime, accentColor: accentColor)),
          ],
        )
      ],
    );
  }
}

class _StatusMenu extends ConsumerWidget {
  final Anime anime;
  final Color accentColor;
  const _StatusMenu({required this.anime, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(tokens.cardSurface),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () => ref
              .read(animeRepoProvider)
              .updateStatus(anime.id, AnimeStatus.planned),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.md,
            ),
            child: Text(
              context.l10n.statusPlanned,
              style: TextStyle(color: tokens.textPrimary),
            ),
          ),
        ),
        MenuItemButton(
          onPressed: () => ref
              .read(animeRepoProvider)
              .updateStatus(anime.id, AnimeStatus.watching),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.md,
            ),
            child: Text(context.l10n.statusWatching,
                style: TextStyle(color: tokens.info)),
          ),
        ),
        MenuItemButton(
          onPressed: () => ref
              .read(animeRepoProvider)
              .updateStatus(anime.id, AnimeStatus.completed),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.md,
            ),
            child: Text(
              context.l10n.statusCompleted,
              style: TextStyle(color: tokens.success),
            ),
          ),
        ),
        MenuItemButton(
          onPressed: () => ref
              .read(animeRepoProvider)
              .updateStatus(anime.id, AnimeStatus.dropped),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(context.l10n.statusDropped)),
        ),
      ],
      builder: (context, controller, child) {
        return Material(
          color: tokens.surfaceSubtle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: BorderSide(color: tokens.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    anime.status == AnimeStatus.planned
                        ? context.l10n.statusPlanned
                        : anime.status == AnimeStatus.watching
                            ? context.l10n.statusWatching
                            : anime.status == AnimeStatus.completed
                                ? context.l10n.statusCompleted
                                : context.l10n.statusDropped,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: anime.status == AnimeStatus.planned
                          ? tokens.textPrimary
                          : anime.status == AnimeStatus.watching
                              ? tokens.info
                              : anime.status == AnimeStatus.completed
                                  ? tokens.success
                                  : Theme.of(context).colorScheme.primary,
                    ),
                  )),
                  Icon(AppIcons.dropdown, color: tokens.textMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MoreMenu extends ConsumerWidget {
  final Anime anime;
  final Color accentColor;
  const _MoreMenu({required this.anime, required this.accentColor});

  PopupMenuItem<String> _menuItem(
    AppThemeExtension tokens,
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: tokens.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: TextStyle(color: tokens.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: tokens.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: context.l10n.detailsMoreOptions,
        offset: const Offset(0, 50),
        itemBuilder: (context) => [
          _menuItem(
              tokens, 'stats', AppIcons.stats, context.l10n.detailsStatistics),
          _menuItem(
            tokens,
            'mark_all',
            AppIcons.doneAll,
            context.l10n.detailsMarkAllWatched,
          ),
          _menuItem(
            tokens,
            'folder',
            AppIcons.folderOpen,
            context.l10n.detailsOpenFolderInManager,
          ),
          const PopupMenuDivider(),
          _menuItem(
              tokens, 'edit', AppIcons.edit, context.l10n.detailsEditPoster),
        ],
        onSelected: (value) async {
          if (value == 'folder') {
            AnimeDialogs.openFolderInOs(anime.folderPath);
          }
          if (value == 'edit') {
            AnimeDialogs.showEditDialog(context, ref, anime, accentColor);
          }
          if (value == 'stats') {
            AnimeDialogs.showAnimeStatsDialog(context, anime, accentColor);
          }
          if (value == 'mark_all') {
            await ref.read(animeRepoProvider).markAllEpisodesWatched(anime.id);
          }
        },
        child: _HoverButton(
            icon: AppIcons.more,
            tooltip: context.l10n.detailsOptions,
            accentColor: accentColor),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color accentColor;
  final VoidCallback? onTap;

  const _HoverButton(
      {required this.icon,
      required this.tooltip,
      required this.accentColor,
      this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            height: AppSpacing.s48,
            decoration: BoxDecoration(
              color: isHovered ? widget.accentColor : tokens.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: isHovered ? widget.accentColor : tokens.borderSubtle,
              ),
            ),
            child: Icon(
              widget.icon,
              color: isHovered ? tokens.textPrimary : tokens.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
