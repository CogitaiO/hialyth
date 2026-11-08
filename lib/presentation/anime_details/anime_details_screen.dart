import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/library_provider.dart';
import '../../providers/color_provider.dart';
import '../../widgets/escapable.dart';
import '../../widgets/custom_title_bar.dart';
import '../../widgets/anime_artwork.dart';
import '../../theme/app_icons.dart';
import '../../core/localization/l10n.dart';
import 'widgets/ambient_background.dart';
import 'widgets/left_control_panel.dart';
import 'widgets/right_info_panel.dart';

class AnimeDetailsScreen extends ConsumerWidget {
  const AnimeDetailsScreen(
      {super.key, required this.animeId, required this.heroTag});
  final int animeId;
  final String heroTag;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeSync = ref.watch(animeDetailsProvider(animeId));
    return Escapable(
        child: Scaffold(
            body: Column(children: [
      const CustomTitleBar(),
      Expanded(
          child: animeSync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(context.l10n.detailsTitleNotFound),
          TextButton(
              onPressed: () => ref.invalidate(animeDetailsProvider(animeId)),
              child: Text(context.l10n.commonRetry)),
        ])),
        data: (anime) {
          if (anime == null) {
            return Center(child: Text(context.l10n.detailsTitleNotFound));
          }
          final ambient = ref.watch(animeColorProvider(anime)).valueOrNull ??
              Theme.of(context).colorScheme.primary;
          final accent = Theme.of(context).colorScheme.primary;
          return Stack(children: [
            Positioned.fill(child: AmbientBackground(color: ambient)),
            Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                                tooltip: context.l10n.playerBack,
                                icon: const Icon(AppIcons.back),
                                onPressed: () => Navigator.pop(context))),
                        const SizedBox(height: 8),
                        Expanded(child:
                            LayoutBuilder(builder: (context, constraints) {
                          if (MediaQuery.sizeOf(context).width < 1000) {
                            return RightInfoPanel(
                              anime: anime,
                              accentColor: accent,
                              showTitle: false,
                              header: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: 160,
                                            height: 240,
                                            child: Hero(
                                                tag: heroTag,
                                                child: AnimeArtwork(
                                                    cover: anime.coverUrl))),
                                        const SizedBox(width: 24),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                              Text(anime.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              const SizedBox(height: 16),
                                              LeftControlPanel(
                                                  anime: anime,
                                                  accentColor: accent,
                                                  heroTag: heroTag,
                                                  showPoster: false),
                                            ])),
                                      ])),
                            );
                          }
                          return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 280,
                                    child: SingleChildScrollView(
                                        child: LeftControlPanel(
                                            anime: anime,
                                            accentColor: accent,
                                            heroTag: heroTag))),
                                const SizedBox(width: 32),
                                Expanded(
                                    child: RightInfoPanel(
                                        anime: anime, accentColor: accent)),
                              ]);
                        })),
                      ]),
                    ))),
          ]);
        },
      )),
    ])));
  }
}
