Observed on Fedora 44 / GNOME Wayland / AMD Radeon Graphics with Flutter stable 3.47.8 (engine revision cf636b1dfb): a 1920x1080 external display runs at 100 Hz, while the laptop panel runs at about 60 Hz. In a Flutter desktop media app, animations felt noticeably less smooth on the 100 Hz display than on the 60 Hz panel.

A profile-mode VM timeline of the app contained 1421 `PlatformVsync` begin events, each with `frame_target_time - frame_start_time` = ~16.667 ms. The median interval between consecutive active frame start timestamps was also ~16.667 ms. This measures Flutter's frame scheduling, not physical presentation timestamps, and does not by itself establish the compositor's presented FPS. No comparison to a patched engine has been made.

A separate minimal Flutter example using a repeating AnimationController and a translating square was then run in profile mode. The tester reported visually uneven motion on the 100 Hz display. In its VM timeline, 8620 PlatformVsync begin events had target intervals of 16.666 or 16.667 ms; the median interval between consecutive active frame start timestamps was 16.667 ms. This first minimal example used the media app's Linux runner.

A follow-up used a newly generated Linux-only Flutter project with its default dependencies and the same minimal Dart source. Over a ten-second profile recording, 598 PlatformVsync events had target intervals of 16.666 or 16.667 ms, with a median active frame-start interval of 16.667 ms. This confirms the scheduling interval without the original application's runner or dependencies. The monitor containing the clean project window was not independently verified for that recording. Neither trace measures actual physical presentation cadence.

Reproduction: `flutter create --platforms=linux --project-name vsync_repro vsync_repro`, replace `lib/main.dart` with the minimal sample, and run `flutter run --profile -d linux`. Minimal `lib/main.dart`:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: VsyncRepro()));

class VsyncRepro extends StatefulWidget {
  const VsyncRepro({super.key});
  @override
  State<VsyncRepro> createState() => _VsyncReproState();
}

class _VsyncReproState extends State<VsyncRepro>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Transform.translate(
              offset: Offset((controller.value - .5) * 500, 0),
              child: child,
            ),
            child: const SizedBox(
              width: 70,
              height: 70,
              child: ColoredBox(color: Colors.blue),
            ),
          ),
        ),
      );
}
```

No raw traces are attached; the numbers above summarize local measurements.
