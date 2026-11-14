import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import 'package:nekaido_pre/data/services/file_discovery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories_provider.dart';
import '../domain/anime.dart';

final libraryProvider = StreamProvider<List<Anime>>((ref) {
  final repo = ref.watch(animeRepoProvider);
  return repo.watchLibrary();
});

final searchQueryProvider = StateProvider<String>((ref) => "");

/// Sidebar category: 0 = all, 1 = watching, 2 = planned, 3 = completed,
/// 4 = dropped, 5 = collections.
final selectedSidebarIndexProvider = StateProvider<int>((ref) => 0);

final selectedCollectionProvider = StateProvider<String?>((ref) => null);

final allCollectionsProvider = Provider<List<String>>((ref) {
  final allAnime = ref.watch(libraryProvider).value ?? [];
  final Set<String> uniqueCollections = {};

  for (var anime in allAnime) {
    uniqueCollections.addAll(anime.customCollections);
  }

  final list = uniqueCollections.toList();
  list.sort();
  return list;
});

typedef _OrderEntry = ({
  int id,
  String title,
  DateTime? date,
  double? progress
});

class _OrderEntries {
  const _OrderEntries(this.entries);
  final List<_OrderEntry> entries;

  @override
  bool operator ==(Object other) =>
      other is _OrderEntries &&
      const ListEquality<_OrderEntry>().equals(entries, other.entries);

  @override
  int get hashCode => const ListEquality<_OrderEntry>().hash(entries);
}

final _sortedAnimeIdsProvider = Provider<List<int>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final index = ref.watch(selectedSidebarIndexProvider);
  final selectedCollection = ref.watch(selectedCollectionProvider);
  final sort = ref.watch(libraryViewProvider).sort;
  bool matches(Anime anime) {
    if (query.isNotEmpty && !anime.title.toLowerCase().contains(query)) {
      return false;
    }

    switch (index) {
      case 1:
        return anime.status == AnimeStatus.watching;
      case 2:
        return anime.status == AnimeStatus.planned;
      case 3:
        return anime.status == AnimeStatus.completed;
      case 4:
        return anime.status == AnimeStatus.dropped;
      case 5:
        if (selectedCollection == null) return false;
        return anime.customCollections.contains(selectedCollection);
      case 0:
      default:
        return true;
    }
  }

  final entries = ref.watch(libraryProvider.select((library) => _OrderEntries([
        for (final anime in library.value ?? <Anime>[])
          if (matches(anime))
            (
              id: anime.id,
              title: anime.title,
              date: switch (sort) {
                LibrarySort.dateAdded => anime.dateAdded,
                LibrarySort.lastWatched => anime.lastWatchedAt,
                _ => null,
              },
              progress:
                  sort == LibrarySort.progress ? anime.watchProgress : null,
            ),
      ])));
  final result = entries.entries.toList();
  final epoch = DateTime(1970);
  result.sort((a, b) {
    final comparison = switch (sort) {
      LibrarySort.title =>
        a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      LibrarySort.dateAdded ||
      LibrarySort.lastWatched =>
        (b.date ?? epoch).compareTo(a.date ?? epoch),
      LibrarySort.progress => b.progress!.compareTo(a.progress!),
    };
    return comparison == 0 ? a.title.compareTo(b.title) : comparison;
  });
  return [for (final entry in result) entry.id];
});

final filteredAnimeProvider = Provider<List<Anime>>((ref) {
  final allAnime = ref.watch(libraryProvider).value ?? [];
  final ids = ref.watch(_sortedAnimeIdsProvider);
  final byId = {for (final anime in allAnime) anime.id: anime};
  return [
    for (final id in ids)
      if (byId[id] case final Anime anime) anime
  ];
});

final continueWatchingProvider = Provider<List<Anime>>((ref) {
  final allAnime = ref.watch(libraryProvider).value ?? [];
  final epoch = DateTime(1970);
  return allAnime
      .where((anime) =>
          anime.episodePaths.isNotEmpty &&
          (anime.lastWatchedAt != null ||
              anime.watchedEpisodes.isNotEmpty ||
              anime.playbackPositions
                  .any((entry) => (entry.position ?? 0) > 0)) &&
          anime.watchProgress < 1)
      .toList()
    ..sort((a, b) =>
        (b.lastWatchedAt ?? epoch).compareTo(a.lastWatchedAt ?? epoch));
});

final animeDetailsProvider =
    StreamProvider.autoDispose.family<Anime?, int>((ref, id) {
  final repo = ref.watch(animeRepoProvider);
  return repo.watchAnimeById(id);
});

final scannerProvider = Provider<FileDiscoveryService>((ref) {
  final repo = ref.watch(animeRepoProvider);
  return FileDiscoveryService(repo);
});

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

enum LibrarySort { title, dateAdded, lastWatched, progress }

class LibraryView {
  const LibraryView({this.sort = LibrarySort.title, this.list = false});
  final LibrarySort sort;
  final bool list;
}

final libraryViewProvider =
    StateNotifierProvider<LibraryViewController, LibraryView>(
        (ref) => LibraryViewController(ref.watch(sharedPrefsProvider)));

class LibraryViewController extends StateNotifier<LibraryView> {
  LibraryViewController(this.prefs)
      : super(LibraryView(
          sort: LibrarySort.values
                  .where((s) => s.name == prefs.getString('library_sort'))
                  .firstOrNull ??
              LibrarySort.title,
          list: prefs.getBool('library_list') ?? false,
        ));
  final SharedPreferences prefs;
  void sortBy(LibrarySort value) {
    state = LibraryView(sort: value, list: state.list);
    prefs.setString('library_sort', value.name);
  }

  void showList(bool value) {
    state = LibraryView(sort: state.sort, list: value);
    prefs.setBool('library_list', value);
  }
}

final librarySearchFocusProvider = Provider.autoDispose<FocusNode>((ref) {
  final focus = FocusNode();
  ref.onDispose(focus.dispose);
  return focus;
});
