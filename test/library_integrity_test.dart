import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/data/services/file_discovery_service.dart';
import 'package:nekaido_pre/domain/anime.dart';

void main() {
  late Directory dir;
  late Isar db;
  late AnimeRepository repo;
  setUpAll(_initializeIsarCore);
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hialyth-integrity-');
    db = await Isar.open([AnimeSchema], directory: dir.path, inspector: false);
    repo = AnimeRepository(db);
  });
  tearDown(() async {
    await db.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });

  test('duplicate rename preserves both records and their notes', () async {
    final a = Anime()..title = 'A';
    final b = Anime()
      ..title = 'B'
      ..notes = [EpisodeNote()..text = 'Keep me'];
    await repo.saveAnime(a);
    await repo.saveAnime(b);
    await expectLater(
        repo.editAnimeDetails(a, 'B', ''), throwsA(isA<DuplicateAnimeTitle>()));
    expect(await db.animes.count(), 2);
    expect((await repo.getAnimeById(b.id))!.notes.single.text, 'Keep me');
  });
  test('stale metadata and edit operations preserve fresh progress', () async {
    final a = Anime()
      ..title = 'A'
      ..episodePaths = ['/ep1.mkv'];
    await repo.saveAnime(a);
    final stale = (await repo.getAnimeById(a.id))!;
    await repo.markEpisodeAsWatched(a.id, '/ep1.mkv');
    await repo.updateMetadata(a.id, coverUrl: 'poster', shikimoriId: 42);
    await repo.editAnimeDetails(stale, 'Renamed', 'poster');
    expect((await repo.getAnimeById(a.id))!.watchedEpisodes, ['/ep1.mkv']);
    await expectLater(repo.saveAnime(stale), throwsStateError);
  });
  test(
      'reconcile preserves other folders, removes vanished files, and respects hiding',
      () async {
    final one = await Directory('${dir.path}/one').create();
    final two = await Directory('${dir.path}/two').create();
    final first = await File('${one.path}/Example - 01.MKV').create();
    final second = await File('${two.path}/Example - 02.mkv').create();
    final scanner = FileDiscoveryService(repo,
        metadataLookup: (_) async => {'shikimoriId': '42'});
    await scanner.scanAndGroupFiles(one.path);
    await scanner.scanAndGroupFiles(two.path);
    final anime = (await repo.getAnimeByTitle('Example'))!;
    expect(anime.episodePaths.toSet(), {first.path, second.path});
    expect(anime.shikimoriId, 42);
    await first.delete();
    await scanner.scanAndGroupFiles(one.path);
    expect((await repo.getAnimeById(anime.id))!.episodePaths, [second.path]);
    await repo.deleteAnime(anime.id);
    await scanner.scanAndGroupFiles(two.path);
    expect((await repo.getAnimeById(anime.id))!.isHidden, isTrue);
  });
  test('missing source reports an error and preserves current library',
      () async {
    final a = Anime()
      ..title = 'A'
      ..episodePaths = ['/keep.mkv'];
    await repo.saveAnime(a);
    await expectLater(
        FileDiscoveryService(repo).scanAndGroupFiles('${dir.path}/missing'),
        throwsA(isA<FileSystemException>()));
    expect((await repo.getAnimeById(a.id))!.episodePaths, ['/keep.mkv']);
  });
  test('progress counts only current unique episodes', () {
    final a = Anime()
      ..title = 'A'
      ..episodePaths = ['a', 'b']
      ..watchedEpisodes = ['a', 'old', 'old2'];
    expect(a.watchProgress, .5);
    expect(a.progressFraction, '1 / 2');
  });
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
