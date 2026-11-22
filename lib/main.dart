import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar_community/isar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:discord_rpc/discord_rpc.dart';
import 'dart:io';
import 'core/logger.dart';
import 'core/frame_metrics.dart';
import 'domain/anime.dart';
import 'data/repositories/anime_repository.dart';
import 'providers/repositories_provider.dart';
import 'presentation/library_screen.dart';
import 'presentation/mobile_navigation_gesture.dart';
import 'providers/library_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_motion.dart';
import 'l10n/app_localizations.dart';
import 'presentation/debug/design_system_gallery.dart';
import 'core/app_features.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme_extension.dart';
import 'demo/showcase_fixtures.dart';
import 'demo/showcase_storage.dart';

bool _showcasePreferencesPrefixSet = false;

Future<void> main() => runHialyth();

Future<void> runHialyth({bool showcaseMode = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    MediaKit.ensureInitialized();
    final isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    if (isDesktop) {
      await windowManager.ensureInitialized();
    }
    await initLogger();
    startFrameMetrics();
    if (!showcaseMode && isDesktop) {
      try {
        DiscordRPC.initialize();
      } catch (e) {
        talker.debug('DiscordRPC initialization failed: $e');
      }
    }
    if (isDesktop) {
      const windowOptions = WindowOptions(
        size: Size(1280, 720),
        minimumSize: Size(840, 560),
        center: true,
        titleBarStyle: TitleBarStyle.hidden,
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }

    if (showcaseMode && !_showcasePreferencesPrefixSet) {
      SharedPreferences.setPrefix(ShowcaseStorage.preferencesPrefix);
      _showcasePreferencesPrefixSet = true;
    }
    final prefs = await SharedPreferences.getInstance();
    final databaseDirectory = showcaseMode
        ? Directory(ShowcaseStorage.databasePath(
            (await getApplicationSupportDirectory()).path))
        : await getApplicationDocumentsDirectory();
    if (showcaseMode) {
      await databaseDirectory.create(recursive: true);
    }
    final isar =
        await Isar.open([AnimeSchema], directory: databaseDirectory.path);
    final repository = AnimeRepository(isar);
    if (showcaseMode) {
      await ShowcaseFixtures.seedOnFirstLaunch(repository, prefs);
    }

    FlutterError.onError = (details) {
      talker.handle(details.exception, details.stack, 'Critical UI error');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      talker.handle(error, stack, 'Unhandled asynchronous error');
      return true;
    };

    runApp(
      ProviderScope(
        overrides: [
          animeRepoProvider.overrideWithValue(repository),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: MyApp(showcaseMode: showcaseMode),
      ),
    );
  } catch (e, st) {
    talker.handle(e, st, 'Critical startup error');
    runApp(_StartupErrorApp(
        onRetry: () => runHialyth(showcaseMode: showcaseMode)));
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.showcaseMode = false});
  final bool showcaseMode;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _mobileNavigation = MobileNavigationController();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accentColorValue = settings.accentColorValue;
    final accentColor = Color(accentColorValue);

    return MaterialApp(
      navigatorKey: _mobileNavigation.key,
      navigatorObservers: [_mobileNavigation],
      onGenerateTitle: (context) => widget.showcaseMode
          ? 'Hialyth Showcase'
          : AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppFeatures.designV2
          ? AppTheme.dark(accent: accentColor)
          : _legacyTheme(accentColor),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routes: {
        if (kDebugMode) '/_design': (_) => const DesignSystemGallery(),
      },
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              settings.reduceMotion || AppMotion.isReduced(context),
        ),
        child: HeroMode(
          enabled: !(settings.reduceMotion ||
              AppMotion.isReduced(context)),
          child: MobileNavigationGesture(
            controller: _mobileNavigation,
            child: child!,
          ),
        ),
      ),
      home: LibraryScreen(showcaseMode: widget.showcaseMode),
    );
  }
}

ThemeData _legacyTheme(Color accentColor) {
  const appTheme = AppThemeExtension.dark();
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: Brightness.dark,
  ).copyWith(
    primary: accentColor,
    onPrimary: AppPalette.onAccent(accentColor),
    secondary: accentColor,
    onSecondary: AppPalette.onAccent(accentColor),
    surface: appTheme.pageSurface,
  );

  return ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: appTheme.pageSurface,
    colorScheme: colorScheme,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accentColor,
      selectionColor: accentColor.withValues(alpha: 0.3),
      selectionHandleColor: accentColor,
    ),
    extensions: const [appTheme],
  );
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: AppTheme.dark(),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
            builder: (context) => Scaffold(
                    body: Center(
                        child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(AppLocalizations.of(context).startupFailed,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context).startupFailedBody,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton(
                        onPressed: onRetry,
                        child: Text(AppLocalizations.of(context).commonRetry)),
                  ]),
                )))),
      );
}
