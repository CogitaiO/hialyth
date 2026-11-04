import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/library_provider.dart';
import '../../providers/color_provider.dart';
import '../../widgets/escapable.dart';
import '../../widgets/custom_title_bar.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';
import 'widgets/ambient_background.dart';
import 'widgets/left_control_panel.dart';
import 'widgets/right_info_panel.dart';

class AnimeDetailsScreen extends ConsumerWidget {
  final int animeId;
  final String heroTag;

  const AnimeDetailsScreen({
    super.key,
    required this.animeId,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeSync = ref.watch(animeDetailsProvider(animeId));

    return Escapable(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            const CustomTitleBar(),
            Expanded(
              child: animeSync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    "Ошибка: $err",
                    style: TextStyle(color: context.appTheme.textPrimary),
                  ),
                ),
                data: (anime) {
                  if (anime == null) {
                    return const Center(child: Text("Тайтл не найден"));
                  }

                  final accentColor =
                      ref.watch(animeColorProvider(anime)).value ??
                          Colors.transparent;

                  return Stack(
                    children: [
                      AmbientBackground(color: accentColor),
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: IconButton(
                                icon: Icon(
                                  AppIcons.back,
                                  color: context.appTheme.textPrimary,
                                  size: 28,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1100),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.xl,
                                    AppSpacing.s10,
                                    AppSpacing.xl,
                                    AppSpacing.s40,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 280,
                                        child: LeftControlPanel(
                                            anime: anime,
                                            accentColor: accentColor,
                                            heroTag: heroTag),
                                      ),
                                      const SizedBox(width: AppSpacing.s48),
                                      Expanded(
                                        child: RightInfoPanel(
                                            anime: anime,
                                            accentColor: accentColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
