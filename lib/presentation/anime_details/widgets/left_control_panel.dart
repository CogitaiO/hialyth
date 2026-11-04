import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../domain/anime.dart';
import '../../../../providers/repositories_provider.dart';
import '../../player/player_screen.dart';
import '../dialogs/anime_dialogs.dart';
import '../../../../providers/settings_provider.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';

class LeftControlPanel extends ConsumerWidget {
  final Anime anime;
  final Color accentColor;
  final String heroTag;

  const LeftControlPanel({
    super.key,
    required this.anime,
    required this.accentColor,
    required this.heroTag,
  });

  void _playEpisode(BuildContext context, String path) {
    if (!File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Ошибка:  Файл видео не найден!"),
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
    //Данные для постера
    ImageProvider? imageProvider;
    if (anime.coverUrl != null) {
      imageProvider = anime.coverUrl!.startsWith('http')
          ? CachedNetworkImageProvider(anime.coverUrl!) as ImageProvider
          : FileImage(File(anime.coverUrl!));
    }

    //Логика умной кнопки
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
        Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  color: tokens.surfaceOverlay,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  image: imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null,
                  border: Border.all(color: tokens.surfaceHover),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: imageProvider == null
                    ? Center(
                        child: Icon(
                          AppIcons.imageMissing,
                          size: 60,
                          color: tokens.textDisabled,
                        ),
                      )
                    : null,
              ),
            )),
        const SizedBox(height: AppSpacing.lg),
        if (sortedEpisodes.isNotEmpty)
          ElevatedButton(
            onPressed: () => _playEpisode(context, nextEpisodePath),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              backgroundColor:
                  isAllWatched ? tokens.surfaceDisabled : accentColor,
              foregroundColor: tokens.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              elevation: 10,
              shadowColor: accentColor.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isAllWatched ? AppIcons.replay : AppIcons.play, size: 26),
                Transform.translate(
                  offset: const Offset(0, -1.5),
                  child: Text(
                    isAllWatched ? "Пересмотреть" : "Эпизод $nextEpisodeIndex",
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
                  tooltip: "Подборка",
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
              "В планах",
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
            child: Text("Смотрю", style: TextStyle(color: tokens.info)),
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
              "Просмотрено",
              style: TextStyle(color: tokens.success),
            ),
          ),
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
                  Text(
                    anime.status == AnimeStatus.planned
                        ? "В планах"
                        : anime.status == AnimeStatus.watching
                            ? "Смотрю"
                            : anime.status == AnimeStatus.completed
                                ? "Просмотрено"
                                : "Брошено",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: anime.status == AnimeStatus.planned
                          ? tokens.textPrimary
                          : anime.status == AnimeStatus.watching
                              ? tokens.info
                              : anime.status == AnimeStatus.completed
                                  ? tokens.success
                                  : Color(
                                      ref
                                          .watch(settingsProvider)
                                          .accentColorValue,
                                    ),
                    ),
                  ),
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
        tooltip: "Больше опций",
        offset: const Offset(0, 50),
        itemBuilder: (context) => [
          _menuItem(tokens, 'stats', AppIcons.stats, "Статистика"),
          _menuItem(
            tokens,
            'mark_all',
            AppIcons.doneAll,
            "Отметить всё просмотренным",
          ),
          _menuItem(
            tokens,
            'folder',
            AppIcons.folderOpen,
            "Открыть папку на ПК",
          ),
          const PopupMenuDivider(),
          _menuItem(tokens, 'edit', AppIcons.edit, "Редактировать постер"),
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
            icon: AppIcons.more, tooltip: "Опции", accentColor: accentColor),
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
            duration: const Duration(milliseconds: 200),
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
