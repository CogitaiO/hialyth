import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekaido_pre/providers/repositories_provider.dart';
import 'dart:io';
import '../../../../providers/player/player_provider.dart';
import '../../../../providers/library_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';
import '../../../../widgets/glass_surface.dart';

class PlayerSidebar extends ConsumerWidget {
  final FocusNode playerFocusNode;
  const PlayerSidebar({super.key, required this.playerFocusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final isOpen = ref.watch(playerProvider.select((s) => s.isSidebarOpen));
    final reduceTransparency =
        ref.watch(settingsProvider.select((s) => s.reduceTransparency));

    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: 360,
      child: IgnorePointer(
        ignoring: !isOpen,
        child: AnimatedSlide(
          offset: isOpen ? Offset.zero : const Offset(1, 0),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: GlassSurface(
              reduceTransparency: reduceTransparency,
              borderRadius: BorderRadius.zero,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: tokens.surfaceHover)),
                ),
                child: ColoredBox(
                  color: Colors.transparent,
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.md,
                            left: AppSpacing.md,
                            bottom: AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.playerMenu,
                                style: TextStyle(
                                  color: tokens.textSecondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(AppIcons.close,
                                    color: tokens.textSecondary),
                                onPressed: () => {
                                  FocusManager.instance.primaryFocus?.unfocus(),
                                  ref
                                      .read(playerProvider.notifier)
                                      .toggleSideBar(),
                                  playerFocusNode.requestFocus(),
                                },
                              ),
                            ],
                          ),
                        ),
                        TabBar(
                          unselectedLabelColor: tokens.textSecondary,
                          dividerColor: tokens.borderSubtle,
                          tabs: [
                            Tab(
                                icon: Icon(AppIcons.videoLibrary),
                                text: context.l10n.playerEpisodes),
                            Tab(
                                icon: Icon(AppIcons.notes),
                                text: context.l10n.playerNotes),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildEpisodeList(context, ref),
                              const _EpisodeNoteTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeList(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final animeId = ref.watch(playerProvider.select((s) => s.animeId));
    final playlist = ref.watch(playerProvider.select((s) => s.playlist));
    final currentVideo = ref.watch(playerProvider.select((s) => s.videoPath));

    if (animeId == null || playlist.isEmpty) {
      return Center(
        child: Text(
          context.l10n.playerPlaylistEmpty,
          style: TextStyle(color: tokens.textSecondary),
        ),
      );
    }

    final animeAsync = ref.watch(animeDetailsProvider(animeId));

    return animeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
              child: Text(
                context.l10n.playerLoadingError,
                style: TextStyle(color: tokens.textSecondary),
              ),
            ),
        data: (anime) {
          if (anime == null) return const SizedBox.shrink();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final path = playlist[index];
              final isCurrent = path == currentVideo;
              final isWatched = anime.watchedEpisodes.contains(path);
              final fileName = path.split(Platform.pathSeparator).last;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xxs,
                ),
                tileColor: isCurrent
                    ? Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                leading: Icon(
                  isCurrent
                      ? AppIcons.playCircle
                      : (isWatched
                          ? AppIcons.checkCircleOutline
                          : AppIcons.circleOutline),
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : (isWatched ? tokens.success : tokens.textSecondary),
                ),
                title: Text(
                  context.l10n.playerEpisodeNumber(index + 1),
                  style: TextStyle(
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : tokens.textPrimary,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal),
                ),
                subtitle: Text(
                  fileName,
                  style: TextStyle(color: tokens.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  final notifier = ref.read(playerProvider.notifier);
                  notifier.toggleSideBar();

                  if (!isCurrent) {
                    notifier.loadVideo(animeId, path);
                  }
                },
              );
            },
          );
        });
  }
}

class _EpisodeNoteTab extends ConsumerStatefulWidget {
  const _EpisodeNoteTab();

  @override
  ConsumerState<_EpisodeNoteTab> createState() => _EpisodeNoteTabState();
}

class _EpisodeNoteTabState extends ConsumerState<_EpisodeNoteTab> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        final player = ref.read(playerProvider);
        if (player.isPlaying) {
          ref.read(playerProvider.notifier).togglePlay();
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _saveNote(int animeId, String episodePath) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final currentPositionSeconds = ref.read(playerProvider).position.inSeconds;

    ref
        .read(animeRepoProvider)
        .addNote(animeId, episodePath, currentPositionSeconds, text);

    _textController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final animeId = ref.watch(playerProvider.select((s) => s.animeId));
    final currentPath = ref.watch(playerProvider.select((s) => s.videoPath));

    if (animeId == null || currentPath == null) {
      return Center(
        child: Text(
          context.l10n.playerVideoRequiredForNotes,
          style: TextStyle(color: tokens.textSecondary),
        ),
      );
    }

    final animeAsync = ref.watch(animeDetailsProvider(animeId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: TextStyle(color: tokens.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: context.l10n.playerAddNoteHint,
                    hintStyle: TextStyle(color: tokens.textSecondary),
                    filled: true,
                    fillColor: tokens.surfaceSubtle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onSubmitted: (_) => _saveNote(animeId, currentPath),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.2)),
                icon: Icon(AppIcons.add,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () => _saveNote(animeId, currentPath),
              ),
            ],
          ),
        ),
        Divider(color: tokens.borderSubtle, height: 1),
        Expanded(
            child: animeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text(context.l10n.playerErrorDetail(e.toString()),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
                data: (anime) {
                  if (anime == null) return const SizedBox.shrink();
                  final episodeNotes = anime.notes
                      .where((n) => n.episodePath == currentPath)
                      .toList()
                    ..sort((a, b) => (a.timestampSeconds ?? 0)
                        .compareTo(b.timestampSeconds ?? 0));
                  if (episodeNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.editNote,
                            size: 48,
                            color: tokens.surfaceHover,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            context.l10n.playerNoNotes,
                            style: TextStyle(color: tokens.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    itemCount: episodeNotes.length,
                    itemBuilder: (context, index) {
                      final note = episodeNotes[index];
                      final timestamp = note.timestampSeconds ?? 0;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xxs,
                        ),
                        leading: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(playerProvider.notifier)
                                  .seek(Duration(seconds: timestamp));
                              ref.read(playerProvider.notifier).showUi();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary
                                    .withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.sm),
                                border: Border.all(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                _formatTime(timestamp),
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          note.text ?? '',
                          style: TextStyle(
                              color: tokens.textPrimary, fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            AppIcons.delete,
                            color: tokens.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            if (note.createdAt != null) {
                              ref
                                  .read(animeRepoProvider)
                                  .deleteNote(animeId, note.createdAt!);
                            }
                          },
                          hoverColor: Theme.of(context).colorScheme.primary
                              .withValues(alpha: 0.2),
                        ),
                      );
                    },
                  );
                })),
      ],
    );
  }
}
