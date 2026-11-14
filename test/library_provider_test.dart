import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountingAnime extends Anime {
  int progressReads = 0;

  @override
  double get watchProgress {
    progressReads++;
    return super.watchProgress;
  }
}

void main() {
  test('progress sorting calculates progress once per filtered anime',
      () async {
    SharedPreferences.setMockInitialValues({'library_sort': 'progress'});
    final prefs = await SharedPreferences.getInstance();
    final animes = List.generate(20, (index) {
      return CountingAnime()
        ..id = index + 1
        ..title = 'Anime $index'
        ..episodePaths = ['1', '2']
        ..watchedEpisodes = index.isEven ? ['1'] : [];
    });
    final container = ProviderContainer(overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      libraryProvider.overrideWith((ref) => Stream.value(animes)),
    ]);
    addTearDown(container.dispose);
    await container.read(libraryProvider.future);
    final result = container.read(filteredAnimeProvider);
    expect(
        result
            .take(10)
            .every((anime) => int.parse(anime.title.split(' ').last).isEven),
        isTrue);
    expect(animes.map((anime) => anime.progressReads), everyElement(1));
  });

  test(
      'position updates expose fresh records and sorting tracks relevant changes',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final stream = StreamController<List<Anime>>();
    final container = ProviderContainer(overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      libraryProvider.overrideWith((ref) => stream.stream),
    ]);
    addTearDown(() async {
      container.dispose();
      await stream.close();
    });
    final subscription = container.listen(filteredAnimeProvider, (_, __) {});
    addTearDown(subscription.close);
    Anime record(int id, String title, int position) => Anime()
      ..id = id
      ..title = title
      ..playbackPositions = [PlaybackEntry()..position = position];

    stream.add([record(1, 'Alpha', 0), record(2, 'Beta', 0)]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(filteredAnimeProvider).map((a) => a.title),
        ['Alpha', 'Beta']);
    stream.add([record(1, 'Alpha', 42), record(2, 'Beta', 0)]);
    await Future<void>.delayed(Duration.zero);
    expect(
        container
            .read(filteredAnimeProvider)
            .first
            .playbackPositions
            .single
            .position,
        42);
    stream.add([record(1, 'Zulu', 42), record(2, 'Beta', 0)]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(filteredAnimeProvider).map((a) => a.title),
        ['Beta', 'Zulu']);
    container.read(searchQueryProvider.notifier).state = 'zulu';
    expect(container.read(filteredAnimeProvider).single.title, 'Zulu');
  });
}
