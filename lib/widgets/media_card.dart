import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nekaido_pre/data/services/shikimori_service.dart';
import 'dart:io';

import '../domain/anime.dart';
import '../presentation/anime_details/anime_details_screen.dart';
import '../../providers/repositories_provider.dart';
import '../presentation/anime_details/dialogs/anime_dialogs.dart';
import '../theme/app_icons.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme_extension.dart';
import '../core/localization/l10n.dart';
import '../presentation/player/player_screen.dart';

class AnimeCard extends ConsumerStatefulWidget {
  final Anime anime;
  const AnimeCard({super.key, required this.anime});

  @override
  ConsumerState<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends ConsumerState<AnimeCard> {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  void _openDetails() {
    Navigator.push(
      context,
      AppMotion.pageRoute(
        context,
        builder: (_) => AnimeDetailsScreen(
          animeId: widget.anime.id,
          heroTag: 'poster_${widget.anime.id}_library',
        ),
      ),
    );
  }

  void _play() {
    final path =
        widget.anime.nextEpisodeToPlay ??
        widget.anime.sortedEpisodes.firstOrNull;
    if (path != null) {
      Navigator.push(
        context,
        AppMotion.pageRoute(
          context,
          builder: (_) =>
              PlayerScreen(animeId: widget.anime.id, videoPath: path),
        ),
      );
    }
  }

  void _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset tapPosition,
  ) {
    final tokens = context.appTheme;
    PopupMenuItem<String> action(
      String value,
      String label,
      IconData icon, {
      bool destructive = false,
    }) {
      final color = destructive ? tokens.destructive : tokens.textPrimary;
      return PopupMenuItem(
        value: value,
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label, style: TextStyle(color: color)),
            ),
          ],
        ),
      );
    }

    showMenu<String>(
      context: context,
      popUpAnimationStyle: AnimationStyle(
        duration: AppMotion.resolveDuration(context, AppMotion.medium),
        curve: AppMotion.enter,
        reverseCurve: AppMotion.exit,
      ),
      color: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: tokens.borderSubtle),
      ),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0),
        Offset.zero &
            (Overlay.of(context).context.findRenderObject()! as RenderBox).size,
      ),
      items: [
        action(
          'sync_api',
          context.l10n.detailsUpdateFromNetwork,
          AppIcons.rescan,
        ),
        action('edit', context.l10n.dialogEdit, AppIcons.edit),
        action(
          'collection',
          context.l10n.toastAddedToCollection,
          AppIcons.collections,
        ),
        const PopupMenuDivider(),
        action(
          'delete',
          context.l10n.detailsRemoveFromLibrary,
          AppIcons.delete,
          destructive: true,
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'delete') {
        _confirmDelete(context, ref);
      } else if (value == 'edit') {
        _showEditDialog(context, ref);
      } else if (value == 'collection') {
        AnimeDialogs.showCollectionDialog(
          context,
          ref,
          widget.anime,
          Theme.of(context).colorScheme.primary,
        );
      } else if (value == 'sync_api') {
        _syncWithApi(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      color: tokens.textPrimary,
      height: 1.25,
    );
    final titleHeight =
        MediaQuery.textScalerOf(context).scale(titleStyle.fontSize!) *
        titleStyle.height! *
        2;
    final active = _isHovered || _isFocused;
    final watched = widget.anime.episodePaths
        .toSet()
        .intersection(widget.anime.watchedEpisodes.toSet())
        .length;
    final cover = widget.anime.coverUrl;
    final (statusLabel, statusColor) = switch (widget.anime.status) {
      AnimeStatus.planned => (context.l10n.statusPlanned, tokens.statusPlanned),
      AnimeStatus.watching => (
        context.l10n.statusWatching,
        tokens.statusWatching,
      ),
      AnimeStatus.completed => (
        context.l10n.statusCompleted,
        tokens.statusCompleted,
      ),
      AnimeStatus.dropped => (context.l10n.statusDropped, tokens.statusDropped),
    };
    final placeholder = Center(
      child: Icon(AppIcons.image, color: tokens.textMuted, size: 40),
    );
    return FocusableActionDetector(
      onShowFocusHighlight: (value) => setState(() => _isFocused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _openDetails();
            return null;
          },
        ),
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _openDetails,
          onSecondaryTapDown: (details) =>
              _showContextMenu(context, ref, details.globalPosition),
          onLongPressStart: (details) =>
              _showContextMenu(context, ref, details.globalPosition),
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : (active ? 1.015 : 1),
            duration: AppMotion.resolveDuration(context, AppMotion.normal),
            curve: AppMotion.enter,
            child: AnimatedContainer(
              duration: AppMotion.resolveDuration(context, AppMotion.normal),
              curve: AppMotion.enter,
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
               color: active ? tokens.cardSurface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: _isFocused
                    ? scheme.primary
                     : (active ? tokens.borderSubtle : Colors.transparent),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'poster_${widget.anime.id}_library',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  tokens.containerHigh,
                                  tokens.pageSurface,
                                ],
                              ),
                            ),
                          ),
                          if (cover == null || cover.isEmpty)
                            placeholder
                          else if (cover.startsWith('http'))
                            CachedNetworkImage(
                              imageUrl: cover,
                              fit: BoxFit.cover,
                              memCacheWidth: 440,
                              placeholder: (_, _) => placeholder,
                              errorWidget: (_, _, _) => placeholder,
                            )
                          else if (cover.startsWith('asset:'))
                            Image.asset(
                              cover.substring('asset:'.length),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => placeholder,
                            )
                          else
                            Image.file(
                              File(cover),
                              fit: BoxFit.cover,
                              cacheWidth: 440,
                              errorBuilder: (_, _, _) => placeholder,
                            ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 72,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    tokens.scrim(0.75),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !active,
                              child: ExcludeSemantics(
                                excluding: !active,
                                child: AnimatedOpacity(
                                  opacity: active ? 1 : 0,
                                  duration:
                                      AppMotion.resolveDuration(
                                        context,
                                        AppMotion.medium,
                                      ),
                                  curve: AppMotion.enter,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ColoredBox(color: tokens.scrim(0.28)),
                                      if (widget.anime.episodePaths.isNotEmpty)
                                        Center(
                                          child: IconButton.filled(
                                            tooltip: context.l10n.detailsContinue(
                                              widget.anime.sortedEpisodes.indexOf(
                                                    widget
                                                            .anime
                                                            .nextEpisodeToPlay ??
                                                        widget
                                                            .anime
                                                            .sortedEpisodes
                                                            .first,
                                                  ) +
                                                  1,
                                            ),
                                            iconSize: 30,
                                            padding: const EdgeInsets.all(16),
                                            onPressed: _play,
                                            icon: const Icon(AppIcons.play),
                                          ),
                                        ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Builder(
                                          builder: (buttonContext) => IconButton(
                                            tooltip:
                                                context.l10n.detailsMoreOptions,
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  tokens.surfaceOverlay,
                                              foregroundColor:
                                                  tokens.textPrimary,
                                            ),
                                            icon: const Icon(AppIcons.more),
                                            onPressed: () {
                                              final box =
                                                  buttonContext
                                                          .findRenderObject()!
                                                      as RenderBox;
                                              _showContextMenu(
                                                context,
                                                ref,
                                                box.localToGlobal(Offset.zero),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: AppSpacing.xs,
                            left: AppSpacing.xs,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: tokens.surfaceOverlay,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.pill,
                                ),
                                border: Border.all(color: tokens.borderFaint),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 3,
                                ),
                                child: Text(
                                  statusLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(color: statusColor),
                                ),
                              ),
                            ),
                          ),
                          if (widget.anime.watchProgress > 0)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(
                                value: widget.anime.watchProgress.clamp(0, 1),
                                minHeight: 3,
                                color: scheme.primary,
                                backgroundColor: tokens.surfaceOverlay,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                 SizedBox(
                   height: titleHeight,
                   child: Text(
                     widget.anime.title,
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                     style: titleStyle,
                   ),
                 ),
                 const SizedBox(height: AppSpacing.xxs),
                 Semantics(
                   label: context.l10n.detailsWatched(
                     widget.anime.episodePaths.length,
                     watched,
                   ),
                   excludeSemantics: true,
                   child: Row(
                     children: [
                       Icon(
                         AppIcons.checkCircle,
                         size: 14,
                         color: tokens.textMuted,
                       ),
                       const SizedBox(width: AppSpacing.xxs),
                       Flexible(
                         child: Text(
                           widget.anime.progressFraction,
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                           style: theme.textTheme.bodySmall,
                         ),
                       ),
                     ],
                   ),
                 ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appTheme.containerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(
          context.l10n.detailsRemoveConfirmTitle(widget.anime.title),
          style: TextStyle(color: context.appTheme.textPrimary),
        ),
        content: Text(
          context.l10n.detailsRemoveConfirmBody,
          style: TextStyle(color: context.appTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.dialogCancel,
              style: TextStyle(color: context.appTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appTheme.destructive,
            ),
            onPressed: () {
              ref.read(animeRepoProvider).deleteAnime(widget.anime.id);
              Navigator.pop(ctx);
            },
            child: Text(
              context.l10n.dialogDelete,
              style: TextStyle(color: context.appTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: widget.anime.title);
    final coverController = TextEditingController(
      text: widget.anime.coverUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(
          context.l10n.dialogEdit,
          style: TextStyle(color: context.appTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: context.appTheme.textPrimary),
              decoration: InputDecoration(
                labelText: context.l10n.detailsTitleField,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: coverController,
              style: TextStyle(color: context.appTheme.textPrimary),
              decoration: InputDecoration(
                labelText: context.l10n.detailsPosterUrl,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    AppIcons.folderOpen,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: context.l10n.detailsChooseImage,
                  onPressed: () async {
                    final result = await FilePicker.pickFile(
                      type: FileType.image,
                    );
                    if (result?.path != null) {
                      coverController.text = result!.path!;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.dialogCancel,
              style: TextStyle(color: context.appTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              try {
                await ref
                    .read(animeRepoProvider)
                    .editAnimeDetails(
                      widget.anime,
                      titleController.text,
                      coverController.text.isNotEmpty
                          ? coverController.text
                          : '',
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(ctx.l10n.commonSaveFailed)),
                  );
                }
              }
            },
            child: Text(
              context.l10n.dialogSave,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncWithApi(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.detailsSyncingMetadata(widget.anime.title)),
      ),
    );
    final shikimori = ShikimoriService();
    final meta = await shikimori.fetchAnimeDetails(widget.anime.title);

    if (meta != null) {
      await ref
          .read(animeRepoProvider)
          .updateMetadata(
            widget.anime.id,
            coverUrl: meta['coverUrl'],
            description: meta['description'],
            shikimoriId: int.tryParse(meta['shikimoriId'] ?? ''),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.detailsMetadataUpdated),
            backgroundColor: context.appTheme.success,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.detailsShikimoriNoData),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
