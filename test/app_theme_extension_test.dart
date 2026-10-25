import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_theme_extension.dart';

void main() {
  group('AppThemeExtension', () {
    test('provides the existing dark palette and shared size scales', () {
      const theme = AppThemeExtension.dark();

      expect(theme.titleBarSurface, const Color(0xFF151515));
      expect(theme.cardSurface, const Color(0xFF1A1A1A));
      expect(theme.textPrimary, Colors.white);
      expect(theme.destructive, Colors.redAccent);
      expect(AppSpacing.xs, 8);
      expect(AppSpacing.md, 16);
      expect(AppSpacing.xl, 32);
      expect(AppRadii.md, 8);
      expect(AppRadii.lg, 12);
      expect(AppRadii.xl, 16);
    });

    test('supports ThemeExtension copy and interpolation', () {
      const theme = AppThemeExtension.dark();
      final copied = theme.copyWith(cardSurface: Colors.blue);
      final other = theme.copyWith(cardSurface: Colors.white);

      expect(copied.cardSurface, Colors.blue);
      expect(
          theme.lerp(other, 0.5).cardSurface,
          Color.lerp(
            theme.cardSurface,
            other.cardSurface,
            0.5,
          ));
    });
  });
}
