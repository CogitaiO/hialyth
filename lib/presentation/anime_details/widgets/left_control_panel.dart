import 'package:flutter/material.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/app_surfaces.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/anime.dart';
import '../../../../widgets/anime_artwork.dart';
import '../../../../providers/repositories_provider.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ink = AppSurfaces.accentInk(accentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPoster)
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Hero(
              tag: heroTag,
              child: AnimeArtwork(
                cover: anime.coverUrl,
                title: anime.title,
                radius: 16,
                cacheWidth: 560,
              ),
            ),
          ),
        if (showPoster) const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 240) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusMenu(anime: anime, accentColor: accentColor),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _HoverButton(
                          icon: AppIcons.collectionAdd,
                          tooltip: context.l10n.detailsCollection,
                          accentColor: accentColor,
                          onTap: () => AnimeDialogs.showCollectionDialog(
                            context,
                            ref,
                            anime,
                            ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _MoreMenu(
                          anime: anime,
                          accentColor: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _StatusMenu(anime: anime, accentColor: accentColor),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  flex: 1,
                  child: _HoverButton(
                    icon: AppIcons.collectionAdd,
                    tooltip: context.l10n.detailsCollection,
                    accentColor: accentColor,
                    onTap: () => AnimeDialogs.showCollectionDialog(
                      context,
                      ref,
                      anime,
                      ink,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  flex: 1,
                  child: _MoreMenu(anime: anime, accentColor: accentColor),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatusMenu extends ConsumerWidget {
  final Anime anime;
  final Color accentColor;
  const _StatusMenu({required this.anime, required this.accentColor});

  String _label(BuildContext context, AnimeStatus status) => switch (status) {
    AnimeStatus.planned => context.l10n.statusPlanned,
    AnimeStatus.watching => context.l10n.statusWatching,
    AnimeStatus.completed => context.l10n.statusCompleted,
    AnimeStatus.dropped => context.l10n.statusDropped,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final ink = AppSurfaces.accentInk(accentColor);
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          AppSurfaces.artworkMenu(accentColor),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
      ),
      menuChildren: [
        for (final status in AnimeStatus.values)
          MenuItemButton(
            leadingIcon: status == anime.status
                ? Icon(AppIcons.checkCircle, color: ink, size: 18)
                : const SizedBox.square(dimension: 18),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.focused) ||
                        states.contains(WidgetState.pressed)
                    ? AppSurfaces.controlSurface(accentColor, AppSurfaces.quiet)
                    : Colors.transparent,
              ),
            ),
            onPressed: () =>
                ref.read(animeRepoProvider).updateStatus(anime.id, status),
            child: Text(
              _label(context, status),
              style: TextStyle(
                color: status == anime.status ? ink : tokens.textPrimary,
              ),
            ),
          ),
      ],
      builder: (context, controller, child) {
        return Material(
          color: AppSurfaces.artworkWash(
            accentColor,
            AppSurfaces.quiet,
            strength: .12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
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
                    child: AnimatedSwitcher(
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...previous, ?current],
                      ),
                      duration: AppMotion.resolveDuration(
                        context,
                        AppMotion.medium,
                      ),
                      switchInCurve: AppMotion.enter,
                      child: Text(
                        key: ValueKey(anime.status),
                        _label(context, anime.status),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: controller.isOpen ? .5 : 0,
                    duration: AppMotion.resolveDuration(
                      context,
                      AppMotion.medium,
                    ),
                    curve: AppMotion.enter,
                    child: Icon(AppIcons.dropdown, color: tokens.textMuted),
                  ),
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
    return PopupMenuButton<String>(
      color: AppSurfaces.artworkMenu(accentColor),
      tooltip: context.l10n.detailsMoreOptions,
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        _menuItem(
          tokens,
          'stats',
          AppIcons.stats,
          context.l10n.detailsStatistics,
        ),
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
          tokens,
          'edit',
          AppIcons.edit,
          context.l10n.detailsEditPoster,
        ),
      ],
      onSelected: (value) async {
        if (value == 'folder') {
          AnimeDialogs.openFolderInOs(anime.folderPath);
        }
        if (value == 'edit') {
          AnimeDialogs.showEditDialog(
            context,
            ref,
            anime,
            AppSurfaces.accentInk(accentColor),
          );
        }
        if (value == 'stats') {
          AnimeDialogs.showAnimeStatsDialog(
            context,
            anime,
            AppSurfaces.accentInk(accentColor),
          );
        }
        if (value == 'mark_all') {
          await ref.read(animeRepoProvider).markAllEpisodesWatched(anime.id);
        }
      },
      child: _HoverButton(
        icon: AppIcons.more,
        tooltip: context.l10n.detailsOptions,
        accentColor: accentColor,
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color accentColor;
  final VoidCallback? onTap;

  const _HoverButton({
    required this.icon,
    required this.tooltip,
    required this.accentColor,
    this.onTap,
  });

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
            duration: AppMotion.resolveDuration(
              context,
              const Duration(milliseconds: 200),
            ),
            height: AppSpacing.s48,
            decoration: BoxDecoration(
              color: isHovered
                  ? AppSurfaces.controlSurface(
                      widget.accentColor,
                      AppSurfaces.quiet,
                    )
                  : tokens.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: isHovered ? widget.accentColor : tokens.borderSubtle,
              ),
            ),
            child: Icon(
              widget.icon,
              color: AppSurfaces.accentInk(widget.accentColor),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
