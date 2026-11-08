import 'dart:io';
import 'package:isar/isar.dart';
import '../../domain/anime.dart';
import 'playback_progress_store.dart';

class DuplicateAnimeTitle implements Exception {
  const DuplicateAnimeTitle(this.title);
  final String title;
  @override
  String toString() => 'A title named "$title" already exists.';
}

class AnimeRepository implements PlaybackProgressStore {
  AnimeRepository(this.db);
  final Isar db;

  Stream<List<Anime>> watchLibrary() => db.animes
      .filter()
      .isHiddenEqualTo(false)
      .sortByTitle()
      .watch(fireImmediately: true);
  Stream<Anime?> watchAnimeById(Id id) =>
      db.animes.watchObject(id, fireImmediately: true);
  Future<Anime?> getAnimeByTitle(String title) =>
      db.animes.filter().titleEqualTo(title).findFirst();
  Future<Anime?> getAnimeById(int id) => db.animes.get(id);

  /// Always re-read inside the transaction. Presentation snapshots are never
  /// written back over progress, notes or other concurrently updated fields.
  Future<void> _update(Id id, void Function(Anime anime) change) =>
      db.writeTxn(() async {
        final anime = await db.animes.get(id);
        if (anime == null) return;
        change(anime);
        await db.animes.put(anime);
      });

  Future<void> updateStatus(Id id, AnimeStatus status) =>
      _update(id, (anime) => anime.status = status);
  @override
  Future<void> markEpisodeAsWatched(Id id, String path) => _update(id, (anime) {
        if (!anime.episodePaths.contains(path)) return;
        anime.watchedEpisodes = {...anime.watchedEpisodes, path}.toList();
        anime.lastWatchedAt = DateTime.now();
      });
  Future<void> markAllEpisodesWatched(Id id) => _update(id, (anime) {
        anime.watchedEpisodes =
            {...anime.watchedEpisodes, ...anime.sortedEpisodes}.toList();
      });
  Future<void> markEpisodeUnwatched(Id id, String path) => _update(id, (anime) {
        anime.watchedEpisodes =
            anime.watchedEpisodes.where((item) => item != path).toList();
      });
  @override
  Future<void> savePlaybackPosition(Id id, String path, int seconds) =>
      _update(id, (anime) {
        anime.playbackPositions = [
          ...anime.playbackPositions.where((entry) => entry.path != path),
          PlaybackEntry()
            ..path = path
            ..position = seconds,
        ];
        if (seconds > 0) anime.lastWatchedAt = DateTime.now();
      });

  Future<void> editAnimeDetails(Anime snapshot, String title, String cover) =>
      db.writeTxn(() async {
        final trimmed = title.trim();
        if (trimmed.isEmpty) throw ArgumentError('Title must not be empty.');
        final existing =
            await db.animes.filter().titleEqualTo(trimmed).findFirst();
        if (existing != null && existing.id != snapshot.id) {
          throw DuplicateAnimeTitle(trimmed);
        }
        final anime = await db.animes.get(snapshot.id);
        if (anime == null) return;
        anime.scanTitle ??= anime.title;
        anime.title = trimmed;
        if (anime.coverUrl != cover) anime.ambientColorValue = null;
        anime.coverUrl = cover.isEmpty ? null : cover;
        await db.animes.put(anime);
      });
  Future<void> updateMetadata(Id id,
          {String? coverUrl, String? description, int? shikimoriId}) =>
      _update(id, (anime) {
        if (coverUrl != null && anime.coverUrl != coverUrl) {
          anime.coverUrl = coverUrl;
          anime.ambientColorValue = null;
        }
        if (description != null) anime.descripion = description;
        if (shikimoriId != null) anime.shikimoriId = shikimoriId;
      });
  Future<void> updateAmbientColor(Id id, String? expectedCover, int color) =>
      _update(id, (anime) {
        if (anime.coverUrl == expectedCover) anime.ambientColorValue = color;
      });
  Future<void> cacheSkipData(Id id, EpisodeSkipData data) =>
      _update(id, (anime) {
        anime.skipData = [
          ...anime.skipData
              .where((entry) => entry.episodePath != data.episodePath),
          data
        ];
      });
  Future<void> addToCollection(Id id, String name) => _update(id, (anime) {
        anime.customCollections = {...anime.customCollections, name.trim()}
            .where((s) => s.isNotEmpty)
            .toList();
      });
  Future<void> addNote(Id id, String path, int seconds, String text) =>
      _update(id, (anime) {
        anime.notes = [
          ...anime.notes,
          EpisodeNote()
            ..episodePath = path
            ..timestampSeconds = seconds
            ..text = text
            ..createdAt = DateTime.now()
        ];
      });
  Future<void> deleteNote(Id id, DateTime createdAt) => _update(id, (anime) {
        anime.notes =
            anime.notes.where((n) => n.createdAt != createdAt).toList();
      });
  Future<void> clearAll() => db.writeTxn(() async {
        await db.animes.clear();
      });
  // A hidden record keeps import identity, so an automatic rescan does not undo removal.
  Future<void> deleteAnime(Id id) =>
      _update(id, (anime) => anime.isHidden = true);

