import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../providers/player/player_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../core/localization/l10n.dart';
import '../../../../widgets/glass_surface.dart';

class PipOverlay extends ConsumerWidget {
  const PipOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.appTheme;
    final isVisible = ref.watch(playerProvider.select((s) => s.isUiVisible));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final volume = ref.watch(playerProvider.select((s) => s.volume));
    final notifier = ref.read(playerProvider.notifier);
    final reduceTransparency =
        ref.watch(settingsProvider.select((s) => s.reduceTransparency));

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
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
                child: GlassSurface(
                  reduceTransparency: reduceTransparency,
                  borderRadius: BorderRadius.circular(999),
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: IconButton(
                    iconSize: 48,
                    icon: Icon(
                      isPlaying ? AppIcons.pauseCircle : AppIcons.playCircle,
                      color: tokens.textPrimary,
                    ),
                    onPressed: () => notifier.togglePlay(),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSpacing.xs,
                left: AppSpacing.xs,
                right: AppSpacing.xs,
                child: GlassSurface(
                  reduceTransparency: reduceTransparency,
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        iconSize: 20,
                        icon: Icon(
                          volume == 0
                              ? AppIcons.volumeOff
                              : (volume < 50
                                  ? AppIcons.volumeDown
                                  : AppIcons.volumeUp),
                          color: tokens.textPrimary,
                        ),
                        onPressed: () => notifier.toggleMute(),
                      ),
                      IconButton(
                        iconSize: 20,
                        tooltip: context.l10n.playerReturnToPlayer,
                        icon: Icon(
                          AppIcons.openExternal,
                          color: tokens.textPrimary,
                        ),
                        onPressed: () => notifier.togglePiP(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
