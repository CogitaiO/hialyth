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

class ContinueWatchingSection extends StatelessWidget {
  const ContinueWatchingSection({super.key, required this.anime});
  final List<Anime> anime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cardWidth =
          ((constraints.maxWidth - 48 - 24) / 3).clamp(280.0, 360.0).toDouble();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(children: [
            Expanded(
                child: Text(context.l10n.libraryContinueWatching,
                    style: Theme.of(context).textTheme.titleLarge)),
            Text('${anime.length}',
                style: Theme.of(context).textTheme.labelMedium),
          ]),
        ),
        SizedBox(
          height: 148,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: anime.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              child: ContinueWatchingCard(anime: anime[index]),
            ),
          ),
        ),
      ]);
    });
  }
}

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({super.key, required this.anime});
  final Anime anime;
  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final next = anime.nextEpisodeToPlay;
    final watched = anime.episodePaths
        .toSet()
        .intersection(anime.watchedEpisodes.toSet())
        .length;
    final progress = anime.watchProgress.clamp(0.0, 1.0);
    return Material(
      color: colors.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: colors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _details(context, anime),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(children: [
            SizedBox(
              width: 76,
              height: 114,
              child: AnimeArtwork(
                  cover: anime.coverUrl, radius: AppRadii.md, cacheWidth: 160),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                      context.l10n
                          .detailsWatched(anime.episodePaths.length, watched),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: colors.borderSubtle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: 34,
                    child: Tooltip(
                      message: context.l10n.detailsContinue(
                          anime.sortedEpisodes.indexOf(next ?? '') + 1),
                      child: FilledButton.icon(
                        onPressed: next == null
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                        animeId: anime.id, videoPath: next))),
                        icon: const Icon(AppIcons.play, size: 16),
                        label: Text(
                          context.l10n.detailsEpisodeNumber(
                              anime.sortedEpisodes.indexOf(next ?? '') + 1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
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
