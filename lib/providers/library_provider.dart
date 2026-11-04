import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final allAnime = ref.watch(libraryProvider).value ??[];
  final Set<String> uniqueCollections = {};
  
  for (var anime in allAnime) {
    uniqueCollections.addAll(anime.customCollections);
  }
  
  final list = uniqueCollections.toList();
  list.sort();
  return list;
});

final filteredAnimeProvider = Provider<List<Anime>>((ref) {
  final allAnime = ref.watch(libraryProvider).value ??[];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final index = ref.watch(selectedSidebarIndexProvider);
  final selectedCollection = ref.watch(selectedCollectionProvider);

  return allAnime.where((anime) {
    if (query.isNotEmpty && !anime.title.toLowerCase().contains(query)) {
      return false;
    }

    switch (index) {
      case 1: return anime.status == AnimeStatus.watching;
      case 2: return anime.status == AnimeStatus.planned;
      case 3: return anime.status == AnimeStatus.completed;
      case 4: return anime.status == AnimeStatus.dropped;
      case 5:
        if (selectedCollection == null) return false;
        return anime.customCollections.contains(selectedCollection);
      case 0: 
      default:
        return true;
    }
  }).toList();
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