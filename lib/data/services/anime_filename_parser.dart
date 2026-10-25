/// Parses anime titles and episode numbers from common release filenames.
class AnimeFilenameParser {
  static final _extensionRegex =
      RegExp(r'\.(mkv|mp4|avi)$', caseSensitive: false);
  static final _bracketsRegex = RegExp(r'\[.*?\]|\(.*?\)');
  static final _spacesRegex = RegExp(r'\s+');
  static final _episodeNumberRegex =
      RegExp(r'(?:\s|-|\[|[Ee]p\s*)(\d{1,4})(?:v\d+)?(?:\s|-|\]|\.)');
  static final _fallbackEpisodeNumberRegex = RegExp(r'(\d+)(?:v\d+)?\.\w+$');
  static const _ignoredVideoResolutions = {480, 720, 1080};

  static String parseTitle(String fileName) {
    var title = fileName.replaceAll(_extensionRegex, '');
    title = title.replaceAll(
      RegExp(r'\d{3,4}p|x264|x265|h264|h265|hevc|hi10p', caseSensitive: false),
      '',
    );
    title = title.replaceAll(RegExp(r'[_.]'), ' ');
    title = title.replaceAll(_bracketsRegex, '');
    title = title.replaceAll(_spacesRegex, ' ').trim();
    title = title.replaceAll(
      RegExp(r'\s+(?:ep|episode|серия)?\s?\d+(?:\s?v\d+)?$',
          caseSensitive: false),
      '',
    );

    if (title.endsWith(' -')) title = title.substring(0, title.length - 2);

    return title.trim();
  }

  /// Returns a likely episode number, excluding common resolution tags/years.
  static int? parseEpisodeNumber(String fileName) {
    for (final match in _episodeNumberRegex.allMatches(fileName)) {
      final value = int.tryParse(match.group(1)!);
      if (_isLikelyEpisodeNumber(value)) return value;
    }

    final fallback = _fallbackEpisodeNumberRegex.firstMatch(fileName);
    final value = fallback == null ? null : int.tryParse(fallback.group(1)!);
    return _isLikelyEpisodeNumber(value) ? value : null;
  }

  static bool _isLikelyEpisodeNumber(int? value) =>
      value != null &&
      value < 2000 &&
      !_ignoredVideoResolutions.contains(value);
}
