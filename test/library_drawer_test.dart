import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/data/services/file_discovery_service.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/library_screen.dart';
import 'package:nekaido_pre/presentation/library/phone_library_header.dart';
import 'package:nekaido_pre/presentation/settings/settings_screen.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UnusedRepository extends Fake implements AnimeRepository {}

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester, {
    List<Anime> animes = const [],
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({'has_seen_vpn_warning': true});
    final prefs = await SharedPreferences.getInstance();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const windowChannel = MethodChannel('window_manager');
    messenger.setMockMethodCallHandler(windowChannel, (call) async {
      return [
            'isMaximized',
            'isFullScreen',
            'isAlwaysOnTop',
          ].contains(call.method)
          ? false
          : null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(windowChannel, null));

    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        scannerProvider.overrideWithValue(
          FileDiscoveryService(_UnusedRepository()),
        ),
        libraryProvider.overrideWith((ref) => Stream.value(animes)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(accent: Colors.green),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> openWithSwipe(WidgetTester tester) async {
    await tester.dragFrom(const Offset(40, 420), const Offset(210, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('a left-half swipe opens the library drawer', (tester) async {
    await mount(tester);
    expect(find.byType(Drawer), findsNothing);

    // A drag that starts well inside the edge (40 px) must work.
    await openWithSwipe(tester);
    expect(find.byType(Drawer), findsOneWidget);
    final drawer = tester.getRect(find.byType(Drawer));
    expect(drawer.left, 0);
    expect(drawer.width, greaterThan(260));

    await tester.tapAt(const Offset(360, 420));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);

    // The activation strip now reaches the horizontal middle of the page.
    await tester.dragFrom(const Offset(170, 420), const Offset(210, 0));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    await tester.tapAt(const Offset(360, 420));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);

    // A drag that starts past the middle still belongs to the content.
    await tester.dragFrom(const Offset(220, 420), const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);

    // Vertical scrolls that begin near the edge stay scrolls.
    await tester.dragFrom(const Offset(40, 420), const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
  });

  testWidgets('the header shrinks and keeps filters pinned while scrolling', (
    tester,
  ) async {
    final animes = [
      for (var i = 1; i <= 10; i++)
        Anime()
          ..id = i
          ..title = 'Anime $i'
          ..status = i.isEven ? AnimeStatus.watching : AnimeStatus.planned
          ..episodePaths = ['/missing/episode-$i.mkv'],
    ];
    await mount(tester, animes: animes);
    final header = find.byKey(const ValueKey('phone-library-header'));
    expect(
      tester.getSize(header).height,
      closeTo(kPhoneLibraryHeaderExpanded, .5),
    );
    expect(find.byType(TextField).hitTestable(), findsOneWidget);

    await tester.dragFrom(const Offset(200, 620), const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(header).height,
      closeTo(kPhoneLibraryHeaderCollapsed, .5),
    );
    expect(find.byType(TextField).hitTestable(), findsNothing);
    expect(find.text('All titles').hitTestable(), findsOneWidget);

    await tester.dragFrom(const Offset(200, 300), const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(header).height,
      closeTo(kPhoneLibraryHeaderExpanded, .5),
    );
  });

  testWidgets('drawer destinations switch the library and open settings', (
    tester,
  ) async {
    final container = await mount(tester);
    await openWithSwipe(tester);
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Watching')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
    expect(container.read(selectedSidebarIndexProvider), 1);
    expect(find.text('Watching'), findsWidgets);

    await openWithSwipe(tester);
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Settings')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
