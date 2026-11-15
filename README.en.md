# Hialyth

**Language:** English · [Русский](README.md)

Hialyth is a desktop application for organizing and watching a local anime collection. The library, playback progress, and videos stay local; online services provide optional metadata and timestamps.

## Project status

[Release 0.1.0 is available for Windows and Linux](https://github.com/CogitaiO/hialyth/releases/tag/v0.1.0). The project is at an early stage: bugs and platform-specific differences are possible. See [ROADMAP.md](ROADMAP.md) for current progress and plans.

## Features

- **Library:** scan video folders, group episodes, track watch status, and create collections; search, sort, and retain the Grid/List view selection.
- **Continue watching:** saved playback positions, a resume section, and episode progress information.
- **Player:** local playback, audio and subtitle selection, notes, opening/ending auto-skip, and recoverable loading errors.
- **Anime details:** Shikimori metadata and AniSkip timestamps when an internet connection is available.
- **Settings:** accent color, playback and accessibility options, and Discord Rich Presence.

The library scanner supports `.mkv`, `.mp4`, and `.avi`. Hialyth does not delete original video files.

## Installation

Download the archive for your platform from the [release page](https://github.com/CogitaiO/hialyth/releases/tag/v0.1.0) and extract it in full:

- **Windows x64:** run `nekaido_pre.exe` from the extracted folder.
- **Linux x64:** run `./nekaido_pre` from the extracted folder. The build was created on Fedora 44 and requires compatible system libraries, including GTK 3 and `libmpv.so.2`; other distributions have not been validated.

The builds compiled successfully and automated tests passed, but manual testing on Windows and other Linux distributions is still needed. Back up application data before upgrading.

## Technology

Flutter and Dart, MediaKit / libmpv, Isar Community, and Riverpod. Shikimori and AniSkip provide external data.

## Development

Install the Flutter SDK; the Dart SDK constraint is specified in [`pubspec.yaml`](pubspec.yaml).

```bash
flutter pub get
flutter devices
flutter run -d linux  # or -d windows on Windows
flutter analyze
flutter test
```

After changing `lib/domain/anime.dart`, regenerate the Isar code:

```bash
dart run build_runner build --delete-conflicting-outputs
```
