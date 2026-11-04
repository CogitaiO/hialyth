import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekaido_pre/providers/repositories_provider.dart';
import 'dart:io';
import '../../../../providers/player/player_provider.dart';
import '../../../../providers/library_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';

class PlayerSidebar extends ConsumerWidget {
  final FocusNode playerFocusNode;
  const PlayerSidebar({super.key, required this.playerFocusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final isOpen = ref.watch(playerProvider.select((s) => s.isSidebarOpen));

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      right: isOpen ? 0 : -350,
      width: 350,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: tokens.titleBarSurface.withValues(alpha: 0.95),
            border: Border(left: BorderSide(color: tokens.surfaceHover)),
            boxShadow: [
              BoxShadow(
                color: tokens.scrim(0.5),
                blurRadius: AppSpacing.s20,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
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
                        "Menu",
                        style: TextStyle(
                          color: tokens.textMuted,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(AppIcons.close, color: tokens.textMuted),
                        onPressed: () => {
                          FocusManager.instance.primaryFocus?.unfocus(),
                          ref.read(playerProvider.notifier).toggleSideBar(),
                          playerFocusNode.requestFocus(),
                        },
                      ),
                    ],
                  ),
                ),
                TabBar(
                  unselectedLabelColor: tokens.textMuted,
                  dividerColor: tokens.borderSubtle,
                  tabs: const [
                    Tab(
                        icon: Icon(AppIcons.videoLibrary),
                        text: "Episodes"),
                    Tab(icon: Icon(AppIcons.notes), text: "Notes"),
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
          "Playlist is empty",
          style: TextStyle(color: tokens.textMuted),
        ),
      );
    }

    final animeAsync = ref.watch(animeDetailsProvider(animeId));

    return animeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
              child: Text(
                "Loading error",
                style: TextStyle(color: tokens.textMuted),
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
                    ? Color(ref.watch(settingsProvider).accentColorValue)
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                leading: Icon(
                  isCurrent
                      ? AppIcons.playCircle
                      : (isWatched
                          ? AppIcons.checkCircleOutline
                          : AppIcons.circleOutline),
                  color: isCurrent
                      ? Color(ref.watch(settingsProvider).accentColorValue)
                      : (isWatched ? tokens.success : tokens.textSubtle),
                ),
                title: Text(
                  "Episode ${index + 1}",
                  style: TextStyle(
                      color: isCurrent
                          ? Color(ref.watch(settingsProvider).accentColorValue)
                          : tokens.textPrimary,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal),
                ),
                subtitle: Text(
                  fileName,
                  style: TextStyle(color: tokens.textSubtle, fontSize: 11),
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
          "Turn on video for notes",
          style: TextStyle(color: tokens.textMuted),
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
                    hintText: "Add a note to the current frame...",
                    hintStyle: TextStyle(color: tokens.textSubtle),
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
                        Color(ref.watch(settingsProvider).accentColorValue)
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
                    child: Text("Error: $e",
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
                            "There are no notes for this series",
                            style: TextStyle(color: tokens.textMuted),
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
                                color: Color(ref
                                        .watch(settingsProvider)
                                        .accentColorValue)
                                    .withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.sm),
                                border: Border.all(
                                    color: Color(ref
                                            .watch(settingsProvider)
                                            .accentColorValue)
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
                            color: tokens.textSubtle,
                            size: 20,
                          ),
                          onPressed: () {
                            if (note.createdAt != null) {
                              ref
                                  .read(animeRepoProvider)
                                  .deleteNote(animeId, note.createdAt!);
                            }
                          },
                          hoverColor: Color(
                                  ref.watch(settingsProvider).accentColorValue)
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
