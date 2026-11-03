import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../providers/player/player_provider.dart';
import '../../../theme/app_theme_extension.dart';

class PipOverlay extends ConsumerWidget {
  const PipOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final isVisible = ref.watch(playerProvider.select((s) => s.isUiVisible));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final volume = ref.watch(playerProvider.select((s) => s.volume));
    final notifier = ref.read(playerProvider.notifier);

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: tokens.scrim(0.54),
          child: Stack(
            children: [
              Positioned.fill(
                child: DragToMoveArea(
                  child: GestureDetector(
                    onDoubleTap: () => notifier.togglePiP(),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Center(
                child: IconButton(
                  iconSize: 48,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: tokens.textPrimary,
                  ),
                  onPressed: () => notifier.togglePlay(),
                ),
              ),
              Positioned(
                bottom: AppSpacing.xs,
                left: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      iconSize: 20,
                      icon: Icon(
                        volume == 0
                            ? Icons.volume_off
                            : (volume < 50
                                ? Icons.volume_down
                                : Icons.volume_up),
                        color: tokens.textPrimary,
                      ),
                      onPressed: () => notifier.toggleMute(),
                    ),
                    IconButton(
                      iconSize: 20,
                      tooltip: "Вернуться",
                      icon: Icon(Icons.open_in_new, color: tokens.textPrimary),
                      onPressed: () => notifier.togglePiP(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
