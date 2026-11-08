import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:discord_rpc/discord_rpc.dart';
import 'dart:io';
import 'core/logger.dart';
import 'domain/anime.dart';
import 'data/repositories/anime_repository.dart';
import 'providers/repositories_provider.dart';
import 'presentation/library_screen.dart';
import 'providers/library_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/debug/design_system_gallery.dart';
import 'core/app_features.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme_extension.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();
  await initLogger();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      DiscordRPC.initialize();
    } catch (e) {
      talker.debug('DiscordRPC initialization failed: $e');
    }
  }
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(840, 560),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([AnimeSchema], directory: dir.path);
    final repository = AnimeRepository(isar);

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
        child: const MyApp(),
      ),
    );
  } catch (e, st) {
    talker.handle(e, st, 'Critical startup error');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accentColorValue = settings.accentColorValue;
    final accentColor = Color(accentColorValue);

    return MaterialApp(
      title: 'Nekaido',
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
              settings.reduceMotion || MediaQuery.disableAnimationsOf(context),
        ),
        child: HeroMode(
          enabled: !(settings.reduceMotion ||
              MediaQuery.disableAnimationsOf(context)),
          child: child!,
        ),
      ),
      home: const LibraryScreen(),
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
