import 'dart:io';
import '../../../../data/services/android_documents.dart';
import 'package:flutter/material.dart';
import '../../../widgets/animated_state_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/anime.dart';
import '../../../../providers/repositories_provider.dart';
import '../../../../utils/os_utils.dart';
import '../../player/player_screen.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_motion.dart';
import '../../../theme/app_surfaces.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';

class RightInfoPanel extends StatefulWidget {
  const RightInfoPanel({
    super.key,
    required this.anime,
    required this.accentColor,
    this.header,
    this.showTitle = true,
  });
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
    final tokens = context.appTheme;
    final text = Theme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        if (widget.header != null) SliverToBoxAdapter(child: widget.header),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTitle) ...[
                Text(
                  anime.title,
                  style: Theme.of(context).textTheme.displayLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _DetailFact(
                    icon: AppIcons.videoLibrary,
                    label: Text(context.l10n.detailsEpisodes(paths.length)),
                  ),
                  _DetailFact(
                    icon: AppIcons.checkCircle,
                    label: Text(anime.progressPercentage),
                  ),
                  if (anime.folderPath != null)
                    ActionChip(
                      avatar: const Icon(AppIcons.folder, size: 16),
                      label: Text(context.l10n.detailsOpenFolder),
                      onPressed: () => OSUtils.openFolder(anime.folderPath),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Divider(color: tokens.borderSubtle, height: AppSpacing.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.detailsDescription,
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      anime.descripion ?? context.l10n.detailsNoDescription,
                      maxLines: expanded ? null : 4,
                      overflow: expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        color: tokens.textSecondary,
                        height: 1.55,
                      ),
                    ),
                    if (anime.descripion != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 44),
                          foregroundColor: AppSurfaces.accentInk(
                            widget.accentColor,
                          ),
                        ),
                        onPressed: () => setState(() => expanded = !expanded),
                        child: Text(
                          expanded
                              ? context.l10n.detailsReadLess
                              : context.l10n.detailsReadMore,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.detailsEpisodesLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (paths.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(context.l10n.detailsNoEpisodes),
                ),
            ],
          ),
        ),
        SliverList.builder(
          itemCount: paths.length,
          itemBuilder: (context, index) => EpisodeRow(
            key: ValueKey(paths[index]),
            anime: anime,
            path: paths[index],
            number: index + 1,
            accentColor: widget.accentColor,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _DetailFact extends StatelessWidget {
  const _DetailFact({required this.icon, required this.label});

  final IconData icon;
  final Widget label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: context.appTheme.textMuted),
      const SizedBox(width: AppSpacing.xs),
      DefaultTextStyle(
        style: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(color: context.appTheme.textSecondary),
        child: label,
      ),
    ],
  );
}

class EpisodeRow extends ConsumerStatefulWidget {
  const EpisodeRow({
    super.key,
    required this.anime,
    required this.path,
    required this.number,
    required this.accentColor,
  });
  final Anime anime;
  final String path;
  final int number;
  final Color accentColor;
  @override
  ConsumerState<EpisodeRow> createState() => _EpisodeRowState();
}

class _EpisodeRowState extends ConsumerState<EpisodeRow> {
  late Future<bool> exists;
  @override
  void initState() {
    super.initState();
    exists = AndroidDocuments.exists(widget.path);
  }

  @override
  void didUpdateWidget(EpisodeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      exists = AndroidDocuments.exists(widget.path);
    }
  }

  Future<void> play() async {
    if (!await AndroidDocuments.exists(widget.path)) {
      if (mounted) setState(() => exists = Future.value(false));
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      AppMotion.pageRoute(
        context,
        builder: (_) =>
            PlayerScreen(animeId: widget.anime.id, videoPath: widget.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: exists,
    builder: (context, snapshot) {
      final missing = snapshot.hasData && !snapshot.data!;
      final watched = widget.anime.watchedEpisodes.contains(widget.path);
      final tokens = context.appTheme;
      final saved =
          widget.anime.playbackPositions
              .where((p) => p.path == widget.path)
              .firstOrNull
              ?.position ??
          0;
      final time = '${saved ~/ 60}:${(saved % 60).toString().padLeft(2, '0')}';
      final hasResume = saved > 0 && !missing && !watched;
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
        ),
        child: Material(
          color: hasResume ? tokens.cardSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(hasResume ? AppRadii.md : 0),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: AnimatedStateIcon(
              missing
                  ? AppIcons.imageBroken
                  : watched
                  ? AppIcons.checkCircle
                  : AppIcons.playCircleOutline,
              color: missing
                  ? context.appTheme.warning
                  : watched
                  ? context.appTheme.success
                  : AppSurfaces.accentInk(widget.accentColor),
            ),
            title: Text(context.l10n.detailsEpisodeNumber(widget.number)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AndroidDocuments.displayName(widget.path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (missing)
                  Text(
                    context.l10n.detailsMissingFile,
                    style: TextStyle(color: context.appTheme.warning),
                  ),
                if (saved > 0 && !missing)
                  Text(context.l10n.detailsSavedPosition(time)),
              ],
            ),
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
                  child: Text(
                    watched
                        ? context.l10n.detailsMarkUnwatched
                        : context.l10n.detailsMarkWatched,
                  ),
                ),
                if (!AndroidDocuments.isDocumentUri(widget.path))
                  PopupMenuItem(
                    value: 'folder',
                    child: Text(context.l10n.detailsOpenFileLocation),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
