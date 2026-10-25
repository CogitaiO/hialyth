# Hialyth

**Language:** English · [Русский](README.md)

Nekaido is a desktop application for organizing and watching a local anime collection. The project aims to bring together a media library, anime metadata, and a convenient local video player.

## Project status

Nekaido is under active development and is at an early stage. The main workflows are in place, but the application and its interface are still evolving. Bugs, unfinished features, and differences in platform support are expected. No stable release is currently announced.

## Features

- **Library:** scan video folders, group files into episodes, track watch status, and create custom collections.
- **Playback:** play local videos, select audio tracks and subtitles, resume playback, and add episode notes.
- **Metadata and timestamps:** fetch anime details from Shikimori and opening/ending timestamps from AniSkip. These features require an internet connection.
- **Settings and integrations:** choose an accent color, configure language and decoding preferences, enable OP/ED auto-skip, and use Discord Rich Presence.

Video files recognized by the library scanner: `.mkv`, `.mp4`, and `.avi`. The library and media remain local; Nekaido does not delete the original files.

## Technology

- Flutter and Dart
- MediaKit / libmpv for video playback
- Isar for the local database
- Riverpod for application state
- Shikimori and AniSkip for external data

## Run and verify

Install the Flutter SDK. The Dart SDK constraint is specified in [`pubspec.yaml`](pubspec.yaml).

```bash
flutter pub get
flutter run
```

Run `flutter devices` to list available devices; select one with the `-d` option. Desktop builds are still being validated across platforms.

```bash
flutter analyze
flutter test
```

After changing the model in `lib/domain/anime.dart`, regenerate the Isar code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Roadmap

- Gradually unify screen styling, colors, spacing, corner radii, and icons.
- Improve filename recognition, library rescanning, and network error handling.
- Expand tests for the library, playback, and user settings.
- Validate and improve builds and runtime behavior across desktop platforms.
