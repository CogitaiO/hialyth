import 'dart:async';
import 'dart:io';
import 'dart:isolate'; 
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/data/services/anime_filename_parser.dart';
import 'package:nekaido_pre/data/services/shikimori_service.dart';
import 'package:nekaido_pre/domain/anime.dart';
import '../../core/logger.dart'; 


class FileDiscoveryService {
  final AnimeRepository _repository;
  FileDiscoveryService(this._repository);

  Future<void> scanAndGroupFiles(String folderPath) async {
    try {
      final groupedAnime = await Isolate.run(() => _scanDirectoryIsolated(folderPath)).timeout(const Duration(minutes: 2));

      if (groupedAnime.isEmpty) return;

      List<Anime> animesToSave =[];
      final shikimori = ShikimoriService();

      for (var entry in groupedAnime.entries) {
        final title = entry.key;
        final episodes = entry.value;
        var anime = await _repository.getAnimeByTitle(title);
        
        if (anime != null) {
          anime.episodePaths = episodes;
          animesToSave.add(anime);
        } else {
          talker.info("Ищем данные в интернете для: $title...");

          final meta = await shikimori.fetchAnimeDetails(title);

          await Future.delayed(const Duration(seconds: 1));

          animesToSave.add(
            Anime()
              ..title = title
              ..folderPath = folderPath
              ..episodePaths = episodes
              ..coverUrl = meta?['coverUrl']
              ..descripion = meta?['description'] 
          );
        }
      }
      await _repository.addScannedAnime(animesToSave);
      talker.info("Сканирование и парсинг завершены!");
    }catch(e,st) {
      if (e is TimeoutException) {
        talker.error("Сканирование отменено: папка слишком большая");
      } else {
        talker.handle(e, st, "Критическая ошибка сканирования");
      }
    }
  }

  static Map<String, List<String>> _scanDirectoryIsolated(String folderPath) {
    final directory = Directory(folderPath);
    if (!directory.existsSync()) return {};

    Map<String, List<String>> grouped = {};

    for (final entity in directory.listSync(recursive: true, followLinks: false)) {
      if (entity is File && _isVideoFile(entity.path)) {
        final fileName = entity.uri.pathSegments.last;
        final title = AnimeFilenameParser.parseTitle(fileName);
        
        grouped.putIfAbsent(title, () =>[]).add(entity.path);
      }
    }
    return grouped;
  }

  static bool _isVideoFile(String path) => path.endsWith('.mp4') || path.endsWith('.mkv') || path.endsWith('.avi');
}
