import 'package:flutter/material.dart';
import '../../domain/anime.dart';
import '../../core/localization/l10n.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_surfaces.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/anime_artwork.dart';
import '../anime_details/anime_details_screen.dart';
import '../player/player_screen.dart';

void _details(BuildContext context, Anime anime) => Navigator.push(
  context,
  AppMotion.pageRoute(
    context,
    builder: (_) => AnimeDetailsScreen(
      animeId: anime.id,
      heroTag: 'library_list_${anime.id}',
    ),
  ),
);

class ContinueWatchingSection extends StatelessWidget {
  const ContinueWatchingSection({super.key, required this.anime});
  final List<Anime> anime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final phone = width < 600;
        final inset = phone ? 16.0 : 24.0;
        final cardWidth = phone
            ? width - inset * 2
            : ((width - 72) / 3).clamp(280.0, 360.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(inset, 8, inset, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.libraryContinueWatching,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${anime.length}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 148,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: inset),
                scrollDirection: Axis.horizontal,
                itemCount: anime.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: cardWidth,
                  child: ContinueWatchingCard(anime: anime[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({super.key, required this.anime});
  final Anime anime;
  @override
  Widget build(BuildContext context) {
    final colors = context.appTheme;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ambient = anime.ambientColorValue;
    final accent = ambient == null ? scheme.primary : Color(ambient);
    final ink = AppSurfaces.accentInk(accent);
    final printColor = ambient == null
        ? colors.cardSurface
        : AppSurfaces.artworkWash(accent, colors.cardSurface, strength: .22);
    final next = anime.nextEpisodeToPlay;
    final watched = anime.episodePaths
        .toSet()
        .intersection(anime.watchedEpisodes.toSet())
        .length;
    final progress = anime.watchProgress.clamp(0.0, 1.0);
    return Material(
      color: colors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [printColor, colors.cardSurface],
            stops: const [.28, 1],
          ),
        ),
        child: InkWell(
          onTap: () => _details(context, anime),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 98,
                child: AnimeArtwork(
                  cover: anime.coverUrl,
                  title: anime.title,
                  radius: 0,
                  cacheWidth: 240,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        anime.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        context.l10n.detailsWatched(
                          anime.episodePaths.length,
                          watched,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          color: ink,
                          backgroundColor: colors.borderSubtle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SizedBox(
                        height: 34,
                        child: Tooltip(
                          message: context.l10n.detailsContinue(
                            anime.sortedEpisodes.indexOf(next ?? '') + 1,
                          ),
                          child: FilledButton.icon(
                            onPressed: next == null
                                ? null
                                : () => Navigator.push(
                                    context,
                                    AppMotion.pageRoute(
                                      context,
                                      builder: (_) => PlayerScreen(
                                        animeId: anime.id,
                                        videoPath: next,
                                      ),
                                    ),
                                  ),
                            icon: const Icon(AppIcons.play, size: 16),
                            label: Text(
                              context.l10n.detailsEpisodeNumber(
                                anime.sortedEpisodes.indexOf(next ?? '') + 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: Size.zero,
                              backgroundColor: AppSurfaces.controlSurface(
                                accent,
                                colors.cardSurface,
                              ),
                              foregroundColor: ink,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    final progress = anime.watchProgress.clamp(0.0, 1.0);
    final swatch = anime.ambientColorValue;
    final progressInk = AppSurfaces.accentInk(
      swatch == null ? Theme.of(context).colorScheme.primary : Color(swatch),
    );
    final (status, statusColor) = switch (anime.status) {
      AnimeStatus.planned => (context.l10n.statusPlanned, colors.statusPlanned),
      AnimeStatus.watching => (
        context.l10n.statusWatching,
        colors.statusWatching,
      ),
      AnimeStatus.completed => (
        context.l10n.statusCompleted,
        colors.statusCompleted,
      ),
      AnimeStatus.dropped => (context.l10n.statusDropped, colors.statusDropped),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _details(context, anime),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
            child: Row(
              children: [
                SizedBox(
                  width: 54,
                  height: 76,
                  child: AnimeArtwork(
                    cover: anime.coverUrl,
                    title: anime.title,
                    radius: 10,
                    cacheWidth: 140,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '$status · ${anime.progressFraction}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: colors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      if (progress > 0) ...[
                        const SizedBox(height: 9),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            color: progressInk,
                            backgroundColor: colors.borderSubtle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (progress > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    anime.progressPercentage,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: colors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
