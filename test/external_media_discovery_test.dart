import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/providers/player/external_media_discovery.dart';

void main() {
  test('reuses complete scans only for the same directory', () async {
    var scans = 0;
    final discovery = ExternalMediaDiscovery(listDirectory: (directory) {
      scans++;
      return Stream.fromIterable([
        File('${directory.path}/audio/voice.mka'),
        File('${directory.path}/subs/signs/episode.ass'),
        Directory('${directory.path}/fonts'),
      ]);
    });

    final first = await discovery.discover('/anime/one.mkv');
    final second = await discovery.discover('/anime/two.mkv');
    expect(scans, 1);
    expect(second, same(first));
    expect(first.audioDirs, ['/anime/audio']);
    expect(first.subDirs, ['/anime/subs/signs']);
    expect(first.subs['episode.ass'], ['subs signs']);
    expect(first.fontsDir, '/anime/fonts');
    await discovery.discover('/other/one.mkv');
    expect(scans, 2);
  });

  test('expires cached scans so new files can be discovered', () async {
    var scans = 0;
    final discovery = ExternalMediaDiscovery(
      cacheDuration: Duration.zero,
      listDirectory: (_) {
        scans++;
        return const Stream.empty();
      },
    );
    await discovery.discover('/anime/one.mkv');
    await discovery.discover('/anime/two.mkv');
    expect(scans, 2);
  });

  test('timeout cancels the scan and does not cache incomplete results',
      () async {
    var scans = 0;
    var cancelled = false;
    final discovery = ExternalMediaDiscovery(
      timeout: const Duration(milliseconds: 20),
      listDirectory: (_) {
        scans++;
        if (scans > 1) return const Stream.empty();
        return StreamController<FileSystemEntity>(
          onCancel: () => cancelled = true,
        ).stream;
      },
    );
    await expectLater(
        discovery.discover('/anime/one.mkv'), throwsA(isA<TimeoutException>()));
    expect(cancelled, isTrue);
    await discovery.discover('/anime/two.mkv');
    expect(scans, 2);
  });
}
