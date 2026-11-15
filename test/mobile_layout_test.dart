import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nekaido_pre/data/repositories/anime_repository.dart';
import 'package:nekaido_pre/data/services/file_discovery_service.dart';
import 'package:nekaido_pre/domain/anime.dart';
import 'package:nekaido_pre/l10n/app_localizations.dart';
import 'package:nekaido_pre/presentation/library_screen.dart';
import 'package:nekaido_pre/presentation/settings/settings_screen.dart';
import 'package:nekaido_pre/presentation/player/widgets/track_selector_dialog.dart';
import 'package:nekaido_pre/presentation/player/widgets/mobile_player_overlay.dart';
import 'package:nekaido_pre/providers/player/player_provider.dart';
import 'package:nekaido_pre/providers/library_provider.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_loading_test.dart' as player_fakes;

class _UnusedRepository extends Fake implements AnimeRepository {}

class _PlayerStream extends Fake implements PlayerStream {
  @override
  Stream<Duration> get position => const Stream.empty();
}

class _Player extends Fake implements Player {
  @override
  PlayerStream get stream => _PlayerStream();
}

class _OverlayBackend extends player_fakes.Backend {
  int playPauseCalls = 0;
  @override
  Player get player => _Player();
  @override
  Future<void> setRate(double rate) async {}
  @override
  Future<void> playOrPause() async {
    playPauseCalls++;
  }
}

class _PlaylistNotifier extends PlayerNotifier {
  _PlaylistNotifier(
    super.repository,
    super.prefs, {
    super.engine,
    super.discordService,
  });

  final requestedPaths = <String>[];

  void seed(List<String> paths) {
    state = state.copyWith(
      playback: state.playback.copyWith(
        animeId: 1,
        videoPath: paths[1],
        playlist: paths,
      ),
    );
  }

  @override
  Future<void> loadVideo(int animeId, String path) {
    requestedPaths.add(path);
    state = state.copyWith(playback: state.playback.copyWith(videoPath: path));
    return Future.value();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'has_seen_vpn_warning': true});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), (
          call,
        ) async {
          return [
                'isMaximized',
                'isFullScreen',
                'isAlwaysOnTop',
              ].contains(call.method)
              ? false
              : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('library and settings fit a $width px phone', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            scannerProvider.overrideWithValue(
              FileDiscoveryService(_UnusedRepository()),
            ),
            libraryProvider.overrideWith((ref) => Stream.value(<Anime>[])),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: 32, bottom: 24)),
              child: child!,
            ),
            home: const LibraryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byTooltip('Library navigation').hitTestable(),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.byTooltip('Library navigation')).dy,
        greaterThanOrEqualTo(32),
      );
      await tester.tap(find.byTooltip('Library navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(BackButton).hitTestable(), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(BackButton)).dy,
        greaterThanOrEqualTo(32),
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('track selector fits a landscape phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final prefs = await SharedPreferences.getInstance();
    final notifier = PlayerNotifier(
      player_fakes.Repository(),
      prefs,
      engine: player_fakes.Backend(),
      discordService: player_fakes.Presence(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerProvider.overrideWith((ref) => notifier)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TrackSelectorDialog()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(Tab).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final size in [const Size(320, 640), const Size(800, 360)]) {
    testWidgets(
      'mobile player actions fit and open the right controls at $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final prefs = await SharedPreferences.getInstance();
        final backend = _OverlayBackend();
        final insets = size.width > size.height
            ? const EdgeInsets.fromLTRB(24, 0, 16, 16)
            : const EdgeInsets.only(top: 24, bottom: 16);
        final notifier = PlayerNotifier(
          player_fakes.Repository(),
          prefs,
          engine: backend,
          discordService: player_fakes.Presence(),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [playerProvider.overrideWith((ref) => notifier)],
            child: MaterialApp(
              theme: AppTheme.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: insets,
                  textScaler: const TextScaler.linear(1.2),
                ),
                child: child!,
              ),
              home: const Scaffold(
                body: MobilePlayerOverlay(
                  title:
                      'A long anime title that should never displace the buttons',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final subtitles = find.byKey(const ValueKey('mobile-player-subtitles'));
        final settings = find.byKey(const ValueKey('mobile-player-settings'));
        final play = find.byKey(const ValueKey('mobile-player-play'));
        expect(tester.getCenter(settings).dx, greaterThan(size.width * .8));
        expect(tester.getCenter(subtitles).dy, lessThan(insets.top + 60));
        expect(
          tester.getTopLeft(subtitles).dy,
          greaterThanOrEqualTo(insets.top),
        );
        expect(
          tester.getCenter(play).dy,
          closeTo((size.height + insets.top - insets.bottom) / 2, 1),
        );
        expect(find.byIcon(Icons.replay_10), findsNothing);
        expect(find.byIcon(Icons.share), findsNothing);
        expect(find.byIcon(Icons.cast), findsNothing);
        expect(find.byIcon(Icons.fullscreen), findsNothing);
        expect(
          find.byKey(const ValueKey('mobile-player-previous')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('mobile-player-next')), findsNothing);
        expect(tester.getSize(play), const Size(80, 80));
        await tester.tap(play);
        await tester.pump();
        expect(backend.playPauseCalls, 1);
        await tester.tap(subtitles);
        await tester.pumpAndSettle();
        final tabs = tester.element(find.byType(TabBar));
        expect(DefaultTabController.of(tabs).index, 1);
        Navigator.of(tabs).pop();
        await tester.pumpAndSettle();
        await tester.tap(settings);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Audio'));
        await tester.pumpAndSettle();
        final audioTabs = tester.element(find.byType(TabBar));
        expect(DefaultTabController.of(audioTabs).index, 0);
        Navigator.of(audioTabs).pop();
        await tester.pumpAndSettle();
        await tester.tap(settings);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Speed'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('1.5x'),
          60,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(find.text('1.5x'));
        await tester.pumpAndSettle();
        expect(notifier.state.playbackSpeed, 1.5);
        notifier.toggleUi();
        await tester.pumpAndSettle();
        expect(play.hitTestable(), findsNothing);
        expect(settings.hitTestable(), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'episode controls request adjacent playlist entries and hide at edges',
    (tester) async {
      final paths = ['/first.mkv', '/middle.mkv', '/last.mkv'];
      final repository = player_fakes.Repository();
      repository.records[1] = Anime()
        ..id = 1
        ..title = 'Playlist'
        ..episodePaths = paths;
      final backend = _OverlayBackend();
      final notifier = _PlaylistNotifier(
        repository,
        await SharedPreferences.getInstance(),
        engine: backend,
        discordService: player_fakes.Presence(),
      );
      notifier.seed(paths);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [playerProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: MobilePlayerOverlay(title: 'Playlist')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final previous = find.byKey(const ValueKey('mobile-player-previous'));
      final next = find.byKey(const ValueKey('mobile-player-next'));
      final play = find.byKey(const ValueKey('mobile-player-play'));
      final centre = tester.getCenter(play);
      expect(tester.getCenter(previous).dx, lessThan(centre.dx));
      expect(tester.getCenter(next).dx, greaterThan(centre.dx));
      await tester.tap(previous);
      await tester.pumpAndSettle();
      expect(notifier.requestedPaths.last, paths.first);
      expect(previous, findsNothing);
      expect(tester.getCenter(play), centre);
      await notifier.loadVideo(1, paths[1]);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(notifier.requestedPaths.last, paths.last);
      expect(next, findsNothing);
      expect(tester.getCenter(play), centre);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
