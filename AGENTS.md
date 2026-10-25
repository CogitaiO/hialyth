# AGENTS.md

## Overview

Desktop Flutter media player for managing and watching anime. Built with Flutter, Isar (embedded database), MediaKit (libmpv playback), and Riverpod (state management).

## Essential Commands

- **Dependencies**: `flutter pub get`
- **Code Generation**: `dart run build_runner build --delete-conflicting-outputs`
  - Required after changing `lib/domain/anime.dart`. Generates `lib/domain/anime.g.dart`.
- **Analyze**: `flutter analyze`
  - Note: Reports warnings on experimental Isar index methods in generated `anime.g.dart`.
- **Format**: `dart format lib/`
- **Launcher Icons**: `dart run flutter_launcher_icons`
- **Run**: `flutter run -d <platform>` (`windows`, `linux`)
- **Tests**: Run the unit suite with `flutter test`; parser and anime model getter tests live in `test/`.

## Architecture & Key Components

- **Entrypoint**: `lib/main.dart`
  - Initializes `WidgetsFlutterBinding`, `MediaKit`, `windowManager` (frameless/hidden title bar), `initLogger()`, `DiscordRPC`, `SharedPreferences`, and `Isar`.
  - Root `ProviderScope` **must** override `animeRepoProvider` and `sharedPrefsProvider` (both throw `UnimplementedError` if uninitialized).
- **Domain & Database** (`lib/domain/`, `lib/data/repositories/`):
  - Isar entity: `Anime` with embedded models `EpisodeNote`, `PlaybackEntry`, `EpisodeSkipData`, `SkipIntervalDb`.
  - `AnimeRepository` wraps all Isar transactions and exposes reactive streams (`watchLibrary()`, `watchAnimeById()`).
- **Services** (`lib/data/services/`):
  - `file_discovery_service.dart`: Scans media folders (`.mp4`, `.mkv`, `.avi`) in a background isolate (`Isolate.run`), regex-parses titles, and queries Shikimori for metadata.
  - `shikimori_service.dart`: Queries Shikimori API for titles, descriptions (cleans BBCode), and poster URLs.
  - `aniskip_service.dart`: Queries AniSkip API for opening/ending timestamps (`types=op&types=ed&episodeLength=0`).
  - `discord_service.dart`: Discord RPC integration for Rich Presence during playback.
- **State Management** (`lib/providers/`):
  - Written with standard Riverpod v2 (`StateNotifierProvider`, `StreamProvider`, `Provider`) without `@riverpod` annotations.
  - `library_provider.dart`: Manages search queries, sidebar category filters, and user collection filtering.
  - `player/player_provider.dart`: Coordinates `media_kit` `Player`, throttles position updates to Isar, controls OP/ED auto-skipping, and updates Discord presence.
  - `settings_provider.dart`: Manages and persists user settings and saved library paths to `SharedPreferences`.
- **UI & Presentation** (`lib/presentation/`, `lib/widgets/`):
  - Custom frameless title bar with drag region via `CustomTitleBar` and `window_manager`.
  - Screens: `LibraryScreen`, `AnimeDetailsScreen`, `PlayerScreen`, `SettingsScreen`.
- **Logging** (`lib/core/logger.dart`):
  - Powered by `talker_flutter` (`talker` singleton).
  - Rotates log files in `<Documents>/NekaidoLogs/log_<timestamp>.txt`, retaining the 10 most recent logs.

## Gotchas & Quirks

- **Isar Codegen**: Always regenerate models via `dart run build_runner build --delete-conflicting-outputs` after editing `lib/domain/anime.dart`. Do not modify `anime.g.dart` directly.
- **MediaKit Native Platform Libraries**: Video decoding relies on platform packages (`media_kit_libs_windows_video` for Windows, `media_kit_libs_linux` for Linux). When targeting a specific platform, ensure the matching dependency is configured in `pubspec.yaml`.
- **Provider Injection**: `animeRepoProvider` and `sharedPrefsProvider` are declared as throwing placeholders; tests or preview scopes must provide explicit overrides.
- **Analysis Config**: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` and excludes generated `*.g.dart` files plus Flutter platform/build output directories.
