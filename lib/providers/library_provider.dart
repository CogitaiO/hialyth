import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
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

final filteredAnimeProvider = Provider<List<Anime>>((ref) {
  final allAnime = ref.watch(libraryProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final index = ref.watch(selectedSidebarIndexProvider);
  final selectedCollection = ref.watch(selectedCollectionProvider);

  final result = allAnime.where((anime) {
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
  }).toList();
  final sort = ref.watch(libraryViewProvider).sort;
  result.sort((a, b) {
    final comparison = switch (sort) {
      LibrarySort.title =>
        a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      LibrarySort.dateAdded => b.dateAdded.compareTo(a.dateAdded),
      LibrarySort.lastWatched => (b.lastWatchedAt ?? DateTime(1970))
          .compareTo(a.lastWatchedAt ?? DateTime(1970)),
      LibrarySort.progress => b.watchProgress.compareTo(a.watchProgress),
    };
    return comparison == 0 ? a.title.compareTo(b.title) : comparison;
  });
  return result;
});

final animeDetailsProvider = StreamProvider.family<Anime?, int>((ref, id) {
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
