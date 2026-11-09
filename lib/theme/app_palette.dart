import 'package:flutter/material.dart';
import 'app_surfaces.dart';

/// Fixed colors for UI outside the semantic dark theme: accent presets,
/// player markers, and poster effects.
/// Updated to match design contract: Iris fallback, no red in presets.
abstract final class AppPalette {
  /// Fallback accent when no user preference or poster color is available.
  /// Iris #8B7CF6 — not red.
  static const Color fallbackAccent = Color(0xFF8B7CF6);

  /// Accent presets shown in Settings — curated, no red.
  static const List<Color> accentPresets = [
    // Iris / violet family
    Color(0xFF8B7CF6), // primary Iris
    Color(0xFFA78BFA),
    Color(0xFFC4B5FD),
    Color(0xFFDDD6FE),
    // Blue family
    Color(0xFF60A5FA),
    Color(0xFF93C5FD),
    Color(0xFFBFDBFE),
    Color(0xFFDBEAFE),
    // Teal / cyan family
    Color(0xFF2DD4BF),
    Color(0xFF5EEAD4),
    Color(0xFF99F6E4),
    Color(0xFFCCFBF1),
    // Green family
    Color(0xFF4ADE80),
    Color(0xFF86EFAC),
    Color(0xFFBBF7D0),
    Color(0xFFDCFCE7),
    // Amber / orange family
    Color(0xFFFBBF24),
    Color(0xFFFDE047),
    Color(0xFFFEF08A),
    Color(0xFFFEF9C3),
  ];

  /// Rainbow ring around the custom accent picker (hue sweep).
  static const List<Color> accentSpectrum = [
    Color(0xFFF87171), // red (only in picker spectrum)
    Color(0xFFFBBF24), // amber
    Color(0xFF4ADE80), // green
    Color(0xFF2DD4BF), // teal
    Color(0xFF60A5FA), // blue
    Color(0xFFA78BFA), // violet
    Color(0xFFF87171), // back to red
  ];

  /// Timeline marker for opening/ending intervals — white 80%.
  static const Color skipMarker = Color(0xCCFFFFFF);

  /// Returns black or white according to which gives better WCAG contrast.
  static Color onAccent(Color accent) {
    final luminance = accent.computeLuminance();
    final blackContrast = (luminance + 0.05) / 0.05;
    final whiteContrast = 1.05 / (luminance + 0.05);
    return blackContrast >= whiteContrast ? Colors.black : Colors.white;
  }

  /// Status colors — semantic, not accent.
  static const Color statusPlanned = AppSurfaces.statusPlanned;
  static const Color statusWatching = AppSurfaces.statusWatching;
  static const Color statusCompleted = AppSurfaces.statusCompleted;
  static const Color statusDropped = AppSurfaces.statusDropped;

  /// Semantic UI colors.
  static const Color success = AppSurfaces.success;
  static const Color warning = AppSurfaces.warning;
  static const Color danger = AppSurfaces.danger;
  static const Color info = AppSurfaces.info;

  /// Poster-derived ambient glow — 15% opacity.
  static Color posterGlow(Color color) => color.withValues(alpha: 0.15);

  /// Poster-derived ambient shadow — 20% opacity.
  static Color posterShadow(Color color) => color.withValues(alpha: 0.2);

  /// Window close button hover — Windows red.
  static const Color windowCloseHover = Color(0xFFE81123);
}
