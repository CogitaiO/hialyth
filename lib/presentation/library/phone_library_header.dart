import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/debouncer.dart';
import '../../core/localization/l10n.dart';
import '../../domain/anime.dart';
import '../../providers/library_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_surfaces.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/animated_state_icon.dart';
import 'library_folder_actions.dart';

/// Height of the header with the large title, search field and filters.
const double kPhoneLibraryHeaderExpanded = 250;

/// Height of the compact header once the page is scrolled.
const double kPhoneLibraryHeaderCollapsed = 130;

class PhoneLibraryHeaderDelegate extends SliverPersistentHeaderDelegate {
  const PhoneLibraryHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kPhoneLibraryHeaderCollapsed;

  @override
  double get maxExtent => kPhoneLibraryHeaderExpanded;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(covariant PhoneLibraryHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class PhoneLibraryHeader extends ConsumerStatefulWidget {
  const PhoneLibraryHeader({super.key, required this.progress});

  /// 0 at rest, 1 when the header is pinned in its compact form.
  final ValueListenable<double> progress;

  @override
  ConsumerState<PhoneLibraryHeader> createState() => _PhoneLibraryHeaderState();
}

class _PhoneLibraryHeaderState extends ConsumerState<PhoneLibraryHeader> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void dispose() {
    _debouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _title(BuildContext context, int index, String? collection) {
    if (index == 5) {
      return collection ?? context.l10n.libraryCollections;
    }
    return switch (index) {
      1 => context.l10n.libraryWatching,
      2 => context.l10n.libraryPlanned,
      3 => context.l10n.libraryCompleted,
      4 => context.l10n.libraryDropped,
      _ => context.l10n.libraryTitle,
    };
  }

  void _select(int index, List<String> collections) {
    ref.read(selectedSidebarIndexProvider.notifier).state = index;
    if (index == 5 &&
        ref.read(selectedCollectionProvider) == null &&
        collections.isNotEmpty) {
      ref.read(selectedCollectionProvider.notifier).state = collections.first;
    }
  }

  Widget _searchField(BuildContext context) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _searchController,
      focusNode: ref.watch(librarySearchFocusProvider),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {});
        _debouncer.run(() {
          if (mounted) ref.read(searchQueryProvider.notifier).state = value;
        });
      },
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: context.l10n.librarySearchHint,
        prefixIcon: Icon(AppIcons.search, size: 21, color: tokens.textMuted),
        filled: true,
        fillColor: tokens.container,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: .7),
            width: 1.5,
          ),
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: context.l10n.libraryClearSearch,
                icon: const Icon(AppIcons.close),
                onPressed: () {
                  _debouncer.cancel();
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                  setState(() {});
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(searchQueryProvider, (_, value) {
      if (value != _searchController.text) _searchController.text = value;
    });

    final tokens = context.appTheme;
    final selected = ref.watch(selectedSidebarIndexProvider);
    final collection = ref.watch(selectedCollectionProvider);
    final collections = ref.watch(allCollectionsProvider);
    final titles = ref.watch(libraryProvider).valueOrNull ?? <Anime>[];
    final count = ref.watch(filteredAnimeProvider).length;
    final running = ref.watch(scanProvider).running;
    final view = ref.watch(libraryViewProvider);
    final folders = ref.watch(savedFoldersProvider);
    final title = _title(context, selected, collection);

    final destinations = [
      context.l10n.libraryAllTitles,
      context.l10n.libraryWatching,
      context.l10n.libraryPlanned,
      context.l10n.libraryCompleted,
      context.l10n.libraryDropped,
      context.l10n.libraryCollections,
    ];
    final counts = [
      titles.length,
      for (final status in [
        AnimeStatus.watching,
        AnimeStatus.planned,
        AnimeStatus.completed,
        AnimeStatus.dropped,
      ])
        titles.where((anime) => anime.status == status).length,
      collections.length,
    ];

    final searchField = _searchField(context);
    final extraActions = Row(
      children: [
        _HeaderAction(
          icon: AppIcons.rescan,
          iconKey: const ValueKey('library-refresh'),
          tooltip: context.l10n.settingsRescanLibrary,
          filled: false,
          onTap: folders.isEmpty || running
              ? null
              : () => ref.read(scanProvider.notifier).scan(folders),
        ),
        PopupMenuButton<LibrarySort>(
          tooltip: context.l10n.librarySort,
          initialValue: view.sort,
          onSelected: ref.read(libraryViewProvider.notifier).sortBy,
          itemBuilder: (_) => [
            for (final sort in LibrarySort.values)
              PopupMenuItem(
                value: sort,
                child: Text(switch (sort) {
                  LibrarySort.title => context.l10n.librarySortTitle,
                  LibrarySort.dateAdded => context.l10n.librarySortAdded,
                  LibrarySort.lastWatched => context.l10n.librarySortWatched,
                  LibrarySort.progress => context.l10n.librarySortProgress,
                }),
              ),
          ],
          icon: const Icon(AppIcons.sort, size: 20),
        ),
        IconButton(
          tooltip: view.list
              ? context.l10n.libraryGrid
              : context.l10n.libraryList,
          iconSize: 20,
          icon: AnimatedStateIcon(view.list ? AppIcons.all : AppIcons.list),
          onPressed: () =>
              ref.read(libraryViewProvider.notifier).showList(!view.list),
        ),
      ],
    );

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The bottom edge melts into the list instead of cutting it.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.black, Color(0x00000000)],
                  stops: [0, .9, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            height: 40,
            child: RepaintBoundary(
              child: _filters(
                context,
                selected: selected,
                destinations: destinations,
                counts: counts,
                onSelect: (index) => _select(index, collections),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 10,
            top: 6,
            height: 44,
            child: Row(
              children: [
                _HeaderAction(
                  icon: AppIcons.menu,
                  tooltip: context.l10n.libraryNavigation,
                  onTap: () => Scaffold.of(context).openDrawer(),
                ),
                const Spacer(),
                ValueListenableBuilder<double>(
                  valueListenable: widget.progress,
                  child: extraActions,
                  builder: (context, t, child) {
                    final opacity = (1 - t * 2.8).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: IgnorePointer(
                        ignoring: opacity < .5,
                        child: child,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 2),
                _HeaderAction(
                  icon: AppIcons.addFolder,
                  tooltip: context.l10n.libraryAddFolder,
                  accent: true,
                  onTap: running ? null : () => addLibraryFolder(context, ref),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: widget.progress,
              child: searchField,
              builder: (context, t, searchField) {
                final travel = Curves.easeInOutCubic.transform(t);
                final titleLeft = 16 + 46 * (t / .4).clamp(0.0, 1.0);
                final titleTop = 62 - 44 * travel;
                final titleScale = (32 - 13 * travel) / 32;
                final countOpacity = (1 - ((t - .55) / .35).clamp(0.0, 1.0));
                final searchOpacity = (1 - t * 5).clamp(0.0, 1.0);

                return Stack(
                  children: [
                    Positioned(
                      left: titleLeft,
                      right: 76,
                      top: titleTop,
                      height: 42,
                      child: Transform.scale(
                        scale: titleScale,
                        alignment: Alignment.topLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(height: 1.2),
                              ),
                            ),
                            if (countOpacity > 0) ...[
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Opacity(
                                  opacity: countOpacity,
                                  child: Text(
                                    '· $count',
                                    style: TextStyle(
                                      color: tokens.textMuted,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      top: 112,
                      height: 48,
                      child: IgnorePointer(
                        ignoring: searchOpacity < .3,
                        child: Opacity(
                          opacity: searchOpacity,
                          child: searchField,
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
    );
  }

  Widget _filters(
    BuildContext context, {
    required int selected,
    required List<String> destinations,
    required List<int> counts,
    required ValueChanged<int> onSelect,
  }) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: destinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final active = selected == index;
              return AnimatedContainer(
                duration: AppMotion.resolveDuration(context, AppMotion.normal),
                curve: AppMotion.enter,
                decoration: BoxDecoration(
                  color: active
                      ? Color.alphaBlend(
                          scheme.primary.withValues(alpha: .28),
                          tokens.containerHigh,
                        )
                      : tokens.container,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => onSelect(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Text(
                            destinations[index],
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: active
                                      ? tokens.textPrimary
                                      : tokens.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${counts[index]}',
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
                                  color: active
                                      ? tokens.textSecondary
                                      : tokens.textMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      tokens.pageSurface,
                      tokens.pageSurface.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconKey,
    this.accent = false,
    this.filled = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Key? iconKey;
  final bool accent;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      key: iconKey,
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(42, 42),
        backgroundColor: accent
            ? Color.alphaBlend(
                scheme.primary.withValues(alpha: .28),
                tokens.container,
              )
            : (filled ? tokens.container : Colors.transparent),
        foregroundColor: accent
            ? AppSurfaces.accentInk(scheme.primary)
            : tokens.textSecondary,
        disabledBackgroundColor: filled ? tokens.container : Colors.transparent,
        disabledForegroundColor: tokens.textDisabled,
        shape: const CircleBorder(),
      ),
    );
  }
}
