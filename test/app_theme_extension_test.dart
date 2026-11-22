import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_palette.dart';
import 'package:nekaido_pre/theme/app_breakpoints.dart';
import 'package:nekaido_pre/theme/app_motion.dart';
import 'package:nekaido_pre/theme/app_surfaces.dart';
import 'package:nekaido_pre/theme/app_theme.dart';
import 'package:nekaido_pre/theme/app_theme_extension.dart';
import 'package:nekaido_pre/theme/app_typography.dart';

void main() {
  group('AppThemeExtension', () {
    test('provides the updated dark palette and shared size scales', () {
      const theme = AppThemeExtension.dark();

      // Surfaces
      expect(theme.pageSurface, AppSurfaces.base);
      expect(theme.titleBarSurface, AppSurfaces.raised);
      expect(theme.cardSurface, AppSurfaces.quiet);
      expect(theme.container, AppSurfaces.container);
      expect(theme.containerHigh, AppSurfaces.containerHigh);
      expect(theme.hover, AppSurfaces.hover);
      expect(theme.surfaceSubtle, const Color(0x0DFFFFFF));
      expect(theme.surfaceFaint, const Color(0x08FFFFFF));
      expect(theme.surfaceHover, AppSurfaces.hover);
      expect(theme.surfaceDisabled, const Color(0x33FFFFFF));
      expect(theme.surfaceTooltip, AppSurfaces.base);
      expect(theme.surfaceOverlay, const Color(0xE10A0B0D));
      expect(theme.glass, const Color(0x8C14161A));
      expect(theme.videoSurface, Colors.black);
      expect(theme.borderFaint, const Color(0x1AFFFFFF));
      expect(theme.borderSubtle, AppSurfaces.borderSubtle);
      expect(theme.borderStrong, AppSurfaces.borderStrong);

      // Content
      expect(theme.textPrimary, AppSurfaces.contentPrimary);
      expect(theme.textSecondary, AppSurfaces.contentSecondary);
      expect(theme.textMuted, AppSurfaces.contentMuted);
      expect(theme.textSubtle, AppSurfaces.contentSecondary);
      expect(theme.textDisabled, const Color(0x33FFFFFF));

      // Semantic colors
      expect(theme.success, AppPalette.success);
      expect(theme.info, AppPalette.info);
      expect(theme.warning, AppPalette.warning);
      expect(theme.danger, AppPalette.danger);
      expect(theme.destructive, AppPalette.danger);
      expect(theme.statusPlanned, AppPalette.statusPlanned);
      expect(theme.statusWatching, AppPalette.statusWatching);
      expect(theme.statusCompleted, AppPalette.statusCompleted);
      expect(theme.statusDropped, AppPalette.statusDropped);

      // Window
      expect(theme.windowCloseHover, AppPalette.windowCloseHover);
      expect(theme.scrim(0.5), Colors.black.withValues(alpha: 0.5));

      // Spacing
      expect(AppSpacing.xxs, 4);
      expect(AppSpacing.s6, 6);
      expect(AppSpacing.xs, 8);
      expect(AppSpacing.s10, 10);
      expect(AppSpacing.sm, 12);
      expect(AppSpacing.s14, 14);
      expect(AppSpacing.md, 16);
      expect(AppSpacing.s20, 20);
      expect(AppSpacing.lg, 24);
      expect(AppSpacing.xl, 32);
      expect(AppSpacing.s40, 40);
      expect(AppSpacing.s48, 48);
      expect(AppSpacing.s50, 50);
      expect(AppSpacing.s64, 64);

      // Radii
      expect(AppRadii.sm, 6);
      expect(AppRadii.md, 8);
      expect(AppRadii.lg, 12);
      expect(AppRadii.xl, 16);
      expect(AppRadii.xxl, 24);
      expect(AppRadii.pill, 999);
    });

    test('raised layers stay distinct and artwork tints preserve contrast', () {
      const theme = AppThemeExtension.dark();
      final layers = [
        theme.pageSurface,
        theme.titleBarSurface,
        theme.cardSurface,
        theme.container,
        theme.containerHigh,
      ];
      for (var i = 1; i < layers.length; i++) {
        expect(
          layers[i].computeLuminance(),
          greaterThan(layers[i - 1].computeLuminance()),
        );
      }
      for (final artwork in [
        Colors.white,
        Colors.black,
        Colors.yellow,
        Colors.purple,
      ]) {
        final wash = AppSurfaces.artworkWash(artwork, theme.titleBarSurface);
        expect(
          (theme.textSecondary.computeLuminance() + .05) /
              (wash.computeLuminance() + .05),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('an accent only tints controls; the page remains pure black', () {
      final teal = AppTheme.dark(accent: Colors.teal);
      final plum = AppTheme.dark(accent: Colors.purple);
      expect(teal.scaffoldBackgroundColor, Colors.black);
      expect(plum.scaffoldBackgroundColor, Colors.black);
      expect(
        teal.colorScheme.surfaceContainer,
        isNot(plum.colorScheme.surfaceContainer),
      );
      for (final states in [
        <WidgetState>{},
        {WidgetState.selected},
      ]) {
        final thumb = teal.switchTheme.thumbColor!.resolve(states)!;
        final track = teal.switchTheme.trackColor!.resolve(states)!;
        expect(
          (thumb.computeLuminance() + .05) / (track.computeLuminance() + .05),
          greaterThan(3),
        );
      }
    });

    test('keeps the shared type, motion, and desktop layout scales named', () {
      expect(AppTypography.displayLarge.fontSize, 36);
      expect(AppTypography.headline.fontSize, 24);
      expect(AppTypography.title.fontSize, 16);
      expect(AppTypography.body.fontSize, 14);
      expect(AppTypography.caption.fontSize, 11);
      expect(AppTypography.mono.fontFamily, 'JetBrainsMono');

      expect(AppMotion.fast, const Duration(milliseconds: 100));
      expect(AppMotion.page, const Duration(milliseconds: 250));
      expect(
        AppMotion.effective(
          AppMotion.slow,
          decorative: true,
          reduceMotion: true,
        ),
        Duration.zero,
      );

      expect(AppBreakpoints.forWidth(839), Breakpoint.compact);
      expect(AppBreakpoints.forWidth(900), Breakpoint.medium);
      expect(AppBreakpoints.forWidth(1200), Breakpoint.expanded);
      expect(AppBreakpoints.forWidth(1600), Breakpoint.wide);
    });

    test('supports ThemeExtension copy and interpolation', () {
      const theme = AppThemeExtension.dark();
      final copied = theme.copyWith(cardSurface: Colors.blue);
      final other = theme.copyWith(cardSurface: Colors.white);

      expect(copied.cardSurface, Colors.blue);
      expect(
        theme.lerp(other, 0.5).cardSurface,
        Color.lerp(theme.cardSurface, other.cardSurface, 0.5),
      );
    });
  });
}
