import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/services/file_discovery_service.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/library_screen.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/providers/scan_provider.dart';
import 'package:nekaido_pre/providers/settings_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Scanner extends Fake implements FileDiscoveryService {
  final calls = <String>[];
  Completer<ScanResult>? pending;
  String? failOnce;

  @override
  Future<ScanResult> scanAndGroupFiles(
    String folderPath, {
    bool Function()? isCancelled,
    Future<void>? cancellation,
  }) async {
    calls.add(folderPath);
    if (folderPath == failOnce) {
      failOnce = null;
      throw StateError('Folder unavailable');
    }
    if (pending case final gate?) {
      return Future.any([
        gate.future,
        if (cancellation != null)
          cancellation.then((_) => const ScanResult(cancelled: true)),
      ]);
    }
    return const ScanResult();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_seen_vpn_warning': true,
      'library_folders': ['/first', '/second'],
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (call) async => false,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
  });

  Future<ProviderContainer> mount(
    WidgetTester tester,
    _Scanner scanner, {
    int screen = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          scannerProvider.overrideWithValue(scanner),
          libraryProvider.overrideWith((ref) => Stream.value(<Anime>[])),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LibraryScreen(key: ValueKey(screen)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(LibraryScreen)),
    );
  }

  final refresh = find.byKey(const ValueKey('library-refresh'));

  testWidgets('opening and recreating the library never starts a scan', (
    tester,
  ) async {
    final scanner = _Scanner();
    await mount(tester, scanner);
    expect(scanner.calls, isEmpty);
    await mount(tester, scanner, screen: 1);
    expect(scanner.calls, isEmpty);
    expect(tester.widget<IconButton>(refresh).onPressed, isNotNull);
  });

  testWidgets(
    'refresh scans saved folders once and disables duplicate actions',
    (tester) async {
      final scanner = _Scanner()..pending = Completer<ScanResult>();
      final container = await mount(tester, scanner);
      await tester.tap(refresh);
      await tester.pump();
      expect(scanner.calls, ['/first']);
      expect(tester.widget<IconButton>(refresh).onPressed, isNull);
      expect(container.read(scanProvider).running, isTrue);
      await tester.tap(refresh);
      expect(scanner.calls, ['/first']);

      scanner.pending!.complete(const ScanResult());
      scanner.pending = null;
      await tester.pumpAndSettle();
      expect(scanner.calls, ['/first', '/second']);
      expect(container.read(scanProvider).completed, 2);
      expect(container.read(savedFoldersProvider), ['/first', '/second']);
      expect(tester.widget<IconButton>(refresh).onPressed, isNotNull);
    },
  );

  testWidgets('refresh is disabled without saved folders on a narrow phone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_vpn_warning': true});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final scanner = _Scanner();
    await mount(tester, scanner);
    expect(tester.widget<IconButton>(refresh).onPressed, isNull);
    expect(scanner.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed refresh can retry only the failed folder', (
    tester,
  ) async {
    final scanner = _Scanner()..failOnce = '/second';
    final container = await mount(tester, scanner);
    await tester.tap(refresh);
    await tester.pumpAndSettle();
    expect(container.read(scanProvider).errors, ['/second']);
    expect(container.read(savedFoldersProvider), ['/first', '/second']);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(scanner.calls, ['/first', '/second', '/second']);
    expect(container.read(scanProvider).errors, isEmpty);
  });

  testWidgets('cancelling refresh does not scan the next saved folder', (
    tester,
  ) async {
    final scanner = _Scanner()..pending = Completer<ScanResult>();
    final container = await mount(tester, scanner);
    await tester.tap(refresh);
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(scanner.calls, ['/first']);
    expect(container.read(scanProvider).cancelled, isTrue);
    expect(tester.widget<IconButton>(refresh).onPressed, isNotNull);
  });
}
