import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/data/services/file_discovery_service.dart';
import 'package:nekaido_pre/domain/anime.dart';

class ScanRepository extends Fake implements AnimeRepository {
  int reconciliations = 0;
  Map<String, List<String>>? grouped;

  @override
  Future<List<Anime>> reconcileScan(
    String folder,
    Map<String, List<String>> grouped,
  ) async {
    reconciliations++;
    this.grouped = grouped;
    return [];
  }
}

void stalledWorker((String, SendPort) request) {
  Timer.periodic(const Duration(seconds: 1), (_) {});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Android document scan groups names and keeps document URIs', () async {
    const channel = MethodChannel('hialyth/android_documents');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'scan');
          return [
            {
              'name': 'Example - 01.mkv',
              'uri': 'content://provider/tree/a/document/1',
            },
            {
              'name': 'Example - 02.mkv',
              'uri': 'content://provider/tree/a/document/2',
            },
          ];
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final repo = ScanRepository();
    final result = await FileDiscoveryService(
      repo,
    ).scanAndGroupFiles('content://provider/tree/a');
    expect(result.files, 2);
    expect(repo.grouped!['Example'], hasLength(2));
  });
  test(
    'cancels a running worker without reconciling partial results',
    () async {
      final repo = ScanRepository();
      final cancellation = Completer<void>();
      final scanner = FileDiscoveryService(repo, scanWorker: stalledWorker);
      final pending = scanner.scanAndGroupFiles(
        '/unused',
        cancellation: cancellation.future,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      cancellation.complete();
      final result = await pending.timeout(const Duration(seconds: 2));
      expect(result.cancelled, isTrue);
      expect(repo.reconciliations, 0);
    },
  );

  test('times out without reconciling partial results', () async {
    final repo = ScanRepository();
    final scanner = FileDiscoveryService(
      repo,
      scanWorker: stalledWorker,
      scanTimeout: const Duration(milliseconds: 30),
    );
    await expectLater(
      scanner.scanAndGroupFiles('/unused'),
      throwsA(isA<TimeoutException>()),
    );
    expect(repo.reconciliations, 0);
  });

  test('scans actual media and reports unavailable folders', () async {
    final repo = ScanRepository();
    final scanner = FileDiscoveryService(repo);
    final directory = await Directory.systemTemp.createTemp('hialyth-scan-');
    addTearDown(() => directory.delete(recursive: true));
    await File('${directory.path}/Example - 01.mkv').create();
    await File('${directory.path}/ignore.txt').create();
    final result = await scanner.scanAndGroupFiles(directory.path);
    expect(result.files, 1);
    expect(repo.reconciliations, 1);
    expect(repo.grouped!.values.single, hasLength(1));
    await expectLater(
      scanner.scanAndGroupFiles('${directory.path}/missing'),
      throwsA(isA<FileSystemException>()),
    );
    expect(repo.reconciliations, 1);
  });
}
