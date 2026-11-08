import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import '../repositories/anime_repository.dart';
import 'anime_filename_parser.dart';
import 'shikimori_service.dart';

class ScanResult {
  const ScanResult(
      {this.titles = 0,
      this.files = 0,
      this.warnings = const [],
      this.cancelled = false});
  final int titles;
  final int files;
  final List<String> warnings;
  final bool cancelled;
}

typedef MetadataLookup = Future<Map<String, String>?> Function(String title);

class FileDiscoveryService {
  FileDiscoveryService(this._repository, {MetadataLookup? metadataLookup})
      : _lookup = metadataLookup ?? ShikimoriService().fetchAnimeDetails;
  final AnimeRepository _repository;
  final MetadataLookup _lookup;

  Future<ScanResult> scanAndGroupFiles(String folderPath,
      {bool Function()? isCancelled}) async {
    final root = AnimeRepository.normalizeRoot(folderPath);
    // Exceptions intentionally reach the scan controller instead of looking like success.
    final grouped = await Isolate.run(() => _scanDirectory(root))
        .timeout(const Duration(minutes: 2));
    if (isCancelled?.call() == true) return const ScanResult(cancelled: true);
    // Import local media before any network request. Progress and notes are
    // preserved by transactional field updates in the repository.
    final affected = await _repository.reconcileScan(root, grouped);
    final warnings = <String>[];
    for (final anime in affected) {
      if (isCancelled?.call() == true) {
        return ScanResult(
            titles: grouped.length,
            files: grouped.values.fold(0, (n, paths) => n + paths.length),
            warnings: warnings,
            cancelled: true);
      }
      if (anime.isHidden ||
          anime.episodePaths.isEmpty ||
          anime.shikimoriId != null) {
        continue;
      }
      try {
        final metadata = await _lookup(anime.scanTitle ?? anime.title)
            .timeout(const Duration(seconds: 18));
        if (isCancelled?.call() == true) break;
        if (metadata == null) {
          warnings.add(anime.title);
        } else {
          await _repository.updateMetadata(
            anime.id,
            coverUrl: metadata['coverUrl'],
            description: metadata['description'],
            shikimoriId: int.tryParse(metadata['shikimoriId'] ?? ''),
          );
        }
      } catch (_) {
        warnings.add(anime.title);
      }
    }
    return ScanResult(
        titles: grouped.length,
        files: grouped.values.fold(0, (n, paths) => n + paths.length),
        warnings: warnings,
        cancelled: isCancelled?.call() == true);
  }

  static Map<String, List<String>> _scanDirectory(String root) {
    final directory = Directory(root);
    if (!directory.existsSync()) {
      throw FileSystemException('Library folder is unavailable', root);
    }
    final grouped = <String, List<String>>{};
    for (final entity
        in directory.listSync(recursive: true, followLinks: false)) {
      if (entity is! File ||
          !RegExp(r'\.(mkv|mp4|avi)$', caseSensitive: false)
              .hasMatch(entity.path)) {
        continue;
      }
      final title =
          AnimeFilenameParser.parseTitle(entity.uri.pathSegments.last);
      if (title.isNotEmpty) {
        grouped.putIfAbsent(title, () => []).add(entity.path);
      }
    }
    return grouped;
  }
}
