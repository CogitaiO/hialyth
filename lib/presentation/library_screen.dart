import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nekaido_pre/presentation/settings/settings_screen.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/scan_provider.dart';
import '../../core/debouncer.dart';
import '../../core/localization/l10n.dart';
import '../widgets/media_card.dart';
import '../widgets/custom_title_bar.dart';
import '../theme/app_icons.dart';
import '../theme/app_breakpoints.dart';
import '../domain/anime.dart';
import '../theme/app_theme_extension.dart';

Future<void> _addLibraryFolder(BuildContext context, WidgetRef ref) async {
  if (ref.read(scanProvider).running) return;
  final path = await FilePicker.getDirectoryPath();
  if (path == null || !context.mounted) return;
  try {
    ref.read(savedFoldersProvider.notifier).addFolder(path);
    final result = await ref.read(scanProvider.notifier).scan([path]);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.errors.isNotEmpty
                ? context.l10n.libraryScanError
                : result.warnings > 0
                    ? context.l10n.libraryMetadataWarning
                    : context.l10n.libraryFolderAdded)),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.libraryScanError)),
      );
    }
  }
}

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < AppBreakpoints.compact;
      return Scaffold(
        drawer: compact
            ? const Drawer(child: _LibraryNavigation(expanded: true))
            : null,
        body: Column(children: [
          const CustomTitleBar(),
          Expanded(
              child: Row(children: [
            if (!compact)
              _LibraryNavigation(expanded: constraints.maxWidth >= 1200),
            const Expanded(
                child: Column(children: [
              _TopBar(),
              Expanded(child: _ContentGrid()),
            ])),
          ])),
        ]),
      );
    });
  }
}

class _LibraryNavigation extends ConsumerWidget {
  final bool expanded;
  const _LibraryNavigation({required this.expanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(selectedSidebarIndexProvider);
    final titles = ref.watch(libraryProvider).valueOrNull ?? <Anime>[];
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
        AnimeStatus.dropped
      ])
        titles.where((title) => title.status == status).length,
      ref.watch(allCollectionsProvider).length,
    ];
    return Container(
      width: expanded
          ? (MediaQuery.sizeOf(context).width >= 1600 ? 240 : 220)
          : 72,
      decoration: BoxDecoration(
        color: colors.titleBarSurface,
        border: Border(right: BorderSide(color: colors.borderSubtle)),
      ),
      child: Material(
          color: Colors.transparent,
          child: SafeArea(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(AppIcons.appLogo, color: scheme.primary, size: 28),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(context.l10n.appTitle,
                          style: Theme.of(context).textTheme.titleLarge)),
                ],
              ]),
            ),
            Expanded(
                child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                  for (var i = 0; i < destinations.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Tooltip(
                        message: expanded ? '' : destinations[i].$1,
                        child: Material(
                          color: selected == i
                              ? scheme.primary.withValues(alpha: 0.13)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            selected: selected == i,
                            selectedColor: scheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: expanded ? 12 : 10),
                            leading: Icon(destinations[i].$2, size: 24),
                            title: expanded ? Text(destinations[i].$1) : null,
                            trailing: expanded
                                ? Text('${counts[i]}',
                                    style:
                                        Theme.of(context).textTheme.labelMedium)
                                : null,
                            onTap: () {
                              ref
                                  .read(selectedSidebarIndexProvider.notifier)
                                  .state = i;
                              if (i == 5 &&
                                  ref.read(selectedCollectionProvider) ==
                                      null) {
                                final collections =
                                    ref.read(allCollectionsProvider);
                                if (collections.isNotEmpty) {
                                  ref
                                      .read(selectedCollectionProvider.notifier)
                                      .state = collections.first;
                                }
                              }
                              Scaffold.of(context).closeDrawer();
                            },
                          ),
                        ),
                      ),
                    ),
                ])),
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Tooltip(
                message: context.l10n.settingsTitle,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  leading: const Icon(AppIcons.settings, size: 24),
                  title: expanded ? Text(context.l10n.settingsTitle) : null,
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()));
                  },
                ),
              ),
            ),
          ]))),
    );
  }
}

