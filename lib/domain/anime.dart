import 'package:isar_community/isar.dart';
import 'package:collection/collection.dart';
part 'anime.g.dart';

enum AnimeStatus { planned, watching, completed, dropped }

@collection
class Anime {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String title;
  int? shikimoriId;
  String? scanTitle;
  List<String> sourceFolders = [];
  DateTime? lastWatchedAt;

  String? folderPath;
  String? coverUrl;
  String? descripion;

  int? ambientColorValue;
  DateTime dateAdded = DateTime.now();

  List<String> episodePaths = [];
  List<String> watchedEpisodes = [];
  List<EpisodeNote> notes = [];
  List<PlaybackEntry> playbackPositions = [];
  @enumerated
  AnimeStatus status = AnimeStatus.planned;
  bool isHidden = false;
  List<String> customCollections = [];
  List<EpisodeSkipData> skipData = [];

  @ignore
  List<String> get sortedEpisodes {
    return List.from(episodePaths)..sort(compareNatural);
  }

  @ignore
  double get watchProgress {
    if (episodePaths.isEmpty) return 0.0;
    return episodePaths.toSet().intersection(watchedEpisodes.toSet()).length /
        episodePaths.toSet().length;
  }

  @ignore
  String? get nextEpisodeToPlay {
    final sorted = sortedEpisodes;
    for (var ep in sorted) {
      if (!watchedEpisodes.contains(ep)) {
        return ep;
      }
    }
    return null;
  }

  @ignore
  String get progressPercentage {
    if (episodePaths.isEmpty) return "0%";
    final percent = (watchProgress * 100).toInt();
    return "$percent%";
  }

  @ignore
  String get progressFraction {
    return "${episodePaths.toSet().intersection(watchedEpisodes.toSet()).length} / ${episodePaths.toSet().length}";
  }
}

@embedded
class EpisodeNote {
  String? episodePath;
  int? timestampSeconds;
  String? text;
  DateTime? createdAt;
}

@embedded
class PlaybackEntry {
  String? path;
  int? position;
}

@embedded
class EpisodeSkipData {
  String? episodePath;
  List<SkipIntervalDb> intervals = [];
}

@embedded
class SkipIntervalDb {
  String? type; // "op" or "ed".
  double? startTime;
  double? endTime;
}