  /// Only creates new records. Existing models must use the field-level APIs.
  Future<void> saveAnime(Anime anime) => db.writeTxn(() async {
        if (await db.animes.get(anime.id) != null) {
          throw StateError('Use an atomic field update for an existing anime.');
        }
        await db.animes.put(anime);
      });

  static String normalizeRoot(String path) {
    final normalized =
        Directory(path).absolute.uri.normalizePath().toFilePath();
    return normalized == Platform.pathSeparator ||
            RegExp(r'^[A-Za-z]:[/\\]$').hasMatch(normalized)
        ? normalized
        : normalized.replaceFirst(RegExp(r'[/\\]+$'), '');
  }

  static bool _under(String file, String root) {
    final path = File(file).absolute.uri.normalizePath().toFilePath();
    final prefix = root.endsWith(Platform.pathSeparator)
        ? root
        : '$root${Platform.pathSeparator}';
    return Platform.isWindows
        ? path.toLowerCase().startsWith(prefix.toLowerCase())
        : path.startsWith(prefix);
  }

  /// Replaces only this source's episode paths, preserving every other source
  /// and all user-owned data. Also reconciles titles removed from this root.
  Future<List<Anime>> reconcileScan(
          String folder, Map<String, List<String>> grouped) =>
      db.writeTxn(() async {
        final root = normalizeRoot(folder);
        final records = await db.animes.where().findAll();
        final remaining = Map<String, List<String>>.from(grouped);
        final affected = <Anime>[];
        for (final anime in records) {
          final key = anime.scanTitle ?? anime.title;
          final found = remaining[key];
          final belongs = anime.sourceFolders.contains(root) ||
              (anime.folderPath != null &&
                  normalizeRoot(anime.folderPath!) == root) ||
              anime.episodePaths.any((path) => _under(path, root));
          if (found == null && !belongs) continue;
          remaining.remove(key);
          anime.scanTitle ??= key;
          anime.sourceFolders = {
            ...anime.sourceFolders,
            if (anime.folderPath != null) normalizeRoot(anime.folderPath!),
            root
          }.toList();
          anime.folderPath ??= root;
          anime.episodePaths = {
            ...anime.episodePaths.where((path) => !_under(path, root)),
            ...?found
          }.toList();
          await db.animes.put(anime);
          affected.add(anime);
        }
        for (final entry in remaining.entries) {
          final anime = Anime()
            ..title = entry.key
            ..scanTitle = entry.key
            ..folderPath = root
            ..sourceFolders = [root]
            ..episodePaths = entry.value;
          await db.animes.put(anime);
          affected.add(anime);
        }
        return affected;
      });
}
