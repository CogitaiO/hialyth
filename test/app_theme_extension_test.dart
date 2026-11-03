import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_theme_extension.dart';

void main() {
  group('AppThemeExtension', () {
    test('provides the existing dark palette and shared size scales', () {
      const theme = AppThemeExtension.dark();

      expect(theme.pageSurface, const Color(0xFF0F0F0F));
      expect(theme.titleBarSurface, const Color(0xFF151515));
      expect(theme.cardSurface, const Color(0xFF1A1A1A));
      expect(theme.surfaceSubtle, const Color(0x0DFFFFFF));
      expect(theme.surfaceFaint, const Color(0x08FFFFFF));
      expect(theme.surfaceOverlay, Colors.black26);
      expect(theme.surfaceDisabled, Colors.white24);
      expect(theme.videoSurface, Colors.black);
      expect(theme.textPrimary, Colors.white);
      expect(theme.textSubtle, Colors.white38);
      expect(theme.textDisabled, Colors.white24);
      expect(theme.success, Colors.green);
      expect(theme.info, Colors.blueAccent);
      expect(theme.destructive, Colors.redAccent);
      expect(theme.windowCloseHover, const Color(0xFFE81123));
      expect(theme.scrim(0.5), Colors.black.withValues(alpha: 0.5));
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
      expect(AppRadii.sm, 6);
      expect(AppRadii.md, 8);
      expect(AppRadii.lg, 12);
      expect(AppRadii.xl, 16);
      expect(AppRadii.pill, 999);
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
