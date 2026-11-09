import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_palette.dart';

void main() {
  group('AppPalette', () {
    test('provides fixed accent palettes and the player marker', () {
      expect(AppPalette.fallbackAccent, const Color(0xFF8B7CF6)); // Iris
      expect(AppPalette.accentPresets, hasLength(20));
      expect(AppPalette.accentPresets.first, const Color(0xFF8B7CF6)); // Iris primary
      expect(AppPalette.accentPresets.last, const Color(0xFFFEF9C3)); // Light amber
      expect(AppPalette.accentSpectrum, hasLength(7)); // full hue cycle
      expect(AppPalette.skipMarker, const Color(0xCCFFFFFF));
    });

    test('chooses a readable foreground for a dynamic accent', () {
      expect(AppPalette.onAccent(Colors.white), Colors.black);
      expect(AppPalette.onAccent(Colors.black), Colors.white);
      // Iris accent should use dark text (luminance ~0.55 > 0.45)
      expect(AppPalette.onAccent(const Color(0xFF8B7CF6)), Colors.black);
    });

    test('derives ambient poster colours from the same source', () {
      expect(
        AppPalette.posterGlow(Colors.blue),
        Colors.blue.withValues(alpha: 0.15),
      );
      expect(
        AppPalette.posterShadow(Colors.blue),
        Colors.blue.withValues(alpha: 0.2),
      );
    });
  });
}