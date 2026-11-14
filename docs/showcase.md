# Showcase build

The Showcase build uses `lib/main_showcase.dart` instead of the production
entry point. It seeds a small fictional anime library on first launch and
exposes the developer console button beside the library heading. The console
can add the sample set, create custom fixture records (including local poster
files), remove demo entries, or clear the demo library.

Showcase data is isolated in an `hialyth_showcase` subdirectory under the
platform application-support directory. Showcase preferences use the
`hialyth_showcase_` prefix. The regular library database and settings are not
opened by this entry point. Sample episodes are intentionally fake paths; they
exercise watched/progress/missing-media states but are not playable videos.

## Run

```sh
flutter run -d linux --target lib/main_showcase.dart
```

## Build an isolated Linux release bundle

Flutter's build directory is a persistent Flutter CLI setting rather than a
per-build option in this SDK. Use the wrapper so the Showcase bundle does not
overwrite `build/linux/...` and the temporary CLI setting is removed afterward:

```sh
tool/build_showcase_linux.sh
```

The bundle is written to `build_showcase/linux/x64/release/bundle/`.
