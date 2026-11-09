import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/anime.dart';
import '../../../../providers/repositories_provider.dart';
import '../../../../utils/os_utils.dart';
import '../../player/player_screen.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';

class RightInfoPanel extends StatefulWidget {
  const RightInfoPanel(
      {super.key,
      required this.anime,
      required this.accentColor,
      this.header,
      this.showTitle = true});
  final Anime anime;
  final Color accentColor;
  final Widget? header;
  final bool showTitle;
  @override
  State<RightInfoPanel> createState() => _RightInfoPanelState();
}

class _RightInfoPanelState extends State<RightInfoPanel> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final paths = anime.sortedEpisodes;
    return CustomScrollView(slivers: [
      if (widget.header != null) SliverToBoxAdapter(child: widget.header),
      SliverToBoxAdapter(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.showTitle) ...[
          Text(anime.title,
              style: Theme.of(context).textTheme.displayLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
        ],
        Wrap(spacing: 8, runSpacing: 8, children: [
          Chip(
              avatar: const Icon(AppIcons.videoLibrary, size: 16),
              label: Text(context.l10n.detailsEpisodes(paths.length))),
          Chip(
              avatar: const Icon(AppIcons.checkCircle, size: 16),
              label: Text(anime.progressPercentage)),
          if (anime.folderPath != null)
            ActionChip(
                avatar: const Icon(AppIcons.folder, size: 16),
                label: Text(context.l10n.detailsOpenFolder),
                onPressed: () => OSUtils.openFolder(anime.folderPath)),
        ]),
        const SizedBox(height: 24),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: context.appTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appTheme.borderSubtle)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.l10n.detailsDescription,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(anime.descripion ?? context.l10n.detailsNoDescription,
                  maxLines: expanded ? null : 4,
                  overflow:
                      expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge),
              if (anime.descripion != null)
                TextButton(
                    onPressed: () => setState(() => expanded = !expanded),
                    child: Text(expanded
                        ? context.l10n.detailsReadLess
                        : context.l10n.detailsReadMore)),
            ])),
        const SizedBox(height: 24),
        Text(context.l10n.detailsEpisodesLabel,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (paths.isEmpty)
          Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.detailsNoEpisodes)),
      ])),
      SliverList.builder(
          itemCount: paths.length,
          itemBuilder: (context, index) => EpisodeRow(
              key: ValueKey(paths[index]),
              anime: anime,
              path: paths[index],
              number: index + 1)),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]);
  }
}

class EpisodeRow extends ConsumerStatefulWidget {
  const EpisodeRow(
      {super.key,
      required this.anime,
      required this.path,
      required this.number});
  final Anime anime;
  final String path;
  final int number;
  @override
  ConsumerState<EpisodeRow> createState() => _EpisodeRowState();
}

class _EpisodeRowState extends ConsumerState<EpisodeRow> {
  late Future<bool> exists;
  @override
  void initState() {
    super.initState();
    exists = File(widget.path).exists();
  }

  @override
  void didUpdateWidget(EpisodeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) exists = File(widget.path).exists();
  }

  Future<void> play() async {
    if (!await File(widget.path).exists()) {
      if (mounted) setState(() => exists = Future.value(false));
      return;
    }
    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PlayerScreen(
                animeId: widget.anime.id, videoPath: widget.path)));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
      future: exists,
      builder: (context, snapshot) {
        final missing = snapshot.hasData && !snapshot.data!;
        final watched = widget.anime.watchedEpisodes.contains(widget.path);
        final saved = widget.anime.playbackPositions
                .where((p) => p.path == widget.path)
                .firstOrNull
                ?.position ??
            0;
        final time =
            '${saved ~/ 60}:${(saved % 60).toString().padLeft(2, '0')}';
        return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: context.appTheme.cardSurface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Icon(
                    missing
                        ? AppIcons.imageBroken
                        : watched
                            ? AppIcons.checkCircle
                            : AppIcons.playCircleOutline,
                    color: missing
                        ? context.appTheme.warning
                        : watched
                            ? context.appTheme.success
                            : Theme.of(context).colorScheme.primary),
                title: Text(context.l10n.detailsEpisodeNumber(widget.number)),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(File(widget.path).uri.pathSegments.last,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (missing)
                        Text(context.l10n.detailsMissingFile,
                            style: TextStyle(color: context.appTheme.warning)),
                      if (saved > 0 && !missing)
                        Text(context.l10n.detailsSavedPosition(time)),
                    ]),
                onTap: missing ? null : play,
                trailing: PopupMenuButton<String>(
              icon: const Icon(AppIcons.more),
                  tooltip: context.l10n.detailsMoreOptions,
                  onSelected: (value) {
                    final repo = ref.read(animeRepoProvider);
                    if (value == 'folder') {
                      OSUtils.openFolder(File(widget.path).parent.path);
                    } else if (watched) {
                      repo.markEpisodeUnwatched(widget.anime.id, widget.path);
                    } else {
                      repo.markEpisodeAsWatched(widget.anime.id, widget.path);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'watched',
                        child: Text(watched
                            ? context.l10n.detailsMarkUnwatched
                            : context.l10n.detailsMarkWatched)),
                    PopupMenuItem(
                        value: 'folder',
                        child: Text(context.l10n.detailsOpenFileLocation)),
                  ],
                ),
              ),
            ));
      });
}
