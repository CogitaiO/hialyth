import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/l10n.dart';
import '../../domain/anime.dart';
import '../../providers/library_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_surfaces.dart';
import '../../theme/app_theme_extension.dart';
import '../settings/settings_screen.dart';

/// The phone navigation surface. It follows the same "stacked pills" rhythm
/// as the rest of the mobile shell: a quiet panel, one rounded row per
/// destination, and the artwork accent reserved for the active row.
class LibraryDrawer extends ConsumerWidget {
  const LibraryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(selectedSidebarIndexProvider);
    final titles = ref.watch(libraryProvider).valueOrNull ?? <Anime>[];
    final collections = ref.watch(allCollectionsProvider);
    final running = ref.watch(scanProvider).running;
    final width = (MediaQuery.sizeOf(context).width * .86).clamp(264.0, 320.0);

    final destinations = [
      (context.l10n.libraryAllTitles, AppIcons.all),
      (context.l10n.libraryWatching, AppIcons.watching),
      (context.l10n.libraryPlanned, AppIcons.planned),
      (context.l10n.libraryCompleted, AppIcons.completed),
      (context.l10n.libraryDropped, AppIcons.dropped),
      (context.l10n.libraryCollections, AppIcons.collections),
    ];
    final counts = [
      titles.length,
      for (final status in [
        AnimeStatus.watching,
        AnimeStatus.planned,
        AnimeStatus.completed,
        AnimeStatus.dropped,
      ])
        titles.where((title) => title.status == status).length,
      collections.length,
    ];

    void select(int index) {
      ref.read(selectedSidebarIndexProvider.notifier).state = index;
      if (index == 5 && ref.read(selectedCollectionProvider) == null) {
        if (collections.isNotEmpty) {
          ref.read(selectedCollectionProvider.notifier).state =
              collections.first;
        }
      }
      Scaffold.of(context).closeDrawer();
    }

    return Drawer(
      width: width,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: ColoredBox(
        color: tokens.container,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 10, 6),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppSurfaces.artworkWash(
                          scheme.primary,
                          tokens.containerHigh,
                          strength: .38,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        AppIcons.appLogo,
                        color: AppSurfaces.accentInk(scheme.primary),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.appTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            context.l10n.libraryTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(color: tokens.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      icon: const Icon(AppIcons.close, size: 20),
                      onPressed: () => Scaffold.of(context).closeDrawer(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DrawerDestination(
                          label: destinations[i].$1,
                          icon: destinations[i].$2,
                          count: counts[i],
                          selected: selected == i,
                          onTap: () => select(i),
                        ),
                      ),
                    if (selected == 5 && collections.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                        child: Text(
                          context.l10n.libraryCollections,
                          style: Theme.of(context).textTheme.labelSmall!
                              .copyWith(
                                color: tokens.textMuted,
                                letterSpacing: .8,
                              ),
                        ),
                      ),
                      for (final collection in collections)
                        _CollectionDestination(
                          name: collection,
                          selected:
                              ref.watch(selectedCollectionProvider) ==
                              collection,
                          onTap: () {
                            ref
                                    .read(selectedCollectionProvider.notifier)
                                    .state =
                                collection;
                            Scaffold.of(context).closeDrawer();
                          },
                        ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  children: [
                    _DrawerDestination(
                      label: context.l10n.settingsRescanLibrary,
                      icon: AppIcons.rescan,
                      selected: false,
                      busy: running,
                      onTap: running
                          ? null
                          : () {
                              final folders = ref.read(savedFoldersProvider);
                              if (folders.isEmpty) return;
                              ref.read(scanProvider.notifier).scan(folders);
                              Scaffold.of(context).closeDrawer();
                            },
                    ),
                    const SizedBox(height: 8),
                    _DrawerDestination(
                      label: context.l10n.settingsTitle,
                      icon: AppIcons.settings,
                      selected: false,
                      onTap: () {
                        Scaffold.of(context).closeDrawer();
                        Navigator.push(
                          context,
                          AppMotion.pageRoute(
                            context,
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerDestination extends StatelessWidget {
  const _DrawerDestination({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.count,
    this.busy = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final int? count;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    final fill = selected
        ? Color.alphaBlend(
            scheme.primary.withValues(alpha: .28),
            tokens.containerHigh,
          )
        : tokens.containerHigh;
    final ink = selected
        ? AppSurfaces.accentInk(scheme.primary)
        : tokens.textSecondary;

    return AnimatedContainer(
      duration: AppMotion.resolveDuration(context, AppMotion.normal),
      curve: AppMotion.enter,
      height: 52,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            selected: selected,
            button: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(icon, size: 21, color: ink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: selected
                            ? tokens.textPrimary
                            : tokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (busy)
                    SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tokens.textMuted,
                      ),
                    )
                  else if (count != null)
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: selected
                            ? tokens.textSecondary
                            : tokens.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionDestination extends StatelessWidget {
  const _CollectionDestination({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? tokens.containerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
            child: Row(
              children: [
                Icon(
                  AppIcons.folder,
                  size: 18,
                  color: selected ? scheme.primary : tokens.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: selected
                          ? tokens.textPrimary
                          : tokens.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
