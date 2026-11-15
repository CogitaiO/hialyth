import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nekaido_pre/providers/player/anime_track_preferences.dart';

void main() {
  late AnimeTrackPreferences preferences;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = AnimeTrackPreferences(await SharedPreferences.getInstance());
  });

  test('choice survives recreation and reordered episode track IDs', () async {
    await preferences.save(
      1,
      'audio',
      id: '2',
      title: 'Studio dub',
      language: 'rus',
      index: 3,
    );
    preferences = AnimeTrackPreferences(await SharedPreferences.getInstance());
    expect(
      preferences.match(1, 'audio', [
        (id: '1', title: 'Studio dub', language: 'rus'),
        (id: '2', title: 'Original', language: 'jpn'),
      ]),
      0,
    );
    expect(
      preferences.match(2, 'audio', [
        (id: '1', title: 'Studio dub', language: 'rus'),
      ]),
      isNull,
    );
    expect(
      preferences.match(1, 'subtitle', [
        (id: '1', title: 'Studio dub', language: 'rus'),
      ]),
      isNull,
    );
  });

  test('off and auto persist without choosing a real track', () async {
    for (final id in ['no', 'auto']) {
      await preferences.save(
        1,
        'subtitle',
        id: id,
        title: null,
        language: null,
        index: 0,
      );
      expect(
        preferences.match(1, 'subtitle', [
          (id: '1', title: 'English', language: 'eng'),
          (id: id, title: null, language: null),
        ]),
        1,
      );
    }
  });

  test('missing track keeps preference for later external discovery', () async {
    await preferences.save(
      1,
      'subtitle',
      id: '3',
      title: 'Show 01.ass',
      language: 'eng',
      index: 2,
    );
    expect(
      preferences.match(1, 'subtitle', [
        (id: '3', title: 'Another studio', language: 'eng'),
      ]),
      isNull,
    );
    expect(
      preferences.match(1, 'subtitle', [
        (id: '5', title: 'Show 02.ass', language: 'eng'),
      ]),
      0,
    );
  });

  test('malformed persisted preference does not interrupt playback', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('anime_1_audio', 'broken');
    expect(preferences.match(1, 'audio', []), isNull);
  });
}
