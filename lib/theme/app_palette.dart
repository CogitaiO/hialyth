import 'package:flutter/material.dart';

/// Fixed colours for bespoke UI that sits outside the semantic dark theme:
/// user-selectable accents, player-only markers and poster-derived effects.
abstract final class AppPalette {
  /// Used when no accent or poster colour can be derived.
  static const Color fallbackAccent = Colors.redAccent;

  /// Accent presets shown in Settings.
  static const List<Color> accentPresets = [
    Color(0xFFF8BBD0),
    Color(0xFFE1BEE7),
    Color(0xFFD1C4E9),
    Color(0xFFC5CAE9),
    Color(0xFFBBDEFB),
    Color(0xFFB3E5FC),
    Color(0xFFB2DFDB),
    Color(0xFFDCEDC8),
    Color(0xFF546E7A),
    Color(0xFF7E57C2),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFF9CCC65),
    Color(0xFFFFB74D),
    Color(0xFFFFA726),
    Color(0xFFFF8A65),
    Color(0xFF263238),
    Color(0xFF303F9F),
    Color(0xFF880E4F),
    Color(0xFF1B5E20),
  ];

  /// Rainbow ring around the custom accent picker.
  static const List<Color> accentSpectrum = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.red,
  ];

  /// Timeline marker for opening/ending intervals.
  static const Color skipMarker = Color(0xCCFFFFFF);

  /// Keeps text and icons readable on top of a dynamic accent.
  static Color onAccent(Color accent) =>
      accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  /// Poster-derived ambient glow and shadow.
  static Color posterGlow(Color color) => color.withValues(alpha: 0.15);

  static Color posterShadow(Color color) => color.withValues(alpha: 0.2);
}
