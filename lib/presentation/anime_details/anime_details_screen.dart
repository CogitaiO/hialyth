import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/library_provider.dart';
import '../../providers/color_provider.dart';
import '../../widgets/escapable.dart';
import '../../widgets/custom_title_bar.dart';
import '../../widgets/anime_artwork.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';
import '../../core/localization/l10n.dart';
import 'widgets/ambient_background.dart';
import 'widgets/left_control_panel.dart';
import 'widgets/right_info_panel.dart';
import 'widgets/sticker_poster.dart';

class AnimeDetailsScreen extends ConsumerWidget {
  const AnimeDetailsScreen({
    super.key,
    required this.animeId,
    required this.heroTag,
  });
  final int animeId;
  final String heroTag;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeSync = ref.watch(animeDetailsProvider(animeId));
    return Escapable(
      child: Scaffold(
        // Text entry lives in dialog routes; keep the details behind them
        // stable while the keyboard animates.
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            children: [
              const CustomTitleBar(),
              Expanded(
                child: animeSync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.detailsTitleNotFound),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(animeDetailsProvider(animeId)),
                          child: Text(context.l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                  data: (anime) {
                    if (anime == null) {
                      return Center(
                        child: Text(context.l10n.detailsTitleNotFound),
                      );
                    }
                    final ambient =
                        ref.watch(animeColorProvider(anime)).valueOrNull ??
                        Theme.of(context).colorScheme.primary;
                    final accent = Theme.of(context).colorScheme.primary;
                    return Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 440,
                          child: AmbientBackground(color: ambient),
                        ),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      key: const ValueKey('details-back'),
                                      tooltip: context.l10n.playerBack,
                                      icon: const Icon(AppIcons.back),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        if (MediaQuery.sizeOf(context).width <
                                            1000) {
                                          return RightInfoPanel(
                                            anime: anime,
                                            accentColor: accent,
                                            showTitle: false,
                                            header: Padding(
                                              padding: EdgeInsets.only(
                                                // Leave room for the lifted
                                                // corners inside the viewport.
                                                top:
                                                    StickerPoster.supportsPlatform(
                                                      context,
                                                    )
                                                    ? AppSpacing.lg
                                                    : 0,
                                                bottom: 24,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 160,
                                                    height: 240,
                                                    child: Hero(
                                                      tag: heroTag,
                                                      child: StickerPoster(
                                                        child: AnimeArtwork(
                                                          cover: anime.coverUrl,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 24),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Text(
                                                          anime.title,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .headlineLarge
                                                              ?.copyWith(
                                                                height: 1.12,
                                                                letterSpacing:
                                                                    -.5,
                                                              ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        LeftControlPanel(
                                                          anime: anime,
                                                          accentColor: accent,
                                                          heroTag: heroTag,
                                                          showPoster: false,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 280,
                                              child: SingleChildScrollView(
                                                child: LeftControlPanel(
                                                  anime: anime,
                                                  accentColor: accent,
                                                  heroTag: heroTag,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 32),
                                            Expanded(
                                              child: RightInfoPanel(
                                                anime: anime,
                                                accentColor: accent,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
