import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_palette.dart';
import 'package:nekaido_pre/theme/app_breakpoints.dart';
import 'package:nekaido_pre/theme/app_motion.dart';
import 'package:nekaido_pre/theme/app_theme_extension.dart';
import 'package:nekaido_pre/theme/app_typography.dart';

void main() {
  group('AppThemeExtension', () {
    test('provides the updated dark palette and shared size scales', () {
      const theme = AppThemeExtension.dark();

      // Surfaces
      expect(theme.pageSurface, const Color(0xFF0E0F11));
      expect(theme.titleBarSurface, const Color(0xFF15171A));
      expect(theme.cardSurface, const Color(0xFF1B1E22));
      expect(theme.container, const Color(0xFF1B1E22));
      expect(theme.containerHigh, const Color(0xFF22262B));
      expect(theme.hover, const Color(0xFF262B31));
      expect(theme.surfaceSubtle, const Color(0x0DFFFFFF));
      expect(theme.surfaceFaint, const Color(0x08FFFFFF));
      expect(theme.surfaceHover, const Color(0xFF262B31));
      expect(theme.surfaceDisabled, const Color(0x33FFFFFF));
      expect(theme.surfaceTooltip, const Color(0xFF0E0F11));
      expect(theme.surfaceOverlay, const Color(0xE10A0B0D));
      expect(theme.glass, const Color(0x8C14161A));
      expect(theme.videoSurface, Colors.black);
      expect(theme.borderFaint, const Color(0x1AFFFFFF));
      expect(theme.borderSubtle, const Color(0xFF262B31));
      expect(theme.borderStrong, const Color(0xFF343A42));

      // Content
      expect(theme.textPrimary, const Color(0xFFF4F6F8));
      expect(theme.textSecondary, const Color(0xFFB9C0C9));
      expect(theme.textMuted, const Color(0xFF858D98));
      expect(theme.textSubtle, const Color(0xFFB9C0C9));
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
        AppMotion.effective(AppMotion.slow,
            decorative: true, reduceMotion: true),
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
