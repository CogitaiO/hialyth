import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nekaido_pre/presentation/anime_details/anime_details_screen.dart';
import 'package:nekaido_pre/presentation/anime_details/widgets/right_info_panel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/data/services/file_discovery_service.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/library_screen.dart';
import 'package:nekaido_pre/presentation/settings/settings_screen.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';

class _UnusedRepository extends Fake implements AnimeRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await (FontLoader('packages/iconsax_flutter/FlutterIconsax')
          ..addFont(rootBundle
              .load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf')))
        .load();
    for (final font in ['Inter', 'JetBrainsMono']) {
      await (FontLoader(font)
            ..addFont(rootBundle.load('assets/fonts/$font-Variable.ttf')))
          .load();
    }
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'has_seen_vpn_warning': true});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'),
            (call) async {
      return ['isMaximized', 'isFullScreen', 'isAlwaysOnTop']
              .contains(call.method)
          ? false
          : null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
  });

  for (final size in [const Size(840, 560), const Size(1280, 720)]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';
    testWidgets('accessibility settings are reachable and persisted at $label',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final prefs = await SharedPreferences.getInstance();
      Widget app() => ProviderScope(
            key: UniqueKey(),
            overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
            child: MaterialApp(
              theme: AppTheme.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SettingsScreen(),
            ),
          );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      for (final item in [
        ('reduce-transparency', 'pref_reduce_transparency'),
        ('reduce-motion', 'pref_reduce_motion')
      ]) {
        final finder = find.byKey(ValueKey(item.$1));
        expect(finder.hitTestable(), findsOneWidget);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(prefs.getBool(item.$2), isTrue);
      }
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/settings_$label.png'));
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<SwitchListTile>(
                  find.byKey(const ValueKey('reduce-transparency')))
              .value,
          isTrue);
      expect(
          tester
              .widget<SwitchListTile>(
                  find.byKey(const ValueKey('reduce-motion')))
              .value,
          isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Details stays readable and scrollable at $label and 200 percent text',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dir = Directory.systemTemp.createTempSync('hialyth-details-');
      addTearDown(() => dir.delete(recursive: true));
      final first = File('${dir.path}/Example - 01.mkv')..createSync();
      final anime = Anime()
        ..id = 1
        ..title =
            'Frieren: Beyond Journey’s End — A long title for the compact layout'
        ..episodePaths = [first.path, '${dir.path}/missing-02.mkv']
        ..descripion = List.filled(12,
                'A journey through memories, friendships, and the passage of time.')
            .join(' ');
      final prefs = await SharedPreferences.getInstance();
      Widget app(double scale) => ProviderScope(
              overrides: [
                sharedPrefsProvider.overrideWithValue(prefs),
                animeDetailsProvider(1)
                    .overrideWith((ref) => Stream.value(anime)),
              ],
              child: MaterialApp(
                theme: AppTheme.dark(),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!),
                home: const AnimeDetailsScreen(
                    animeId: 1, heroTag: 'test-details'),
              ));
      await tester.pumpWidget(app(1));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds:50)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/details_$label.png'));
      final scroll = find
          .descendant(
              of: find.byType(RightInfoPanel),
              matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.text('Read more'), 150,
          scrollable: scroll);
      if (find.text('Read more').hitTestable().evaluate().isEmpty) {
        await tester.drag(scroll, const Offset(0,-180));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Read more'));
      await tester.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('missing-02.mkv'), 200,
          scrollable: scroll);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds:50)));
      await tester.pumpAndSettle();
      expect(find.text('File missing'), findsOneWidget);
      await tester.pumpWidget(app(2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('library navigation and cards at $label', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final prefs = await SharedPreferences.getInstance();
      final titles = [
        'Frieren: Beyond Journey’s End',
        'Cowboy Bebop',
        'Violet Evergarden',
        'Mushishi',
        'A Silent Voice',
        'Steins;Gate'
      ];
      final library = [
        for (var i = 0; i < titles.length; i++)
          Anime()
            ..id = i + 1
            ..title = titles[i]
            ..episodePaths = List.generate(12, (n) => '/anime/$i/$n.mkv')
            ..watchedEpisodes = List.generate(i, (n) => '/anime/$i/$n.mkv')
            ..status = AnimeStatus.values[i % 4]
      ];
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          scannerProvider
              .overrideWithValue(FileDiscoveryService(_UnusedRepository())),
          libraryProvider.overrideWith((ref) => Stream.value(library))
        ],
        child: MaterialApp(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LibraryScreen()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/library_$label.png'));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isTrue);
      await tester.tap(find.byTooltip('Sort library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Watch progress'));
      await tester.pumpAndSettle();
      expect(prefs.getString('library_sort'), 'progress');
      await tester.tap(find.byTooltip('List view'));
      await tester.pumpAndSettle();
      expect(prefs.getBool('library_list'), isTrue);
      await tester.enterText(find.byType(TextField), 'Violet');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Violet Evergarden'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      if (size.width < 900) {
        await tester.tap(find.byTooltip('Library navigation'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('reduce-transparency')).hitTestable(),
          findsOneWidget);
    });
  }
}
