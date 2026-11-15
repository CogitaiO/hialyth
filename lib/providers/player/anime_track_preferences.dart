import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Explicit per-title choices, independent of mpv's automatic track changes.
/// Metadata survives reordered track IDs between episodes. Missing choices are
/// left pending, so a later external-track discovery can still restore them.
class AnimeTrackPreferences {
  const AnimeTrackPreferences(this.prefs);
  final SharedPreferences prefs;

  Future<bool> save(
    int animeId,
    String kind, {
    required String id,
    required String? title,
    required String? language,
    required int index,
  }) => prefs.setString(
    'anime_${animeId}_$kind',
    jsonEncode({
      'id': id,
      'title': _normalize(title),
      'language': language,
      'index': index,
    }),
  );

  int? match(
    int animeId,
    String kind,
    List<({String id, String? title, String? language})> tracks,
  ) {
    final raw = prefs.getString('anime_${animeId}_$kind');
    if (raw == null) return null;
    try {
      final saved = jsonDecode(raw) as Map<String, dynamic>;
      final id = saved['id'];
      if (id == 'auto' || id == 'no') {
        final index = tracks.indexWhere((t) => t.id == id);
        return index < 0 ? null : index;
      }
      final title = saved['title'];
      final language = saved['language'];
      final candidates = <int>[];
      for (var i = 0; i < tracks.length; i++) {
        final track = tracks[i];
        if (track.id == 'auto' || track.id == 'no') continue;
        if (title != null && _normalize(track.title) != title) continue;
        if (language != null && track.language != language) continue;
        candidates.add(i);
      }
      if (candidates.isEmpty) return null;
      if (title != null || language != null) {
        if (candidates.length == 1) return candidates.single;
        // Preserve the slot when several tracks have identical metadata.
        if (candidates.contains(saved['index'])) return saved['index'] as int;
        return candidates.first;
      }
      // With no metadata, only the same slot/ID is a defensible fallback.
      final slot = saved['index'];
      if (slot is int && candidates.contains(slot) && tracks[slot].id == id) {
        return slot;
      }
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
    return null;
  }

  static String? _normalize(String? title) {
    if (title == null || title.trim().isEmpty) return null;
    // External files often differ only in the episode number.
    final normalized = title.trim().toLowerCase();
    if (RegExp(r'\.(ass|ssa|srt|vtt|mka|aac|ac3|flac)$').hasMatch(normalized)) {
      return normalized.replaceAll(RegExp(r'\d+'), '#');
    }
    return normalized;
  }
}