class _TopBar extends ConsumerStatefulWidget {
  const _TopBar();
  @override
  ConsumerState<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<_TopBar> {
  final _debouncer = Debouncer(milliseconds: 300);
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _debouncer.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String _getTitle(BuildContext context, int index) {
    switch (index) {
      case 1:
        return context.l10n.libraryWatching;
      case 2:
        return context.l10n.libraryPlanned;
      case 3:
        return context.l10n.libraryCompleted;
      case 4:
        return context.l10n.libraryDropped;
      case 5:
        return context.l10n.libraryCollections;
      default:
        return context.l10n.libraryTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(searchQueryProvider, (_, value) {
      if (value != _searchController.text) _searchController.text = value;
    });
    final index = ref.watch(selectedSidebarIndexProvider);
    final allCollections = ref.watch(allCollectionsProvider);
    final selectedCollections = ref.watch(selectedCollectionProvider);
    final tokens = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (MediaQuery.sizeOf(context).width < 900)
                IconButton(
                  tooltip: context.l10n.libraryNavigation,
                  icon: const Icon(AppIcons.all),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(_getTitle(context, index),
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 4),
                    Text(
                        context.l10n.libraryTitleCount(
                            ref.watch(filteredAnimeProvider).length),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ])),
              FilledButton.icon(
                onPressed: ref.watch(scanProvider).running
                    ? null
                    : () => _addLibraryFolder(context, ref),
                icon: const Icon(AppIcons.addFolder, size: 20),
                label: Text(context.l10n.libraryAddFolder),
              ),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (value) {
                setState(() {});
                _debouncer.run(() {
                  if (mounted) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  }
                });
              },
              decoration: InputDecoration(
                hintText: context.l10n.librarySearchHint,
                prefixIcon: const Icon(AppIcons.search),
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
            ),
            if (ref.watch(scanProvider).running) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 4),
              Text(context.l10n.libraryScanningFolder),
            ],
          ]),
        ),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 300),
          child: index == 5
              ? Container(
                  height: AppSpacing.s50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: allCollections.isEmpty
                      ? Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            context.l10n.libraryNoCollections,
                            style: TextStyle(color: tokens.textMuted),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allCollections.length,
                          itemBuilder: (context, i) {
                            final collectionName = allCollections[i];
                            final isSelected =
                                selectedCollections == collectionName;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSpacing.xs),
                              child: ChoiceChip(
                                label: Text(collectionName),
                                selected: isSelected,
                                selectedColor: Color(ref
                                        .watch(settingsProvider)
                                        .accentColorValue)
                                    .withValues(alpha: 0.3),
                                backgroundColor: tokens.surfaceSubtle,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Color(ref
                                          .watch(settingsProvider)
                                          .accentColorValue)
                                      : tokens.textSecondary,
                                ),
                                side: BorderSide(
                                    color: isSelected
                                        ? Color(ref
                                            .watch(settingsProvider)
                                            .accentColorValue)
                                        : Colors.transparent),
                                onSelected: (selected) {
                                  if (selected) {
                                    ref
                                        .read(
                                            selectedCollectionProvider.notifier)
                                        .state = collectionName;
                                  } else {
                                    ref
                                        .read(
                                            selectedCollectionProvider.notifier)
                                        .state = null;
                                  }
                                },
                              ),
                            );
                          },
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ContentGrid extends ConsumerStatefulWidget {
  const _ContentGrid();

  @override
  ConsumerState<_ContentGrid> createState() => _ContentGridState();
}

class _ContentGridState extends ConsumerState<_ContentGrid> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowVpnWarning();
      _runAutoScan();
    });
  }

  Future<void> _runAutoScan() async {
    final folders = ref.read(savedFoldersProvider);
    if (folders.isEmpty) return;
    await ref.read(scanProvider.notifier).scan(folders);
  }

  Future<void> _checkAndShowVpnWarning() async {
    final prefs = ref.read(sharedPrefsProvider);
    final hasSeenWarning = prefs.getBool('has_seen_vpn_warning') ?? false;

    if (!hasSeenWarning) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false, // Require an explicit dismissal.
        builder: (ctx) => AlertDialog(
          backgroundColor: context.appTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          title: Row(
            children: [
              Icon(
                AppIcons.shield,
                color: context.appTheme.destructive,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.networkRecommendationTitle,
                style: TextStyle(color: context.appTheme.textPrimary),
              ),
            ],
          ),
          content: Text(
            context.l10n.networkRecommendationBody,
            style:
                TextStyle(color: context.appTheme.textSecondary, height: 2.5),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(ref.watch(settingsProvider).accentColorValue)),
              onPressed: () {
                prefs.setBool('has_seen_vpn_warning', true);
                Navigator.pop(ctx);
              },
              child: Text(
                context.l10n.networkRecommendationGotIt,
                style: TextStyle(color: context.appTheme.textPrimary),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryProvider);
    return libraryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          context.l10n.libraryDatabaseError(err.toString()),
          style: TextStyle(color: context.appTheme.textPrimary),
        ),
      ),
      data: (allAnimes) {
        final filteredList = ref.watch(filteredAnimeProvider);
        if (filteredList.isEmpty) {
          final emptyLibrary = allAnimes.isEmpty;
          final noFiles =
              emptyLibrary && ref.watch(savedFoldersProvider).isNotEmpty;
          return Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(emptyLibrary ? AppIcons.videoLibrary : AppIcons.search,
                        size: 48, color: context.appTheme.textMuted),
                    const SizedBox(height: 24),
                    Text(
                        emptyLibrary
                            ? (noFiles
                                ? context.l10n.libraryNoFilesTitle
                                : context.l10n.libraryEmptyTitle)
                            : context.l10n.libraryNothingFound,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Text(
                        emptyLibrary
                            ? (noFiles
                                ? context.l10n.libraryNoFilesBody
                                : context.l10n.libraryEmptyBody)
                            : context.l10n.libraryNoResultsBody,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    if (emptyLibrary)
                      FilledButton.icon(
                        onPressed: ref.watch(scanProvider).running
                            ? null
                            : () => _addLibraryFolder(context, ref),
                        icon: const Icon(AppIcons.addFolder),
                        label: Text(context.l10n.libraryAddFolder),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref
                              .read(selectedSidebarIndexProvider.notifier)
                              .state = 0;
                          ref.read(selectedCollectionProvider.notifier).state =
                              null;
                        },
                        child: Text(context.l10n.libraryResetFilters),
                      ),
                  ],
                )),
          ));
        }
        return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      childAspectRatio: 0.56,
                      crossAxisSpacing: AppSpacing.s20,
                      mainAxisSpacing: AppSpacing.s20,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return AnimeCard(anime: filteredList[index]);
                    })));
      },
    );
  }
}
