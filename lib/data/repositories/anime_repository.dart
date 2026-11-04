import 'package:isar/isar.dart';
import '../../domain/anime.dart';
import '../../core/logger.dart'; 
import 'playback_progress_store.dart';

class AnimeRepository implements PlaybackProgressStore {
  final Isar db;
  AnimeRepository(this.db);


  Stream<List<Anime>> watchLibrary() {
    return db.animes
        .filter()
        .isHiddenEqualTo(false)
        .sortByTitle()
        .watch(fireImmediately: true);
  }

  Stream<Anime?> watchAnimeById(Id id) {
    return db.animes.watchObject(id, fireImmediately: true);
  }


  Future<void> addScannedAnime (List<Anime> newAnimes) async {
    try{
      if (newAnimes.isEmpty) return;

      await db.writeTxn(() async{
        await db.animes.putAll(newAnimes);  
      });
    } catch (e,st) {
      talker.handle(e,st,'Failed to add scanned anime');
    }
  }

  
  Future<void> updateStatus(Id id, AnimeStatus newStasus) async {
    try {
      await db.writeTxn(() async {
        final anime = await db.animes.get(id);
        if (anime != null) {
          anime.status = newStasus;
          await db.animes.put(anime);
          talker.info('Anime status updated');
        }
      });
    } catch (e,st) {
      talker.handle(e,st,'Failed to update anime status');
    }
  }

  @override
  Future<void> markEpisodeAsWatched (Id id, String episodePath) async {
    try{
      await db.writeTxn(() async{
        final anime = await db.animes.get(id);
        if (anime!=null) {
          final uniqueEpisodes = {...anime.watchedEpisodes, episodePath}.toList();
          anime.watchedEpisodes = uniqueEpisodes;
          await db.animes.put(anime);
          talker.info('Episode marked as watched in "${anime.title}"');
        }
      });
    }catch(e,st) {
      talker.handle(e,st,'Failed to mark anime as watched');
    }
  }

  Future<void> markAllEpisodesWatched(Id id) async {
    try {
      await db.writeTxn(() async {
        final anime = await db.animes.get(id);
        if (anime == null) return;

        final unwatchedEpisodes = anime.sortedEpisodes
            .where((path) => !anime.watchedEpisodes.contains(path));
        if (unwatchedEpisodes.isEmpty) return;

        anime.watchedEpisodes = {
          ...anime.watchedEpisodes,
          ...unwatchedEpisodes,
        }.toList();
        await db.animes.put(anime);
        talker.info('All episodes marked as watched in "${anime.title}"');
      });
    } catch (e, st) {
      talker.handle(e, st, 'Failed to mark all episodes as watched');
    }
  }

  Future<Anime?> getAnimeByTitle(String title) async {
    try {
      return await db.animes.filter().titleEqualTo(title).findFirst();
    } catch (e,st) {
      talker.handle(e,st,'Failed to get anime by title');
      return null;
    }
  }

  Future<Anime?> getAnimeById(int id) async {
    return await db.animes.get(id);
  }

  @override
  Future<void> savePlaybackPosition(int id, String path, int seconds) async {
    try {
      await db.writeTxn(() async {
        final anime = await db.animes.get(id);
        if (anime != null) {
          final updatedList = List<PlaybackEntry>.from(anime.playbackPositions);
          // Isar detects list changes only when the list instance is replaced.
          final index = updatedList.indexWhere((e) => e.path == path);
          if (index != -1) {
            updatedList[index].position = seconds;
          } else {
            updatedList.add(
              PlaybackEntry()
                ..path = path
                ..position = seconds,
            );
          }
          anime.playbackPositions = updatedList;
          await db.animes.put(anime);
        }
      });
    } catch (e, st) {
      talker.handle(e, st, 'Failed to save video position');
    }
  }

    Future<void> editAnimeDetails(Anime anime, String newTitle, String newCoverUrl) async {
    await db.writeTxn(() async {
      anime.title = newTitle;
      
      // An empty cover URL clears the stored value.
      anime.coverUrl = newCoverUrl.isNotEmpty ? newCoverUrl : null;
      
      await db.animes.put(anime);
    });
  }

  Future<void> addNote(Id id, String epPath, int seconds, String text) async {
    try {
      await db.writeTxn(() async {
        final anime = await db.animes.get(id);
        if (anime == null) return;

        final note = EpisodeNote()
          ..episodePath = epPath
          ..timestampSeconds = seconds
          ..text = text
          ..createdAt = DateTime.now();

        anime.notes = [...anime.notes, note];
        await db.animes.put(anime);
        talker.info('Note added to "${anime.title}" at $seconds s.');
      });
    } catch (e, st) {
      talker.handle(e, st, 'Failed to save note');
    }
  }
  
  Future <void> deleteNote(Id id, DateTime createdAt) async {
    try {
      await db.writeTxn(() async {
        final anime = await db.animes.get(id);
        if (anime == null) return;

        final updateNotes = anime.notes.where((n) => n.createdAt != createdAt).toList();

        anime.notes = updateNotes;
        await db.animes.put(anime);
        talker.info('Note deleted from "${anime.title}"');
      });
    } catch (e, st) {
      talker.handle(e, st, 'Failed to delete note');
    }
  }

  Future<void> clearAll() async {
    await db.writeTxn(() => db.animes.clear());
    talker.warning('DATABASE WAS CLEARED');
  }

  Future<void> saveAnime(Anime anime) async{
    await db.writeTxn(() async{
      await db.animes.put(anime);
    });
  }

  Future<void> deleteAnime(Id id) async {
    try{
      await db.writeTxn(() async{
        db.animes.delete(id);
      });
    }catch(e, st) {
      talker.handle(e,st, 'Failed to delete anime by ID');
    }
  }

}
