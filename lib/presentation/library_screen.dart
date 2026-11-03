import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nekaido_pre/presentation/settings/settings_screen.dart'; // Проверьте правильность пути
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/debouncer.dart';
import '../widgets/media_card.dart';
import '../widgets/custom_title_bar.dart'; // <-- Исправлена опечатка с кавычкой
import '../theme/app_theme_extension.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Кастомная шапка всегда на самом верху, во всю ширину
          const CustomTitleBar(),

          // 2. Основной контент (Сайдбар + Сетка), растянутый на оставшееся место
          Expanded(
            child: Row(
              // <-- ВАЖНО: Row, чтобы сайдбар был слева, а контент справа
              children: [
                const _LeftSidebar(),
                Expanded(
                  child: Column(
                    children: const [
                      _TopBar(),
                      Expanded(
                        child: _ContentGrid(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          final String? folderPath = await FilePicker.getDirectoryPath();
          if (folderPath != null) {
            ref.read(savedFoldersProvider.notifier).addFolder(folderPath);

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Scanning folder...")));

            final scanner = ref.read(scannerProvider);
            await scanner.scanAndGroupFiles(folderPath);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Folder added to library"),
                  backgroundColor: context.appTheme.success,
                ),
              );
            }
          }
        },
        icon: Icon(Icons.create_new_folder_rounded,
            color: context.appTheme.textPrimary),
        label: Text("Add folder",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _LeftSidebar extends StatelessWidget {
  const _LeftSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      color: context.appTheme.titleBarSurface,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Tooltip(
            message: "Режим: Аниме\n(Нажми для смены)",
            decoration: BoxDecoration(
              color: context.appTheme.surfaceTooltip,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      blurRadius: 10,
                      spreadRadius: -2)
                ],
              ),
              child: Icon(Icons.movie_creation,
                  color: context.appTheme.textPrimary, size: 24),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(
            color: context.appTheme.borderFaint,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  _SidebarIcon(
                      icon: Icons.all_inclusive,
                      tooltip: "Вся библиотека",
                      index: 0),
                  _SidebarIcon(
                      icon: Icons.play_circle_outline,
                      tooltip: "Смотрю",
                      index: 1),
                  _SidebarIcon(
                      icon: Icons.watch_later_outlined,
                      tooltip: "В планах",
                      index: 2),
                  _SidebarIcon(
                      icon: Icons.check_circle_outline,
                      tooltip: "Просмотрено",
                      index: 3),
                  _SidebarIcon(
                      icon: Icons.cancel_outlined,
                      tooltip: "Брошено",
                      index: 4),
                  const SizedBox(height: AppSpacing.md),
                  Divider(
                    color: context.appTheme.borderFaint,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SidebarIcon(
                      icon: Icons.folder_special_outlined,
                      tooltip: "Мои подборки",
                      index: 5),
                ],
              ),
            ),
          ),
          const _SidebarIcon(
              icon: Icons.settings,
              tooltip: "Settings",
              index: -1,
              isBottom: true),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SidebarIcon extends ConsumerStatefulWidget {
  final IconData icon;
  final String tooltip;
  final int index;
  final bool isBottom;

  const _SidebarIcon({
    required this.icon,
    required this.tooltip,
    required this.index,
    this.isBottom = false,
  });

  @override
  ConsumerState<_SidebarIcon> createState() => _SidebarIconState();
}

class _SidebarIconState extends ConsumerState<_SidebarIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final tokens = context.appTheme;
    final isSelected = ref.watch(selectedSidebarIndexProvider
            .select((val) => val == widget.index)) &&
        !widget.isBottom;
    final color = isSelected
        ? primaryColor
        : (_isHovered ? tokens.textPrimary : tokens.textSubtle);

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: tokens.surfaceTooltip,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: tokens.borderSubtle),
      ),
      textStyle: TextStyle(color: tokens.textPrimary, fontSize: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (widget.isBottom && widget.index == -1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            } else if (!widget.isBottom) {
              ref.read(selectedSidebarIndexProvider.notifier).state =
                  widget.index;
              if (widget.index == 5) {
                final collections = ref.read(allCollectionsProvider);
                if (collections.isNotEmpty &&
                    ref.read(selectedCollectionProvider) == null) {
                  ref.read(selectedCollectionProvider.notifier).state =
                      collections.first;
                }
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Icon(widget.icon, color: color, size: 28),
          ),
        ),
      ),
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

  String _getTitle(int index) {
    switch (index) {
      case 1:
        return "Watching";
      case 2:
        return "In plans";
      case 3:
        return "Watched";
      case 4:
        return "Abandoned ";
      case 5:
        return "My collections";
      default:
        return "Library";
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(selectedSidebarIndexProvider);
    final allCollections = ref.watch(allCollectionsProvider);
    final selectedCollections = ref.watch(selectedCollectionProvider);
    final tokens = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Text(_getTitle(index),
                  style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  onChanged: (value) {
                    _debouncer.run(() {
                      ref.read(searchQueryProvider.notifier).state = value;
                    });
                  },
                  style: TextStyle(color: tokens.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: tokens.textSubtle),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: tokens.textMuted),
                    filled: true,
                    fillColor: tokens.surfaceSubtle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: index == 5
              ? Container(
                  height: AppSpacing.s50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: allCollections.isEmpty
                      ? Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            "You don't have any collections yet",
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
    final scanner = ref.read(scannerProvider);
    for (String folder in folders) {
      await scanner.scanAndGroupFiles(folder);
    }
  }

  Future<void> _checkAndShowVpnWarning() async {
    final prefs = ref.read(sharedPrefsProvider);
    final hasSeenWarning = prefs.getBool('has_seen_vpn_warning') ?? false;

    if (!hasSeenWarning) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false, // Запрещаем закрывать кликом мимо
        builder: (ctx) => AlertDialog(
          backgroundColor: context.appTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          title: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: context.appTheme.destructive,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Рекомендация по сети",
                style: TextStyle(color: context.appTheme.textPrimary),
              ),
            ],
          ),
          content: Text(
            "Для корректной работы приложения (загрузки постеров, описаний и поиска таймкодов пропусков опенингов) используются зарубежные сервисы Shikimori и AniSkip.\n\n"
            "Если вы находитесь в РФ, некоторые из них могут блокироваться провайдерами.\n\n"
            "В случае сбоев или бесконечных загрузок настоятельно рекомендуется включить VPN (например, с маршрутизацией для определенных IP) или использовать средства обхода блокировок.",
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
                "Понятно",
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
          "Ошибка БД: $err",
          style: TextStyle(color: context.appTheme.textPrimary),
        ),
      ),
      data: (allAnimes) {
        final filteredList = ref.watch(filteredAnimeProvider);
        if (filteredList.isEmpty) {
          return Center(
            child: Text(
              "Ничего не найдено",
              style: TextStyle(color: context.appTheme.textMuted),
            ),
          );
        }
        return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 0.7,
              crossAxisSpacing: AppSpacing.s20,
              mainAxisSpacing: AppSpacing.s20,
            ),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              return AnimeCard(anime: filteredList[index]);
            });
      },
    );
  }
}
