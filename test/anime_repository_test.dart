import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/domain/anime.dart';

void main() {
  late Directory databaseDirectory;
  late Isar isar;
  late AnimeRepository repository;

  setUpAll(_initializeIsarCore);

  setUp(() async {
    databaseDirectory =
        await Directory.systemTemp.createTemp('nekaido_anime_repository_');
    isar = await Isar.open(
      [AnimeSchema],
      directory: databaseDirectory.path,
      inspector: false,
    );
    repository = AnimeRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await databaseDirectory.delete(recursive: true);
  });

  test('persists anime without evaluating derived episode getters', () async {
    final anime = _AnimeWithGuardedGetters()
      ..title = 'Derived properties'
      ..episodePaths = ['/anime/10.mkv', '/anime/2.mkv', '/anime/1.mkv']
      ..watchedEpisodes = ['/anime/1.mkv'];

    expect(
      AnimeSchema.properties.keys,
      isNot(contains(anyOf('sortedEpisodes', 'nextEpisodeToPlay',
          'watchProgress', 'progressFraction', 'progressPercentage'))),
    );
    await repository.saveAnime(anime);

    final saved = await repository.getAnimeById(anime.id);
    expect(saved?.episodePaths, anime.episodePaths);
    expect(saved?.watchedEpisodes, anime.watchedEpisodes);
    expect(saved?.nextEpisodeToPlay, '/anime/2.mkv');
    expect(saved?.progressFraction, '1 / 3');
  });

  test(
      'marks all episodes watched in natural order and preserves existing ones',
      () async {
    final anime = Anime()
      ..title = 'Repository test'
      ..episodePaths = ['/anime/10.mkv', '/anime/2.mkv', '/anime/1.mkv']
      ..watchedEpisodes = ['/anime/2.mkv'];
    await repository.saveAnime(anime);

    await repository.markAllEpisodesWatched(anime.id);

    final savedAnime = await repository.getAnimeById(anime.id);
    expect(
      savedAnime?.watchedEpisodes,
      ['/anime/2.mkv', '/anime/1.mkv', '/anime/10.mkv'],
    );
  });

  test('is idempotent when all episodes are already watched', () async {
    final anime = Anime()
      ..title = 'Already watched'
      ..episodePaths = ['/anime/1.mkv', '/anime/2.mkv']
      ..watchedEpisodes = ['/anime/2.mkv', '/anime/1.mkv'];
    await repository.saveAnime(anime);

    await repository.markAllEpisodesWatched(anime.id);

    final savedAnime = await repository.getAnimeById(anime.id);
    expect(savedAnime?.watchedEpisodes, ['/anime/2.mkv', '/anime/1.mkv']);
  });

  test('does nothing when the anime id does not exist', () async {
    await expectLater(repository.markAllEpisodesWatched(999), completes);
  });

  test('unchanged rescan preserves records and does not notify watchers',
      () async {
    final root = databaseDirectory.path;
    final one = '$root/one.mkv';
    final two = '$root/two.mkv';
    final anime = (await repository.reconcileScan(root, {
      'Example': [one, two]
    }))
        .single;
    await repository.addNote(anime.id, one, 5, 'keep');
    var notifications = 0;
    final subscription = isar.animes.watchObject(anime.id).listen((_) {
      notifications++;
    });
    addTearDown(subscription.cancel);
    final affected = await repository.reconcileScan(root, {
      'Example': [two, one]
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(notifications, 0);
    expect(affected.single.notes.single.text, 'keep');
    expect(affected.single.episodePaths, [one, two]);

    await repository.reconcileScan(root, {
      'Example': [two]
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(notifications, 1);
    final updated = await repository.getAnimeById(anime.id);
    expect(updated!.episodePaths, [two]);
    expect(updated.notes.single.text, 'keep');
  });
}

class _AnimeWithGuardedGetters extends Anime {
  Never _unexpectedGetter() => throw StateError('Derived getter was persisted');

  @override
  List<String> get sortedEpisodes => _unexpectedGetter();
  @override
  String? get nextEpisodeToPlay => _unexpectedGetter();
  @override
  double get watchProgress => _unexpectedGetter();
  @override
  String get progressFraction => _unexpectedGetter();
  @override
  String get progressPercentage => _unexpectedGetter();
}

Future<void> _initializeIsarCore() async {
  final packageConfigFile = File(
    Platform.packageConfig ??
        '${Directory.current.path}/.dart_tool/package_config.json',
  );
  final packageConfig =
      jsonDecode(await packageConfigFile.readAsString()) as Map;
  final packages = packageConfig['packages'] as List;
  final isarFlutterLibs = packages.cast<Map>().firstWhere(
        (package) => package['name'] == 'isar_community_flutter_libs',
      );
  final packageRoot =
      Directory.fromUri(Uri.parse(isarFlutterLibs['rootUri'] as String));
  final libraryRelativePath = switch (Abi.current()) {
    Abi.linuxX64 || Abi.linuxArm64 => 'linux/libisar.so',
    Abi.macosX64 || Abi.macosArm64 => 'macos/libisar.dylib',
    Abi.windowsX64 || Abi.windowsArm64 => 'windows/isar.dll',
    _ => throw UnsupportedError('Isar tests do not support ${Abi.current()}.'),
  };

  await Isar.initializeIsarCore(
    libraries: {
      Abi.current():
          '${packageRoot.path}${Platform.pathSeparator}$libraryRelativePath',
    },
  );
}
