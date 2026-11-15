# Hialyth

**Language:** English · [Русский](README.md)

Hialyth organizes and plays a local anime collection. **Android is the primary development focus.** The library, playback progress, and videos stay local; online services provide optional metadata and timestamps.

## Project status

The project is at an early stage. The Android interface and folder access are being adapted and tested; bugs and incomplete workflows are possible. Stability and animation smoothness still need hands-on testing across devices.

| Platform | Status |
|---|---|
| **Android** | Primary focus: mobile UI, local library, playback, and new builds |
| Windows | Not a priority; active desktop development is deferred |
| Linux | Development is deferred due to external platform-stack issues outside the project developer's control |

The existing [desktop release 0.1.0](https://github.com/CogitaiO/hialyth/releases/tag/v0.1.0) remains available as a historical version, not the current development direction. No public Android release has been published yet. See [ROADMAP.md](ROADMAP.md) for progress and plans.

## Features

- **Library:** add folders through the system picker, group episodes, track watch status, and create collections; search, sort, and retain the Grid/List view selection.
- **Continue watching:** saved playback positions, a resume section, and episode progress information.
- **Player:** local playback, audio and subtitle selection, notes, opening/ending auto-skip, and recoverable loading errors.
- **Anime details:** Shikimori metadata and AniSkip timestamps when an internet connection is available.
- **Settings:** accent color, playback and accessibility options. Discord Rich Presence belongs to the desktop version, not Android.

The library scanner supports `.mkv`, `.mp4`, and `.avi`. New folders are scanned when added; saved folders are refreshed with **Rescan Library** in the library or settings. Opening the app does not automatically scan them. Hialyth does not delete original video files.

## Android builds

Until a public Android release is available, build from source. The **Android checks and debug APK** workflow also saves a test ARM64 APK in the artifacts of a successful GitHub Actions run; downloading artifacts requires signing in to GitHub.

Debug installations are separate from the release app and its data. They are not stable releases. After installation, add a video folder through the Android system picker and grant access to that folder.

New public releases target Android APKs for ARM64, ARMv7, and x86_64, with a persistent signing key and download checksums. See [docs/android-releases.md](docs/android-releases.md) for signing and publishing (in Russian). Back up app data before upgrading.

## Technology

Flutter and Dart, MediaKit / libmpv, Isar Community, and Riverpod. Shikimori and AniSkip provide external data.

## Development

Install the Flutter and Android SDKs and connect an Android device with USB debugging enabled, or use an emulator. The Dart SDK constraint is specified in [`pubspec.yaml`](pubspec.yaml). See the [repository map](docs/repository-map.md) for branches and source layout (in Russian).

```bash
flutter pub get
flutter devices
flutter run -d DEVICE_ID  # Android device ID from flutter devices
flutter analyze
flutter test
flutter build apk --debug
```

Test APK: `build/app/outputs/flutter-apk/app-debug.apk`. Release builds require a separate persistent key; debug signing is no longer substituted for release signing.

After changing `lib/domain/anime.dart`, regenerate the Isar code:

```bash
dart run build_runner build --delete-conflicting-outputs
```
