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

  void _openDetails() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AnimeDetailsScreen(
                  animeId: widget.anime.id,
                  heroTag: 'poster_${widget.anime.id}_library',
                )));
  }

  void _play() {
    final path = widget.anime.nextEpisodeToPlay ??
        widget.anime.sortedEpisodes.firstOrNull;
    if (path != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PlayerScreen(
                    animeId: widget.anime.id,
                    videoPath: path,
                  )));
    }
  }

  void _showContextMenu(
      BuildContext context, WidgetRef ref, Offset tapPosition) {
    final tokens = context.appTheme;
    showMenu<String>(
      context: context,
      color: tokens.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx,
        tapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'sync_api',
          child: Text(
            context.l10n.detailsUpdateFromNetwork,
            style: TextStyle(color: tokens.textPrimary),
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Text(context.l10n.dialogEdit,
              style: TextStyle(color: tokens.textPrimary)),
        ),
        PopupMenuItem(
          value: 'collection',
          child: Text(
            context.l10n.toastAddedToCollection,
            style: TextStyle(color: tokens.textPrimary),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            context.l10n.detailsRemoveFromLibrary,
            style: TextStyle(color: tokens.destructive),
          ),
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
          context.appTheme.destructive,
        );
      } else if (value == 'sync_api') {
        _syncWithApi(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    final active = _isHovered || _isFocused;
    final cover = widget.anime.coverUrl;
    final placeholder =
        Center(child: Icon(AppIcons.image, color: tokens.textMuted, size: 40));
    return FocusableActionDetector(
      onShowFocusHighlight: (value) => setState(() => _isFocused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
          _openDetails();
          return null;
        })
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _openDetails,
          onSecondaryTapDown: (details) =>
              _showContextMenu(context, ref, details.globalPosition),
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? tokens.containerHigh : tokens.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _isFocused
                      ? scheme.primary
                      : (active ? tokens.borderStrong : tokens.borderSubtle),
                  width: _isFocused ? 2 : 1),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Hero(
                tag: 'poster_${widget.anime.id}_library',
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(fit: StackFit.expand, children: [
                      DecoratedBox(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [tokens.containerHigh, tokens.pageSurface],
                      ))),
                      if (cover == null || cover.isEmpty)
                        placeholder
                      else if (cover.startsWith('http'))
                        CachedNetworkImage(
                          imageUrl: cover,
                          fit: BoxFit.cover,
                          memCacheWidth: 440,
                          placeholder: (_, __) => placeholder,
                          errorWidget: (_, __, ___) => placeholder,
                        )
                      else
                        Image.file(File(cover),
                            fit: BoxFit.cover,
                            cacheWidth: 440,
                            errorBuilder: (_, __, ___) => placeholder),
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
                            colors: [tokens.scrim(0.75), Colors.transparent],
                          )))),
                      if (active) ...[
                        ColoredBox(color: tokens.scrim(0.28)),
                        if (widget.anime.episodePaths.isNotEmpty)
                          Center(
                              child: IconButton.filled(
                            tooltip: context.l10n.detailsContinue(widget
                                    .anime.sortedEpisodes
                                    .indexOf(widget.anime.nextEpisodeToPlay ??
                                        widget.anime.sortedEpisodes.first) +
                                1),
                            iconSize: 30,
                            padding: const EdgeInsets.all(16),
                            onPressed: _play,
                            icon: const Icon(AppIcons.play),
                          )),
                        Positioned(
                            top: 4,
                            right: 4,
                            child: Builder(
                                builder: (buttonContext) => IconButton(
                                      tooltip: context.l10n.detailsMoreOptions,
                                      style: IconButton.styleFrom(
                                          backgroundColor:
                                              tokens.surfaceOverlay,
                                          foregroundColor: tokens.textPrimary),
                                      icon: const Icon(AppIcons.more),
                                      onPressed: () {
                                        final box = buttonContext
                                            .findRenderObject()! as RenderBox;
                                        _showContextMenu(context, ref,
                                            box.localToGlobal(Offset.zero));
                                      },
                                    ))),
                      ],
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
                            )),
                    ])),
              )),
              const SizedBox(height: 12),
              Text(widget.anime.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: tokens.textPrimary)),
              const SizedBox(height: 8),
              Text(
                  context.l10n.detailsWatched(widget.anime.episodePaths.length,
                      widget.anime.watchedEpisodes.length),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: context.appTheme.cardSurface,
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
            ));
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: widget.anime.title);
    final coverController =
        TextEditingController(text: widget.anime.coverUrl ?? '');

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
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: coverController,
              style: TextStyle(color: context.appTheme.textPrimary),
              decoration: InputDecoration(
                labelText: context.l10n.detailsPosterUrl,
                labelStyle: TextStyle(color: context.appTheme.destructive),
                suffixIcon: IconButton(
                  icon: Icon(AppIcons.folderOpen,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: context.l10n.detailsChooseImage,
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.pickFiles(type: FileType.image);
                    if (result != null && result.files.single.path != null) {
                      coverController.text = result.files.single.path!;
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
              backgroundColor: context.appTheme.destructive,
            ),
            onPressed: () async {
              try {
                await ref.read(animeRepoProvider).editAnimeDetails(
                    widget.anime,
                    titleController.text,
                    coverController.text.isNotEmpty
                        ? coverController.text
                        : '');
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(ctx.l10n.commonSaveFailed)));
                }
              }
            },
            child: Text(
              context.l10n.dialogSave,
              style: TextStyle(color: context.appTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncWithApi(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(context.l10n.detailsSyncingMetadata(widget.anime.title))),
    );
    final shikimori = ShikimoriService();
    final meta = await shikimori.fetchAnimeDetails(widget.anime.title);

    if (meta != null) {
      await ref.read(animeRepoProvider).updateMetadata(
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
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }
}
