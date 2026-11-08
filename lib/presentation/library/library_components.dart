import 'package:flutter/material.dart';
import '../../domain/anime.dart';
import '../../core/localization/l10n.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/anime_artwork.dart';
import '../anime_details/anime_details_screen.dart';
import '../player/player_screen.dart';

void _details(BuildContext context, Anime anime) => Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => AnimeDetailsScreen(
            animeId: anime.id, heroTag: 'library_list_${anime.id}')));

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({super.key, required this.anime});
  final Anime anime;
  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    final ambient = anime.ambientColorValue == null
        ? scheme.primary
        : Color(anime.ambientColorValue!);
    final next = anime.nextEpisodeToPlay;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.borderStrong),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.containerHigh,
                Color.alphaBlend(
                    ambient.withValues(alpha: .14), colors.pageSurface)
              ])),
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        SizedBox(
            width: 108,
            height: 162,
            child: AnimeArtwork(cover: anime.coverUrl)),
        const SizedBox(width: 24),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l10n.libraryContinueWatching,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.primary)),
          const SizedBox(height: 8),
          Text(anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(context.l10n.detailsWatched(
              anime.episodePaths.length,
              anime.episodePaths
                  .toSet()
                  .intersection(anime.watchedEpisodes.toSet())
                  .length)),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 8, children: [
            FilledButton.icon(
                onPressed: next == null
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PlayerScreen(
                                animeId: anime.id, videoPath: next))),
                icon: const Icon(AppIcons.play, size: 18),
                label: Text(context.l10n.detailsContinue(
                    anime.sortedEpisodes.indexOf(next ?? '') + 1))),
            TextButton(
                onPressed: () => _details(context, anime),
                child: Text(context.l10n.detailsInformation)),
          ]),
        ])),
      ]),
    );
  }
}

class AnimeListTile extends StatelessWidget {
  const AnimeListTile({super.key, required this.anime});
  final Anime anime;
  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final status = switch (anime.status) {
      AnimeStatus.planned => context.l10n.statusPlanned,
      AnimeStatus.watching => context.l10n.statusWatching,
      AnimeStatus.completed => context.l10n.statusCompleted,
      AnimeStatus.dropped => context.l10n.statusDropped,
    };
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: colors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
              onTap: () => _details(context, anime),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  SizedBox(
                      width: 44,
                      height: 66,
                      child: AnimeArtwork(
                          cover: anime.coverUrl, radius: 8, cacheWidth: 120)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(anime.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('$status · ${anime.progressFraction}',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                            value: anime.watchProgress.clamp(0, 1),
                            minHeight: 3),
                      ])),
                  const SizedBox(width: 16),
                  Text(anime.progressPercentage,
                      style: Theme.of(context).textTheme.labelLarge),
                ]),
              )),
        ));
  }
}
