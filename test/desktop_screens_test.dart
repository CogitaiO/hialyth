import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/library_screen.dart';
import 'package:nekaido_pre/presentation/settings/settings_screen.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';

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
