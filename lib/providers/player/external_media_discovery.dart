import 'dart:async';
import 'dart:io';

class ExternalMedia {
  const ExternalMedia(this.audioDirs, this.subDirs, this.fontsDir, this.subs);

  final List<String> audioDirs;
  final List<String> subDirs;
  final String? fontsDir;
  final Map<String, List<String>> subs;
}

/// Reuses a recent complete scan for episodes in the same directory.
class ExternalMediaDiscovery {
  ExternalMediaDiscovery({
    this.cacheDuration = const Duration(seconds: 30),
    this.timeout = const Duration(seconds: 5),
    Stream<FileSystemEntity> Function(Directory)? listDirectory,
  }) : _listDirectory = listDirectory ??
            ((directory) =>
                directory.list(recursive: true, followLinks: false));

  final Duration cacheDuration;
  final Duration timeout;
  final Stream<FileSystemEntity> Function(Directory) _listDirectory;
  String? _cachedDirectory;
  DateTime? _cachedAt;
  ExternalMedia? _cached;

  Future<ExternalMedia> discover(String videoPath) async {
    final directory = File(videoPath).parent;
    final now = DateTime.now();
    if (_cachedDirectory == directory.path &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < cacheDuration) {
      return _cached!;
    }

    final iterator =
        StreamIterator<FileSystemEntity>(_listDirectory(directory));
    final audioDirs = <String>{};
    final subDirs = <String>{};
    final subs = <String, List<String>>{};
    String? fontsDir;

    Future<void> scan() async {
      while (await iterator.moveNext()) {
        final entity = iterator.current;
        final lower = entity.path.toLowerCase();
        if (entity is File) {
          if (lower.endsWith('.mka') ||
              lower.endsWith('.m4a') ||
              lower.endsWith('.ac3') ||
              lower.endsWith('.flac')) {
            audioDirs.add(entity.parent.path);
          } else if (lower.endsWith('.ass') || lower.endsWith('.srt')) {
            subDirs.add(entity.parent.path);
            final parts = entity.parent.path.replaceAll('\\', '/').split('/');
            var folderName = parts.last;
            if (parts.length > 1 &&
                (folderName.toLowerCase() == 'надписи' ||
                    folderName.toLowerCase() == 'signs')) {
              folderName = '${parts[parts.length - 2]} $folderName';
            }
            subs
                .putIfAbsent(entity.uri.pathSegments.last, () => [])
                .add(folderName);
          }
        } else if (entity is Directory &&
            (lower.endsWith('fonts') || lower.endsWith('шрифты'))) {
          fontsDir = entity.path;
        }
      }
    }

    try {
      await scan().timeout(timeout);
    } finally {
      await iterator.cancel();
    }

    final result = ExternalMedia(
        audioDirs.toList()..sort(), subDirs.toList()..sort(), fontsDir, subs);
    _cachedDirectory = directory.path;
    _cachedAt = DateTime.now();
    _cached = result;
    return result;
  }
}
