import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nekaido_pre/theme/app_palette.dart';

void main() {
  group('AppPalette', () {
    test('provides fixed accent palettes and the player marker', () {
      expect(AppPalette.fallbackAccent, Colors.redAccent);
      expect(AppPalette.accentPresets, hasLength(20));
      expect(AppPalette.accentPresets.first, const Color(0xFFF8BBD0));
      expect(AppPalette.accentPresets.last, const Color(0xFF1B5E20));
      expect(AppPalette.accentSpectrum, hasLength(6));
      expect(AppPalette.skipMarker, const Color(0xCCFFFFFF));
    });

    test('chooses a readable foreground for a dynamic accent', () {
      expect(AppPalette.onAccent(Colors.white), Colors.black);
      expect(AppPalette.onAccent(Colors.black), Colors.white);
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
